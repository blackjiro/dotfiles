#!/bin/bash
# claude-scheduler.sh: Claude Code定期実行スクリプト（汎用版）
# Usage: claude-scheduler.sh <repo-path>
#
# リポジトリの .claude/scheduler-config.sh から設定を読み込み、
# 指定されたタスクを順番に実行します。

set -euo pipefail

REPO_PATH="${1:-}"
LOG_DIR="${CLAUDE_SCHEDULER_LOG_DIR:-$HOME/logs/claude-scheduler}"

# 使用方法
if [[ -z "$REPO_PATH" ]]; then
    echo "Usage: claude-scheduler.sh <repo-path>"
    echo "Example: claude-scheduler.sh ~/workspaces/my-project"
    exit 1
fi

# リポジトリパスの検証
if [[ ! -d "$REPO_PATH/.claude/scheduled-tasks" ]]; then
    echo "Error: scheduled-tasks directory not found at $REPO_PATH/.claude/scheduled-tasks" >&2
    exit 1
fi

# 設定ファイルの読み込み
CONFIG_FILE="$REPO_PATH/.claude/scheduler-config.sh"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: scheduler-config.sh not found at $CONFIG_FILE" >&2
    echo "Please create .claude/scheduler-config.sh in your repository" >&2
    exit 1
fi

# 設定を読み込む
source "$CONFIG_FILE"

# 必須変数のチェック
if [[ -z "${TASKS:-}" ]]; then
    echo "Error: TASKS variable not defined in $CONFIG_FILE" >&2
    exit 1
fi

# ログディレクトリ作成
mkdir -p "$LOG_DIR"

# 日付
DATE=$(date +%Y%m%d_%H%M%S)

# Slack通知関数
notify_slack() {
    local message="$1"
    local color="${2:-good}"

    if [[ -n "${SLACK_WEBHOOK_URL:-}" ]]; then
        curl -s -X POST "$SLACK_WEBHOOK_URL" \
            -H "Content-Type: application/json" \
            -d "{
                \"attachments\": [{
                    \"color\": \"$color\",
                    \"text\": \"$message\"
                }]
            }" > /dev/null 2>&1 || true
    fi
}

# タスク実行関数
run_task() {
    local task_name="$1"
    local task_file="$REPO_PATH/.claude/scheduled-tasks/${task_name}.md"
    local log_file="$LOG_DIR/${task_name}_${DATE}.log"

    if [[ ! -f "$task_file" ]]; then
        echo "Task file not found: $task_file" >&2
        return 1
    fi

    echo "$(date '+%Y-%m-%d %H:%M:%S') Starting task: $task_name" | tee -a "$log_file"

    # Claude CLI実行
    cd "$REPO_PATH"

    # miseの環境変数を読み込む（mise.toml, mise.local.tomlから）
    if command -v mise &> /dev/null; then
        eval "$(mise env -C "$REPO_PATH" 2>/dev/null)" || true
    fi

    # 設定からClaude CLIオプションを構築
    local claude_opts=(
        --print
        --output-format json
        --permission-mode bypassPermissions
    )

    # allowedToolsが設定されている場合のみ追加
    if [[ -n "${ALLOWED_TOOLS:-}" ]]; then
        claude_opts+=(--allowedTools "$ALLOWED_TOOLS")
    fi

    local result
    if cat "$task_file" | claude "${claude_opts[@]}" 2>&1 | tee -a "$log_file"; then
        result="success"
    else
        result="failed"
    fi

    echo "$(date '+%Y-%m-%d %H:%M:%S') Task completed: $task_name ($result)" | tee -a "$log_file"

    return 0
}

# メイン処理
main() {
    echo "========================================"
    echo "Claude Scheduler Started: $(date)"
    echo "Repository: $REPO_PATH"
    echo "========================================"

    notify_slack "${START_MESSAGE:-🚀 Claude定期タスクを開始します}" "good"

    local errors=0
    local task_num=1

    # TASKSをスペース区切りで分割して実行
    for task in $TASKS; do
        echo ""
        echo "--- Task $task_num: $task ---"
        if ! run_task "$task"; then
            echo "Warning: $task task failed" >&2
            ((errors++))
        fi
        ((task_num++))

        # タスク間の待機時間（設定されている場合）
        if [[ -n "${TASK_INTERVAL:-}" ]]; then
            sleep "$TASK_INTERVAL"
        fi
    done

    echo ""
    echo "========================================"
    echo "Claude Scheduler Finished: $(date)"
    echo "Errors: $errors"
    echo "========================================"

    # 完了通知
    if [[ $errors -eq 0 ]]; then
        notify_slack "${SUCCESS_MESSAGE:-✅ Claude定期タスクが完了しました}\nログ: $LOG_DIR" "good"
    else
        notify_slack "${ERROR_MESSAGE:-⚠️ Claude定期タスクが完了しました（エラー: ${errors}件）}\nログ: $LOG_DIR" "warning"
    fi
}

main "$@"
