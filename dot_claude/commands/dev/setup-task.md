---
allowed-tools: Bash(*), Read(*), Write(*), Edit(*), LS(*), TodoWrite(*), TodoRead(*)
description: "taskコマンドをaqua経由でセットアップし、Taskfile.ymlに新しいタスクを追加"
---

# Setup Aqua Task

taskコマンドをaqua経由でセットアップし、Taskfile.ymlに新しいタスクを追加するためのコマンドです。

## 概要

このコマンドは以下の処理を行います：

1. **初期セットアップ確認**
   - aqua.ymlの存在確認と作成
   - taskのインストール（aqua install）
   - Taskfile.ymlの初期化（task --init）

2. **新規タスクの追加**
   - ユーザーの要件をヒアリング
   - Taskfile.ymlへの新規タスク追加

## 動作フロー

1. プロジェクトルートでaqua.ymlを確認
2. 存在しない場合は、go-task/taskを含むaqua.ymlを作成
3. Taskfile.ymlの存在を確認
4. 存在しない場合：
   - `task --init`を実行
   - コマンドが見つからない場合は`aqua install`を実行してから再度`task --init`
5. ユーザーに追加したいタスクの詳細を質問
6. 要件に基づいてTaskfile.ymlに新規タスクを追加

## 使用例

```
/setup-aqua-task
```

実行すると、以下のような質問をします：
- どのようなタスクを追加したいですか？
- タスクの名前は何にしますか？
- どのようなコマンドを実行しますか？
- 依存関係や変数は必要ですか？

## 前提条件

- [aqua](https://aquaprj.github.io/)がインストールされていること
- Gitリポジトリ内で実行すること

## 参考リンク

- [Task Documentation](https://taskfile.dev/)
- [Aqua Documentation](https://aquaprj.github.io/)
- [Aqua Registry](https://github.com/aquaproj/aqua-registry)

