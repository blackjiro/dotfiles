---
name: bdd-testing
description: >-
  BDDテストガイドライン。テスト計画、テスト設計、TDD、BDD、behavior、
  振る舞い駆動、GIVEN/WHEN/THEN、mockポリシーに関連する場面で自動参照。
user-invocable: false
---

# BDDテストガイドライン

テストの設計・記述・レビューにおけるルールを定義する。

## Mockポリシー（3段階）

### 禁止: 内部依存

以下はmockしてはならない。実際の接続・実体を使うこと。

- データベース（testcontainers, in memory db等で実DB接続）
- 内部モジュール・内部サービス間の依存関係
- ファイルシステム（テスト用一時ディレクトリを使う）

### Skip制御: AI系API

AI API（Claude, OpenAI, Gemini等）はmockしない。ただし毎回呼び出すとコストがかかるため、環境変数でテスト実行をskipできるようにする。

```
RUN_EXPENSIVE_TESTS=1  # この環境変数が設定されている場合のみ実行
```

テスト内では skip 制御のみ行い、mock は使わない。

### 許可: 完全外部依存

以下のみmockを許可する。

- 外部ベンダーAPI（決済、クローリング、SMS送信等）
- サードパーティSaaS

## テスト記述ルール

### 日本語BDDスタイル (日本語レポジトリの場合)

describe/it は日本語で記述し、GIVEN / WHEN / THEN でネスト構造にする。

```typescript
describe('ユーザー登録', () => {
  describe('GIVEN: 有効なメールアドレス', () => {
    describe('WHEN: 登録APIを呼ぶ', () => {
      it('THEN: ユーザーが作成される', async () => {
        // テスト実装
      });
    });
  });

  describe('GIVEN: 既に登録済みのメールアドレス', () => {
    describe('WHEN: 登録APIを呼ぶ', () => {
      it('THEN: 409エラーが返る', async () => {
        // テスト実装
      });
    });
  });
});
```

### テスト対象

- 公開インターフェース（exported/public）のみテストする
- privateな関数や内部実装はテストしない

### 細粒度unitテストの扱い

- 実装中の確認用として一時的に作成してよい
- **最終成果物からは必ず削除する**
- 残すべきテストはbehavior（振る舞い）テストのみ

## BEHAVIORS.md

### 目的

計画時に実装する振る舞いをGIVEN/WHEN/THENで定義し、テストとの一貫性を担保する。

### 作成タイミング

planモードでExitPlanMode後、実装の最初のステップとして `.claude/BEHAVIORS.md` に作成する。

### 配置場所

`.claude/BEHAVIORS.md`（`.gitignore_global` で除外されるためmainにマージされない）

### フォーマット

publicインターフェース単位で見出しを切り、**正常系/異常系/境界値**のカテゴリで網羅的に列挙する。

```markdown
# BEHAVIORS

## <機能名> (<公開インターフェース>)

### 正常系
- GIVEN: <前提条件>
  AND: <追加の前提条件>
  WHEN: <操作>
  THEN: <期待結果>
  AND: <追加の期待結果>

### 異常系
- GIVEN: <異常な前提条件>
  WHEN: <操作>
  THEN: <エラー応答>

### 境界値
- GIVEN: <境界条件>
  WHEN: <操作>
  THEN: <期待結果>
```

サンプルは `assets/BEHAVIOURS.md` を参照。

### 作成時の網羅性チェック

各publicインターフェースに対して、以下の観点で振る舞いを列挙すること:

- 正常系（主要パスを少なくとも1つ以上）
- バリデーションエラー
- 認証・認可エラー（該当する場合）
- 存在しないリソースへのアクセス（該当する場合）
- 重複・競合
- 境界値（該当する場合）

### レビュー時の照合

レビュー時にbdd-checker agentがBEHAVIORS.mdの各項目とテストコードを照合し、以下を確認する:

- 定義したすべての振る舞いに対応するテストが存在するか
- テストのdescribe/it記述がBEHAVIORS.mdの定義と意味的に一致しているか
