---
description: Squash merge the current PR
allowed-tools: ["Bash"]
---

現在のブランチのPRをsquash mergeします。

## 実行手順

1. 現在のブランチに対応するPRを確認:
   ```bash
   gh pr view --json number,title,state
   ```

2. PRが存在し、OPENであればsquash merge:
   ```bash
   gh pr merge --squash
   ```

3. 完了を報告

## 備考

- `--delete-branch` オプションは使用しません（worktree環境でエラーになるため）
- リモートブランチの削除はGitHubのリポジトリ設定「Automatically delete head branches」で自動化されているため、コマンド側での削除は不要です
