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

# --print モードの場合はスキップ（StructuredOutput との競合を防ぐ）
if os.environ.get("CLAUDE_CODE_ENTRYPOINT") == "cli-print":
    sys.exit(0)

# =============================================================================
# 設定
# =============================================================================

MAX_REVIEW_COUNT = 3
COUNT_FILE_TEMPLATE = "/tmp/claude_review_count_{session_id}.txt"
MIN_LINES_FOR_REVIEW = 50  # この行数以下の変更はレビューをスキップ

# 実装を示すツール名
IMPLEMENTATION_TOOLS = {"Edit", "MultiEdit", "Write"}


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


def analyze_transcript(transcript_path: str | None) -> tuple[bool, bool]:
    """
    トランスクリプトを解析して実装変更とタスク全完了を検出

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
    total_tasks = 0
    completed_task_ids: set[str] = set()

    try:
        with open(path, "r", encoding="utf-8") as f:
            # 最新1000行のみ解析（パフォーマンス考慮）
            lines = f.readlines()[-1000:]

        for line in lines:
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue

            entry_type = entry.get("type")
            if entry_type != "assistant":
                continue

            message = entry.get("message", {})
            content = message.get("content", [])
            if not isinstance(content, list):
                continue

            for item in content:
                if not isinstance(item, dict) or item.get("type") != "tool_use":
                    continue

                tool_name = item.get("name", "")

                # 実装変更検出
                if tool_name in IMPLEMENTATION_TOOLS:
                    has_implementation = True

                # タスク作成検出
                if tool_name == "TaskCreate":
                    total_tasks += 1

                # タスク完了検出
                if tool_name == "TaskUpdate":
                    tool_input = item.get("input", {})
                    if tool_input.get("status") == "completed":
                        task_id = tool_input.get("taskId")
                        if task_id:
                            completed_task_ids.add(task_id)

    except Exception:
        return (False, False)

    # タスクリスト未使用なら完了とみなさない
    is_complete = total_tasks > 0 and total_tasks == len(completed_task_ids)
    return (has_implementation, is_complete)


# =============================================================================
# レビュー指示生成
# =============================================================================


def build_review_instruction(changed_lines: int) -> dict:
    """レビュー指示を生成"""
    reason = f"""[自動リマインド] 全タスク完了を検出しました（変更{changed_lines}行）。
/auto-reviewing を実行してください。
レビュー不要な場合はスキップして構いません。"""
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
    has_implementation, is_complete = analyze_transcript(transcript_path)

    # 実装がなければスキップ
    if not has_implementation:
        sys.exit(0)

    # 全タスク完了でなければスキップ
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

    # 5. レビュー指示生成
    increment_review_count(session_id)
    instruction = build_review_instruction(changed_lines)

    # 7. 出力
    print(json.dumps(instruction, ensure_ascii=False))
    sys.exit(0)


if __name__ == "__main__":
    main()
