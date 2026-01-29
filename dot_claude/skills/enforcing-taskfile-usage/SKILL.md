---
name: enforcing-taskfile-usage
description: Taskfileがあるプロジェクトで開発コマンド（dev, build, lint, test等）を実行する際に、必ずtaskコマンド経由で実行することを強制する。pnpm dev、npm run、npx、python -m等の直接実行を防止。taskfile、task コマンド、開発サーバー起動、ビルド、リント、テスト実行時に使用。
---

# Enforcing Taskfile Usage

## Quick Start

プロジェクトで開発コマンドを実行する前に、必ず以下を確認する:

1. `Taskfile.yml` が存在するか確認
2. 存在する場合、`task --list` で利用可能なタスクを確認
3. **必ず `task` コマンド経由で実行**

```bash
# ✅ 正しい
task dev
task lp:dev
task build
task lint
task test

# ❌ 禁止（Taskfile.ymlが存在するプロジェクトでは絶対に使わない）
pnpm dev
npm run dev
npx vite dev
python -m pytest
go test ./...
```

## Key Concepts

- **Taskfileが存在するプロジェクトでは、task コマンドが唯一のエントリポイント**
- task コマンドは依存タスク（install等）を自動実行し、正しい作業ディレクトリで動作する
- 直接コマンドは依存関係をスキップし、環境不整合を起こす原因になる
- モノレポでは `task <namespace>:<task>` 形式（例: `task lp:dev`, `task api:test`）

## Workflows

### Workflow 1: 開発サーバー起動

```bash
# 1. Taskfile.yml の存在確認
ls Taskfile.yml

# 2. 利用可能なタスク確認
task --list

# 3. 適切なタスクを実行
task dev          # 全体
task lp:dev       # 特定コンポーネント
task widget:dev   # 特定コンポーネント
```

### Workflow 2: モノレポでの特定コンポーネント操作

```bash
# ルートの Taskfile.yml が includes で子プロジェクトを定義している場合
task --list              # namespace付きタスク一覧を確認
task api:dev             # API開発サーバー
task admin:build         # Admin ビルド
task widget:test         # Widget テスト
```

### Workflow 3: CI/ビルド系コマンド

```bash
task lint                # リント
task lint:fix            # リント + 自動修正
task format              # フォーマット
task format:check        # フォーマットチェック
task test                # テスト
task build               # ビルド
task ci                  # CI全チェック
```

## 判定ルール

### task を使うべき場合

以下のすべてを満たす場合、`task` コマンド経由で実行する:

1. カレントディレクトリまたは親ディレクトリに `Taskfile.yml` が存在する
2. 実行しようとしている操作が Taskfile のタスクとして定義されている

### task を使わなくてよい場合

- `Taskfile.yml` が存在しないプロジェクト
- Taskfile に定義されていない一時的な操作（例: `git status`, `ls`）
- Taskfile 自体の編集・デバッグ

## Error Handling

**`task: command not found`**:
```bash
# aqua経由でインストール
aqua install
# または PATH確認
export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"
```

**`task: Task "xxx" does not exist`**:
```bash
# タスク一覧を確認
task --list
```

**バックグラウンド実行で `interactive: true` のタスクが即終了する場合**:
```bash
# task --list でコマンド内容を確認し、内部コマンドを直接実行
# ただし、まず task 経由での実行を試みること
```
