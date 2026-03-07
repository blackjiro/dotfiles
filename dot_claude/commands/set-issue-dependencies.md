---
description: Set blocked-by dependencies between GitHub issues
allowed-tools: ["Bash"]
---

GitHub Issueの依存関係（blocked by）を設定します。

ユーザーから依存関係の指示を受け取り、GraphQL APIで設定します。

## 使い方

ユーザーが以下のような形式で依存関係を指示します:
- 「#10 は #8 と #9 にブロックされる」
- 「#8 blocked by #7」
- または複数のissueの依存関係を一括指定

## 実行手順

1. 対象issueのnode IDを取得:
   ```bash
   gh issue view <番号> --json id --jq .id
   ```

2. `addBlockedBy` mutationで依存関係を設定:
   ```bash
   gh api graphql -f query='mutation { addBlockedBy(input: {issueId: "<ブロックされる側のnode ID>", blockingIssueId: "<ブロックする側のnode ID>"}) { clientMutationId } }'
   ```

3. 設定した依存関係を一覧で報告

## 依存関係の解除

解除が必要な場合は `removeBlockedBy` を使用:
```bash
gh api graphql -f query='mutation { removeBlockedBy(input: {issueId: "<node ID>", blockingIssueId: "<node ID>"}) { clientMutationId } }'
```

## 備考

- `addIssueDependency` は存在しない。正しいmutation名は `addBlockedBy` / `removeBlockedBy`
- `issueId` = ブロックされる側、`blockingIssueId` = ブロックする側
