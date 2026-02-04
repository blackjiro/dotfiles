#!/bin/bash
# worktree環境での gh pr merge --delete-branch 警告hook
# PreToolUse で実行され、worktree環境で --delete-branch を使おうとした場合に警告する

read -r INPUT

COMMAND=$(echo "$INPUT" | jq -r '.params.command // empty' 2>/dev/null)

if [ -z "$COMMAND" ]; then
  exit 0
fi

# gh pr merge --delete-branch を検出
if [[ "$COMMAND" =~ gh[[:space:]]+pr[[:space:]]+merge.*--delete-branch ]]; then
  # worktree環境かどうかを判定
  # git worktree list の出力が2行以上あればworktree使用中
  WORKTREE_COUNT=$(git worktree list 2>/dev/null | wc -l | tr -d ' ')

  if [ "$WORKTREE_COUNT" -gt 1 ]; then
    # 現在のディレクトリがworktreeかどうか確認
    MAIN_WORKTREE=$(git worktree list 2>/dev/null | head -1 | awk '{print $1}')
    CURRENT_DIR=$(pwd)

    if [ "$CURRENT_DIR" != "$MAIN_WORKTREE" ]; then
      cat <<EOF
{
  "decision": "block",
  "message": "worktree環境では --delete-branch オプションを使用できません（mainブランチが別のworktreeで使用中のため）。代わりに以下を実行してください:\n\n1. gh pr merge <PR番号> --squash  (--delete-branch なし)\n2. リモートブランチはGitHubで自動削除されます（設定済みの場合）"
}
EOF
      exit 0
    fi
  fi
fi

exit 0
