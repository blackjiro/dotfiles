---
allowed-tools: Read, Write, Edit
description: "要件定義書を作成するコマンド。ユーザーとの対話を通じて必要な情報を収集し、包括的な要件定義書を生成します。"
---

# 要件定義書作成

要件定義書を作成します: $ARGUMENTS

## 実行手順

### 1. 初期情報収集

まず、以下の基本情報について確認させていただきます：

- **プロジェクト概要**: $ARGUMENTSの詳細な説明
- **目的と背景**: なぜこの要件が必要なのか
- **スコープ**: 対象範囲と除外事項
- **ステークホルダー**: 関係者とその役割
- **制約条件**: 技術的、時間的、予算的な制約

### 2. 詳細要件の確認

基本情報を元に、以下の詳細について確認します：

- **機能要件**: 具体的に何を実現する必要があるか
- **非機能要件**: 性能、セキュリティ、使いやすさなどの要件
- **インターフェース要件**: 他システムとの連携や画面設計
- **データ要件**: 扱うデータの種類と形式
- **運用要件**: メンテナンスやサポートに関する要件

### 3. 深掘り検討

収集した情報を基に、以下の観点で追加検討が必要な項目を洗い出します：

- **リスク要因**: 実現上の課題や懸念事項
- **依存関係**: 他のシステムやプロジェクトとの関連
- **優先順位**: 要件の重要度と実装順序
- **受け入れ基準**: 要件が満たされたと判断する基準
- **将来的な拡張性**: 今後の発展可能性

### 4. 最終確認と文書生成

すべての情報が揃ったら、要件定義書の構成を提示し、確認を求めます。
確認後、`docs/requirements/`ディレクトリに以下の形式でマークダウン文書を生成します：

```markdown
# [プロジェクト名] 要件定義書

## 1. プロジェクト概要
### 1.1 背景と目的
### 1.2 スコープ
### 1.3 ステークホルダー

## 2. 要件定義
### 2.1 機能要件
### 2.2 非機能要件
### 2.3 インターフェース要件
### 2.4 データ要件

## 3. 制約条件とリスク
### 3.1 制約条件
### 3.2 リスクと対策

## 4. 実装計画
### 4.1 優先順位
### 4.2 マイルストーン

## 5. 受け入れ基準

## 6. 付録
### 6.1 用語集
### 6.2 参考資料
```

## 使用例

```
/requirements ユーザー管理システム
/requirements ECサイトの決済機能
/requirements モバイルアプリのプッシュ通知機能
```

## 注意事項

- 要件定義書は`docs/requirements/`ディレクトリに、`[連番]_[要件名].md`の形式で保存されます
- 既存のファイルがある場合は、上書きするか確認します
- 機密情報が含まれる場合は、適切にマスキングして記載します
