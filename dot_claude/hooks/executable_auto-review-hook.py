#!/usr/bin/env python3
"""
Claude Code 自動レビューフック

Stop 毎に軽量レビュー、完成時に包括的レビューを自動実行する。
"""
import json
import os
import sys
from pathlib import Path

# =============================================================================
# 設定
# =============================================================================

MAX_REVIEW_COUNT = 3
COUNT_FILE_TEMPLATE = "/tmp/claude_review_count_{session_id}.txt"

# 実装を示すツール名
IMPLEMENTATION_TOOLS = {"Edit", "MultiEdit", "Write"}

# 完成を示すキーワード（小文字で比較）
COMPLETION_KEYWORDS = [
    # 日本語
    "完成",
    "完了",
    "実装完了",
    "終了",
    "終わり",
    "できました",
    "コミットします",
    "コミットしました",
    "pr作成",
    "プルリクエスト",
    # 英語
    "done",
    "finished",
    "completed",
    "complete",
    "ready",
    "ready for review",
    "ready to commit",
    "creating pr",
    "implementation complete",
    "all done",
]


# =============================================================================
# レビューカウント管理
# =============================================================================


def get_count_file(session_id: str) -> Path:
    """セッションごとのカウントファイルパスを取得"""
    return Path(COUNT_FILE_TEMPLATE.format(session_id=session_id))


def get_review_count(session_id: str) -> int:
    """レビュー回数を取得"""
    count_file = get_count_file(session_id)
    if count_file.exists():
        try:
            return int(count_file.read_text().strip())
        except (ValueError, OSError):
            return 0
    return 0


def increment_review_count(session_id: str) -> None:
    """レビュー回数をインクリメント"""
    count = get_review_count(session_id) + 1
    try:
        get_count_file(session_id).write_text(str(count))
    except OSError:
        pass


def reset_review_count(session_id: str) -> None:
    """レビュー回数をリセット"""
    try:
        get_count_file(session_id).unlink(missing_ok=True)
    except OSError:
        pass


# =============================================================================
# トランスクリプト解析
# =============================================================================


def analyze_transcript(transcript_path: str | None) -> tuple[bool, bool]:
    """
    トランスクリプトを解析して実装変更と完成状態を検出

    Args:
        transcript_path: transcript.jsonl のパス

    Returns:
        (has_implementation, is_complete) のタプル
    """
    if not transcript_path:
        return (False, False)

    path = Path(transcript_path).expanduser()
    if not path.exists():
        return (False, False)

    has_implementation = False
    is_complete = False

    try:
        with open(path, "r", encoding="utf-8") as f:
            # 最新1000行のみ解析（パフォーマンス考慮）
            lines = f.readlines()[-1000:]

        for line in lines:
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue

            # 実装変更検出: assistant メッセージ内の tool_use から Edit/MultiEdit/Write を検出
            entry_type = entry.get("type")
            if entry_type == "assistant":
                message = entry.get("message", {})
                content = message.get("content", [])
                if isinstance(content, list):
                    for item in content:
                        if isinstance(item, dict) and item.get("type") == "tool_use":
                            tool_name = item.get("name", "")
                            if tool_name in IMPLEMENTATION_TOOLS:
                                has_implementation = True

            # 完成キーワード検出: 直近のメッセージから検出
            text_content = ""
            if entry.get("type") == "human":
                message = entry.get("message", {})
                content = message.get("content", "")
                if isinstance(content, str):
                    text_content = content
                elif isinstance(content, list):
                    for item in content:
                        if isinstance(item, dict) and item.get("type") == "text":
                            text_content += item.get("text", "")
            elif entry.get("type") == "assistant":
                message = entry.get("message", {})
                content = message.get("content", [])
                if isinstance(content, list):
                    for item in content:
                        if isinstance(item, dict) and item.get("type") == "text":
                            text_content += item.get("text", "")

            text_lower = text_content.lower()
            for keyword in COMPLETION_KEYWORDS:
                if keyword.lower() in text_lower:
                    is_complete = True
                    break

    except Exception:
        return (False, False)

    return (has_implementation, is_complete)


# =============================================================================
# レビュー指示生成
# =============================================================================


def get_thinking_level(is_vertex: bool, is_comprehensive: bool) -> str:
    """環境とレビュータイプに応じた Thinking レベルを決定"""
    if is_vertex:
        return "think hard" if is_comprehensive else "think"
    else:
        return "ultrathink" if is_comprehensive else "think hard"


def build_lightweight_review(is_vertex: bool, review_count: int) -> dict:
    """軽量レビュー（Stop 毎）の指示を生成"""
    thinking = get_thinking_level(is_vertex, is_comprehensive=False)

    reason = f"""{thinking}

/pr-review-toolkit:review-pr code を実行してください。

## 対応方針
- 🔴 Critical Issues → 今すぐ修正
- 🟡 Important/Suggestions → メモして後で対応
- 🟠 判断困難な問題 → AskUserQuestion で確認

(レビュー {review_count}/{MAX_REVIEW_COUNT})"""

    return {"decision": "block", "reason": reason}


def build_comprehensive_review(is_vertex: bool) -> dict:
    """包括的レビュー（完成時）の指示を生成"""
    thinking = get_thinking_level(is_vertex, is_comprehensive=True)

    reason = f"""{thinking}

/pr-review-toolkit:review-pr all を実行してください。

## 対応方針
- Critical Issues → 自動修正
- Important Issues → 修正推奨（私の意見を添えて）
- Suggestions → 検討事項として報告
- 判断困難な問題 → AskUserQuestion で確認

完成時の最終レビューです。"""

    return {"decision": "block", "reason": reason}


# =============================================================================
# メイン処理
# =============================================================================


def main() -> None:
    """メインエントリーポイント"""
    try:
        # 1. 入力パース
        input_data = json.load(sys.stdin)
    except json.JSONDecodeError:
        # JSON パースエラーはスキップ
        sys.exit(0)

    # 2. 早期リターン判定

    # 無限ループ防止: stop_hook_active が True ならスキップ
    if input_data.get("stop_hook_active"):
        sys.exit(0)

    # Plan モードはスキップ
    if input_data.get("permission_mode") == "plan":
        sys.exit(0)

    # セッション ID 取得
    session_id = input_data.get("session_id", "default")

    # レビュー回数上限チェック
    review_count = get_review_count(session_id)
    if review_count >= MAX_REVIEW_COUNT:
        reset_review_count(session_id)
        sys.exit(0)

    # 3. トランスクリプト解析
    transcript_path = input_data.get("transcript_path")
    has_implementation, is_complete = analyze_transcript(transcript_path)

    # 実装がなければスキップ
    if not has_implementation:
        sys.exit(0)

    # 4. 環境検出
    is_vertex = os.environ.get("CLAUDE_CODE_USE_VERTEX") == "1"

    # 5. レビュー指示生成
    if is_complete:
        # 包括的レビュー（完成時）
        reset_review_count(session_id)
        instruction = build_comprehensive_review(is_vertex)
    else:
        # 軽量レビュー（Stop 毎）
        increment_review_count(session_id)
        instruction = build_lightweight_review(is_vertex, review_count + 1)

    # 6. 出力
    print(json.dumps(instruction, ensure_ascii=False))
    sys.exit(0)


if __name__ == "__main__":
    main()
