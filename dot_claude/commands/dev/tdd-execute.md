---
allowed-tools: Bash(*), Read(*), Write(*), Edit(*), Grep(*), Glob(*), TodoWrite(*), TodoRead(*)
description: "TDDで最新のPLAN.mdまたはSCRATCHPAD.mdからタスクを実行"
---

# TDD Execute Plan

最新のPLAN.mdまたはSCRATCHPAD.mdファイルを見つけて、記載されているタスクをTDD方式で実行します。

## Instructions

1. **計画ドキュメントの検索**
   - 現在のディレクトリとサブディレクトリからPLAN.mdまたはSCRATCHPAD.mdを検索
   - 複数見つかった場合は最新のものを使用
   - 見つからない場合はホームディレクトリも検索

2. **タスクの抽出と解析**
   - 見つかったドキュメントを読み込む
   - TODOリスト、タスクリスト、または番号付きリストを抽出
   - タスクの優先順位を判定

3. **TDD実行サイクル**
   各タスクに対して：
   - **Red**: 失敗するテストを作成
   - **Green**: テストが通る最小限の実装
   - **Refactor**: コードの改善とクリーンアップ

4. **進捗管理**
   - TodoWriteツールで各タスクの進捗を管理
   - 完了したタスクにチェックマークを付ける
   - 実行結果をドキュメントに記録

5. **完了確認**
   - すべてのテストが通ることを確認
   - lintとtypecheckを実行
   - 実行結果のサマリーを表示

## Error Handling

- 計画ドキュメントが見つからない場合は、ユーザーに作成を促す
- テスト実行に失敗した場合は、エラー内容を分析して修正案を提示
- 依存関係の問題がある場合は、必要なパッケージのインストールを提案

## Usage Example

```
/dev:tdd-execute
```

このコマンドは自動的に最新の計画ドキュメントを見つけて、TDD方式でタスクを実行します。