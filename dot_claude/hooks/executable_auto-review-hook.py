#!/usr/bin/env python3
"""
Claude Code 自動レビューフック

Stop 毎に軽量レビュー、完成時に包括的レビューを自動実行する。
"""
import json
import os
import subprocess
import sys
from pathlib import Path

# =============================================================================
# 設定
# =============================================================================

MAX_REVIEW_COUNT = 3
COUNT_FILE_TEMPLATE = "/tmp/claude_review_count_{session_id}.txt"
MIN_LINES_FOR_REVIEW = 50  # この行数以下の変更はレビューをスキップ
RECENT_ENTRIES_FOR_COMPLETION = 10  # 完成キーワード検出対象の直近エントリ数

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
# Git 変更検出
# =============================================================================


def has_uncommitted_changes() -> bool:
    """未コミットの変更があるかチェック"""
    try:
        result = subprocess.run(
            ["git", "diff", "--name-only"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        return bool(result.stdout.strip())
    except (subprocess.TimeoutExpired, FileNotFoundError, OSError):
        # git がない、タイムアウトなどの場合は変更ありとみなす
        return True


def get_changed_lines_count() -> int:
    """変更行数を取得（追加行 + 削除行）"""
    try:
        result = subprocess.run(
            ["git", "diff", "--numstat"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        total_lines = 0
        for line in result.stdout.strip().split("\n"):
            if not line:
                continue
            parts = line.split("\t")
            if len(parts) >= 2:
                added = int(parts[0]) if parts[0] != "-" else 0
                deleted = int(parts[1]) if parts[1] != "-" else 0
                total_lines += added + deleted
        return total_lines
    except (subprocess.TimeoutExpired, FileNotFoundError, OSError, ValueError):
        # エラー時は大きな値を返してレビューを実行させる
        return 9999


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


def analyze_transcript(transcript_path: str | None) -> tuple[bool, bool, str | None]:
    """
    トランスクリプトを解析して実装変更と完成状態を検出

    Args:
        transcript_path: transcript.jsonl のパス

    Returns:
        (has_implementation, is_complete, detected_keyword) のタプル
    """
    if not transcript_path:
        return (False, False, None)

    path = Path(transcript_path).expanduser()
    if not path.exists():
        return (False, False, None)

    has_implementation = False
    is_complete = False
    detected_keyword: str | None = None
    all_entries: list[dict] = []

    try:
        with open(path, "r", encoding="utf-8") as f:
            # 最新1000行のみ解析（パフォーマンス考慮）
            lines = f.readlines()[-1000:]

        for line in lines:
            try:
                entry = json.loads(line)
                all_entries.append(entry)
            except json.JSONDecodeError:
                continue

        # 実装変更検出: 全エントリから Edit/MultiEdit/Write を検出
        for entry in all_entries:
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
                                break
                if has_implementation:
                    break

        # 完成キーワード検出: 直近N件のエントリのみ対象
        for entry in all_entries[-RECENT_ENTRIES_FOR_COMPLETION:]:
            text_content = ""
            entry_type = entry.get("type")

            if entry_type == "human":
                message = entry.get("message", {})
                content = message.get("content", "")
                if isinstance(content, str):
                    text_content = content
                elif isinstance(content, list):
                    for item in content:
                        if isinstance(item, dict) and item.get("type") == "text":
                            text_content += item.get("text", "")
            elif entry_type == "assistant":
                message = entry.get("message", {})
                content = message.get("content", [])
                if isinstance(content, list):
                    for item in content:
                        if isinstance(item, dict) and item.get("type") == "text":
                            text_content += item.get("text", "")

            if text_content:
                text_lower = text_content.lower()
                for keyword in COMPLETION_KEYWORDS:
                    if keyword.lower() in text_lower:
                        is_complete = True
                        detected_keyword = keyword
                        break
                if is_complete:
                    break

    except Exception:
        return (False, False, None)

    return (has_implementation, is_complete, detected_keyword)


# =============================================================================
# レビュー指示生成
# =============================================================================


def get_thinking_level(is_vertex: bool) -> str:
    """環境に応じた Thinking レベルを決定"""
    return "think hard" if is_vertex else "ultrathink"


def build_review_instruction(
    is_vertex: bool, detected_keyword: str | None, changed_lines: int
) -> dict:
    """レビュー指示を生成"""
    thinking = get_thinking_level(is_vertex)

    # Vertex AI 環境では Codex は使用不可
    codex_instruction = ""
    if not is_vertex:
        codex_instruction = """
## Codex 並行レビュー
mcp__codex__codex ツールが利用可能な場合は、以下も並行実行：
- prompt: "Perform a comprehensive code review of all changes. Check for bugs, security vulnerabilities, performance issues, and adherence to best practices"
"""

    # 検知理由の表示
    detection_info = f"""検知理由:
- 完成キーワード: 「{detected_keyword}」を検出
- 変更規模: {changed_lines}行（閾値{MIN_LINES_FOR_REVIEW}行以上）"""

    reason = f"""[自動レビュー] 完成時の包括的レビューを実行します

{thinking}

{detection_info}

/pr-review-toolkit:review-pr all を実行してください。
{codex_instruction}
## 軽微な変更の場合
変更内容が軽微（設定変更、リネーム、フォーマット修正など）と判断した場合は、
詳細レビューをスキップし「軽微な変更のため詳細レビュー不要」と報告してください。

## 注意
レビュー結果は必ずしも妥当とは限りません。修正前に妥当性を確認してください。

## 対応方針
1. 各レビューコメントの妥当性を確認
2. Critical/Important で妥当なもの → 修正
3. Suggestions → 検討事項として報告
4. 判断困難 → AskUserQuestion で確認
5. 修正後、再度レビューを実行
6. 妥当でないコメントのみ or コメントなしになるまで繰り返す"""

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

    # 未コミット変更がなければスキップ
    if not has_uncommitted_changes():
        sys.exit(0)

    # 3. トランスクリプト解析
    transcript_path = input_data.get("transcript_path")
    has_implementation, is_complete, detected_keyword = analyze_transcript(
        transcript_path
    )

    # 実装がなければスキップ
    if not has_implementation:
        sys.exit(0)

    # 完成キーワードがなければスキップ（完成時のみレビュー）
    if not is_complete:
        sys.exit(0)

    # 4. 変更行数チェック
    changed_lines = get_changed_lines_count()
    if changed_lines <= MIN_LINES_FOR_REVIEW:
        sys.exit(0)

    # セッション ID 取得
    session_id = input_data.get("session_id", "default")

    # レビュー回数上限チェック
    review_count = get_review_count(session_id)
    if review_count >= MAX_REVIEW_COUNT:
        reset_review_count(session_id)
        sys.exit(0)

    # 5. 環境検出
    is_vertex = os.environ.get("CLAUDE_CODE_USE_VERTEX") == "1"

    # 6. レビュー指示生成
    increment_review_count(session_id)
    instruction = build_review_instruction(is_vertex, detected_keyword, changed_lines)

    # 7. 出力
    print(json.dumps(instruction, ensure_ascii=False))
    sys.exit(0)


if __name__ == "__main__":
    main()
