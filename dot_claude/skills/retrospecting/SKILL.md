---
name: retrospecting
description: セッション終了前の振り返りを実施し、作業プロセスの改善点を発見・蓄積する。「振り返り」「retro」「改善」「ふりかえり」などのキーワードで使用。
---

# セッション振り返り（Retro）

## Quick Start

セッション終了前に `/retro` を実行して、作業プロセスの改善点を発見・蓄積する。

1. 過去ログの確認（既知の問題の再発チェック）
2. 今セッションの振り返り（改善点のリストアップ）
3. 改善アクションの決定（ユーザーと対話）
4. 改善の実施
5. ログへの記録

## Key Concepts

### auto-reviewing との棲み分け

- **auto-reviewing**: コード品質のレビュー（バグ、設計、可読性）
- **retro（本スキル）**: 作業プロセスの改善（効率化、自動化、知見の蓄積）

### 振り返りの4つの観点

1. **非効率だった作業フロー** — 環境構築の手順漏れ、依存関係の見落とし、セットアップのやり直し
2. **繰り返しパターン** — 毎回手動でやっている作業（skill/hookにできないか）
3. **環境・ツールの知見** — 特定の環境エラーへの解決策、ツールの設定ノウハウ
4. **ツール活用の気づき** — もっと早い方法があった、知らなかった機能

### 振り返り対象外（改善点としてリストアップしない）

- **テストで検知されたコードエラー** — テストが失敗→修正はTDDの正常フロー。実装上のミス（型エラー、構文エラー、プロパティ名の見落とし等）はテストの仕事であり、作業フローの問題ではない
- **通常のデバッグ作業** — 実装中の試行錯誤は開発の一部
- **コードレビュー指摘事項** — auto-reviewingの領域

### 改善アクションの種類

| 種類 | 用途 | 例 |
|------|------|-----|
| **hook** | 自動で防げるミス | npm install忘れ → PreToolUseで自動チェック |
| **skill** | 対話的な手順が必要なもの | 複雑なデプロイ手順のガイド |
| **command** | 既存コマンドの改善 | 引数追加、処理の効率化 |
| **CLAUDE.md** | Claudeの振る舞いに関する指示 | 特定パターンでの注意点 |

**原則: 既存の改善を優先** — 新規作成より既存のskill/command/hookの改善を先に検討する。

### 保存先の判断基準

| 条件 | 保存先 |
|------|--------|
| どのプロジェクトでも使える汎用的なもの | `~/.claude/`（global） |
| 特定プロジェクト固有のもの | プロジェクトローカル |

## Workflows

### Workflow 1: 振り返りの実行（メインフロー）

#### Step 1: 過去ログの確認

1. `~/.claude/retro-log.md` を読み込む（存在しなければスキップ）
2. 「未対応」「対応済み」のエントリを一覧表示する
3. 今セッションで同じ問題が再発していないか確認する
   - 再発していた場合: 対処が不十分だったことをユーザーに報告し、改善を再検討
   - 再発なし（対応済みエントリが3セッション以上再発なし）: 「解決確認済み」に更新提案

#### Step 2: 今セッションの振り返り

セッション中のやり取りを4つの観点で振り返り、改善点をリストアップする。

確認ポイント:
- やり直した作業はなかったか
- エラーが発生して調査に時間がかかったものはなかったか
- 手動で繰り返した操作はなかったか
- もっと効率的な方法はなかったか

リストアップした改善点をユーザーに提示し、認識が合っているか確認する。
ユーザーが気づいた改善点があれば追加する。

#### Step 3: 改善アクションの決定

各改善点について、ユーザーと対話しながら以下を決定する:

1. **既存の改善を優先チェック**
   - 既存のskill/command/hook/CLAUDE.mdで対応できないか確認
   - `~/.claude/skills/`, `~/.claude/commands/`, `~/.claude/hooks/` を確認
   - プロジェクトローカルの `.claude/` も確認
   - 既存を改善できる場合はそれを提案

2. **新規作成が必要な場合**
   - アクション種類（hook/skill/command/CLAUDE.md）を提案
   - 保存先（global/project-local）を提案

3. **対応タイミング**
   - 今すぐ実施するか、次回以降に回すか
   - 今すぐ実施しない場合は「未対応」としてログに記録

#### Step 4: 改善の実施

決定した改善を実施する:

- **hook追加/修正**: hookスクリプトを作成/修正し、settings.jsonのhooks設定を更新
- **skill作成/修正**: `skills/<name>/SKILL.md` を作成/修正
- **command作成/修正**: `commands/` 配下のmdファイルを作成/修正
- **CLAUDE.md更新**: 該当のCLAUDE.mdに指示を追記

#### Step 5: ログへの記録

`~/.claude/retro-log.md` に振り返り結果を追記する。

### Workflow 2: ログのメンテナンス

「解決確認済み」のエントリが溜まった場合:
1. 解決確認済みエントリの一覧を表示
2. ユーザーに削除してよいか確認
3. 確認後、該当エントリを削除

## retro-log.md フォーマット

```markdown
## 2025-01-15 | project-name

- **問題**: npm install を忘れて依存エラーが発生
  - **対処**: PreToolUse hookで package.json変更時に自動チェック追加
  - **ステータス**: 対応済み

- **問題**: テスト実行前にビルドが必要だった
  - **対処**: CLAUDE.mdに注意事項を追記
  - **ステータス**: 解決確認済み
```

ステータスは3段階:
- **未対応** — 問題を認識したが対処していない
- **対応済み** — 改善を実施した
- **解決確認済み** — しばらく再発していないことを確認（削除可能）

## Examples

### 例1: hookによる自動化

```
ユーザー: /retro

Claude: 過去ログを確認します...
- [未対応] package.json変更後にnpm installを忘れてエラー（2回目）

今セッションの振り返り:
1. package.json に依存追加後、npm install を忘れてモジュール未解決エラーが発生
   → 前回と同じ問題が再発しています

改善案:
- PostToolUse hook で package.json の Edit/Write を検知し、npm install の実行を提案
- 保存先: ~/.claude/（全プロジェクト共通）

実施しますか？

ユーザー: はい

Claude: [hookスクリプト作成、settings.json更新、ログ記録]
```

### 例2: CLAUDE.md への知見追加

```
ユーザー: /retro

Claude: 今セッションの振り返り:
1. chezmoi managed なファイルを直接編集してしまい、chezmoi apply で上書きされた

改善案:
- CLAUDE.md に「chezmoi管理下のファイルは source directory で編集する」を追記
- 保存先: プロジェクトローカル（dotfilesリポジトリ固有）
```

### 例3: 問題なしの場合

```
ユーザー: /retro

Claude: 過去ログを確認します...
- [対応済み] npm install忘れ → hook追加済み。今回再発なし → 解決確認済みに更新します。

今セッションの振り返り:
特に改善点はありませんでした。
```

## Reference

### chezmoi管理について

globalの設定ファイル（`~/.claude/` 配下のskill, command, hook, settings.json等）はchezmoiで管理されている。
改善を実施する際は **`~/.claude/` を直接編集せず、chezmoi source directory（`~/.local/share/chezmoi/dot_claude/`）のファイルを編集** し、`chezmoi apply` で反映すること。

対応表:
| 実際のパス | chezmoi source |
|---|---|
| `~/.claude/settings.json` | `dot_claude/settings.json` |
| `~/.claude/skills/` | `dot_claude/skills/` |
| `~/.claude/commands/` | `dot_claude/commands/` |
| `~/.claude/hooks/` | `dot_claude/hooks/` |
| `~/.claude/CLAUDE.md` | `dot_claude/CLAUDE.md` |

### 関連ファイル
- `~/.claude/retro-log.md` — 振り返りログの蓄積先（chezmoi管理外）
- `dot_claude/settings.json` — hook設定の参照・更新先
- `dot_claude/hooks/` — hookスクリプトの配置先

### 関連スキル
- **auto-reviewing** — コード品質レビュー（retroとは棲み分け）
- **creating-skills** — 新規skill作成時に参照
