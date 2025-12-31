---
description: Create a new worktree in Zellij pane with auto-generated branch name
model: claude-3-5-haiku-20241022
allowed-tools: ["Bash"]
---

会話のコンテキストから、ユーザーが取り組もうとしているタスクに適したブランチ名を生成し、
gw-handoff スクリプトを実行してください。

## ブランチ名の規則

- 形式: `<prefix>/<short-description>`
- prefix の種類:
  - `feat/` - 新機能
  - `fix/` - バグ修正
  - `refactor/` - リファクタリング
  - `docs/` - ドキュメント
  - `chore/` - その他の作業
- short-description: 英語、ケバブケース、簡潔に（2-4単語程度）

## 実行手順

1. 会話の文脈から、タスクの内容を理解する
2. 適切なブランチ名を1つ決定する（ユーザーへの確認は不要）
3. 現在のブランチを確認する:
   ```bash
   git rev-parse --abbrev-ref HEAD
   ```
4. 現在のブランチが main/master でない場合は `-c` オプションを付ける
5. 以下のコマンドを実行する:
   ```bash
   # main/master から分岐する場合
   gw-handoff <決定したブランチ名>

   # 現在のブランチから分岐する場合
   gw-handoff <決定したブランチ名> -c
   ```

## 例

- ユーザー認証機能の追加 → `gw-handoff feat/add-user-auth`
- ログインバグの修正 → `gw-handoff fix/login-validation`
- API クライアントのリファクタリング → `gw-handoff refactor/api-client`
