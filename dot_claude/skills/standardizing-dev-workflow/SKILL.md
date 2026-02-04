---
name: standardizing-dev-workflow
description: aqua経由でtaskとlefthookを導入し、標準開発フローを構築・監査。Use when setting up task/aqua/lefthook, standardizing dev workflow, or when the user mentions "taskをセットアップ", "aquaでtaskを入れて", "lefthookを設定", "開発ワークフロー標準化", "git hooks設定", "Taskfile作成"。
---

# Standardizing Dev Workflow

## Quick Start

aqua経由でtaskとlefthookを導入し、標準開発フローを構築する。

```bash
# 1. aqua初期化（なければ）
aqua init

# 2. task, lefthookを追加
aqua g -i go-task/task evilmartians/lefthook

# 3. インストール
aqua install

# 4. Taskfile初期化
task --init

# 5. lefthook初期化
lefthook install
```

## Key Concepts

- **aqua**: CLIツールのバージョン管理。プロジェクトごとにツールを固定
- **task**: YAMLベースのタスクランナー。Makefileの代替
- **lefthook**: 高速なGitフックマネージャー。pre-commit/pre-pushを管理
- **includes**: モノレポで複数Taskfileを連携
- **標準フロー**: format（pre-commit）→ lint（pre-push）

## Workflows

### Workflow 1: 初期セットアップ

```yaml
# aqua.yml
registries:
  - type: standard
    ref: v4.250.0

packages:
  - name: go-task/task@v3
  - name: evilmartians/lefthook@v1
```

```yaml
# Taskfile.yml
version: '3'

tasks:
  format:
    desc: Format code
    cmds:
      - prettier --write .

  lint:
    desc: Lint code
    cmds:
      - eslint .

  hooks:install:
    desc: Install git hooks
    cmds:
      - lefthook install
```

```yaml
# lefthook.yml
pre-commit:
  parallel: true
  commands:
    format:
      run: task format
      stage_fixed: true

pre-push:
  commands:
    lint:
      run: task lint
```

### Workflow 2: タスク追加

```yaml
# Taskfile.yml に追加
tasks:
  build:
    desc: Build the project
    cmds:
      - go build -o bin/app .

  test:
    desc: Run tests
    cmds:
      - go test ./...

  dev:
    desc: Run development server
    deps: [build]
    cmds:
      - ./bin/app serve
```

### Workflow 3: モノレポ対応

```yaml
# ルートのTaskfile.yml
version: '3'

includes:
  backend:
    taskfile: ./backend/Taskfile.yml
    dir: ./backend
  frontend:
    taskfile: ./frontend/Taskfile.yml
    dir: ./frontend
  shared:
    taskfile: ./shared/Taskfile.yml
    dir: ./shared
    optional: true

tasks:
  all:build:
    desc: Build all projects
    cmds:
      - task: backend:build
      - task: frontend:build

  all:lint:
    desc: Lint all projects
    cmds:
      - task: backend:lint
      - task: frontend:lint
```

呼び出し例:
- `task backend:build` - backendのbuildタスク
- `task frontend:dev` - frontendのdevタスク
- `task all:build` - 全プロジェクトのビルド

### Workflow 4: 既存リポジトリの監査

以下をチェックし、ガイドライン逸脱があれば修正提案する:

**監査チェックリスト**:
- [ ] aqua.ymlが存在するか
- [ ] Taskfile.ymlが存在するか
- [ ] lefthook.ymlが存在するか
- [ ] format/lintタスクが定義されているか
- [ ] README/CLAUDE.mdに直接コマンド（npm run, python -m等）がないか
- [ ] package.json scriptsがtask経由になっているか
- [ ] Makefileがtask経由になっているか
- [ ] .github/workflows内がtask経由になっているか

## Examples

### Example 1: README.mdの直接コマンドを修正

**Before**:
```markdown
## Development
npm run lint
npm run format
npm test
```

**After**:
```markdown
## Development
task lint
task format
task test
```

### Example 2: package.jsonからTaskfileへ移行

**Before (package.json)**:
```json
{
  "scripts": {
    "lint": "eslint .",
    "format": "prettier --write .",
    "test": "jest"
  }
}
```

**After (Taskfile.yml)**:
```yaml
version: '3'

tasks:
  lint:
    desc: Lint code
    cmds:
      - npx eslint .

  format:
    desc: Format code
    cmds:
      - npx prettier --write .

  test:
    desc: Run tests
    cmds:
      - npx jest
```

### Example 3: CI/CDをtask経由に変更

**Before (.github/workflows/ci.yml)**:
```yaml
- run: npm run lint
- run: npm test
```

**After**:
```yaml
- uses: aquaproj/aqua-installer@v4.0.4
  with:
    aqua_version: v2.36.0
- run: task lint
- run: task test
```

> **注意**: `aquaproj/aqua-installer`はメジャーバージョンタグ（@v3, @v4）が存在しない。
> 必ずフルバージョン（@v4.0.4等）を指定すること。
> 最新版は `gh api repos/aquaproj/aqua-installer/releases/latest --jq '.tag_name'` で確認。

## includeオプション一覧

| オプション | 説明 |
|-----------|------|
| `taskfile` | サブTaskfileのパス |
| `dir` | タスク実行時の作業ディレクトリ（**必須**） |
| `optional: true` | Taskfileがなくてもエラーにしない |
| `aliases` | namespaceの別名（例: `[api]`） |
| `vars` | サブTaskfileへの変数渡し |
| `flatten: true` | namespaceなしで呼び出し可能 |

## 重要な注意事項

### node_modules内コマンドの呼び出し

Taskfile.ymlでnode_modules/.bin内のコマンド（vitest, eslint, prettier等）を呼び出す際は、
**必ず`npx`経由で実行する**こと。直接呼び出すとCI環境でPATHが通らずエラーになる。

```yaml
# ❌ NG - PATHが通らない環境でエラー
cmds:
  - vitest

# ✅ OK - npx経由で実行
cmds:
  - npx vitest
```

### installタスクをdepsとして使用

主要なタスク（dev, build, test等）には`install`タスクを依存関係として設定し、
依存関係のインストールを自動化する：

```yaml
tasks:
  install:
    desc: 依存関係インストール
    cmds:
      - npm install
    sources:
      - package.json
      - package-lock.json
    generates:
      - node_modules/.package-lock.json

  dev:
    desc: 開発サーバー起動
    deps: [install]
    cmds:
      - npm run dev
```

`sources`と`generates`を設定することで、package.jsonが変更されていない場合は
インストールをスキップして効率的に動作する。

## Error Handling

**taskコマンドが見つからない**:
```bash
export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"
aqua install
```

**lefthookが動作しない**:
```bash
lefthook install  # hookを再インストール
```

**Taskfile構文エラー**:
```bash
task --list  # エラーがあれば表示される
```

## Reference

- [Task公式ドキュメント](https://taskfile.dev/)
- [lefthook公式ドキュメント](https://github.com/evilmartians/lefthook)
- [Aqua公式ドキュメント](https://aquaproj.github.io/)
