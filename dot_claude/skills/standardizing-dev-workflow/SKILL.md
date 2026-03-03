---
name: standardizing-dev-workflow
description: aqua経由でtaskとlefthookを導入し、標準開発フローを構築・監査。worktreeやマルチサービス環境ではportlessによるポート競合解消もサポート。Use when setting up task/aqua/lefthook/portless, standardizing dev workflow, or when the user mentions "taskをセットアップ", "aquaでtaskを入れて", "lefthookを設定", "開発ワークフロー標準化", "git hooks設定", "Taskfile作成", "portless", "ポート競合", "worktreeで開発サーバー", "マルチサービス開発"。
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
- **portless**: Vercel Labs製のリバースプロキシ。`portless <name> <command>` でプロセスを `<name>.localhost:1355` にマッピング。worktree間のポート競合を解消
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

### Workflow 4: portless によるマルチサービス開発

worktree間のポート競合を解消し、名前ベースでサービスにアクセスできるようにする。

#### ステップ 1: portless のインストール確認

```bash
portless --version
# なければインストール
npm install -g portless
```

#### ステップ 2: Vite プロジェクトの PORT 環境変数対応（必須）

portless は子プロセスに `PORT` 環境変数でリッスンすべきポートを渡すが、**Vite はデフォルトでは `PORT` を読まない**。
また `pnpm dev` / `npx vite` 経由では portless のフラグ自動注入（`--port`）が効かないため、`vite.config.ts` への以下の追加が**必須**。
この設定がないと portless 経由で起動しても Vite が固定ポート（5173）で listen してしまい、名前ベースのルーティングが機能しない。

portless なしの環境でも壊れない（後方互換あり）。

```typescript
// vite.config.ts
export default defineConfig({
  server: {
    port: process.env.PORT ? parseInt(process.env.PORT) : 5173,
    strictPort: !!process.env.PORT,
    host: process.env.HOST || 'localhost',
  },
})
```

#### ステップ 3: Taskfile への `dev:portless` タスク生成

**単一サービス:**
```yaml
vars:
  WT_NAME:
    sh: basename $(pwd)

tasks:
  dev:portless:
    desc: portless経由で開発サーバー起動
    cmds:
      - portless {{.SERVICE_NAME}}.{{.WT_NAME}} npx vite
```

**モノレポ（複数サービス並列起動）:**
```yaml
vars:
  WT_NAME:
    sh: basename $(pwd)

tasks:
  dev:portless:
    desc: 全サービスをportless経由で並列起動
    cmds:
      - portless proxy start 2>/dev/null || true
      - task dev:portless:api & task dev:portless:widget & task dev:portless:admin & wait

  dev:portless:widget:
    env:
      VITE_API_BASE_URL: http://api.{{.WT_NAME}}.localhost:1355
    cmds:
      - portless widget.{{.WT_NAME}} pnpm --dir widget dev
```

#### ステップ 4: 環境変数の上書き（サービス間接続設定）

`.env.local` 生成ではなく Taskfile の `env` で直接渡す方式を推奨する。
`VITE_API_BASE_URL` 等をworktree名を含む動的URLに設定する。

#### ステップ 5: CORS 設定の提案（Cookie 認証使用時）

`admin.localhost` → `api.localhost` のようなフラットな命名では、ブラウザが異なるサイトと判定し `SameSite=lax` の Cookie が送信されない。
worktree名をサブドメインプレフィックスにする命名規則で回避する:

`widget.main.localhost:1355`, `api.main.localhost:1355`, `admin.main.localhost:1355`

`*.main.localhost` は同一サイトとして扱われ、Cookie が正しく送信される。
CORS の正規表現パターン例:

```
CORS_ADMIN_ORIGIN_REGEX=^http://admin(\.[a-z0-9-]+)*\.localhost:1355$
```

### Workflow 5: 既存リポジトリの監査

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
- [ ] マルチサービス/worktree開発時にdev:portlessタスクが定義されているか（任意）

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

### Example 4: portless を使ったマルチサービス開発

**Before（ポート固定）**:
```yaml
tasks:
  dev:widget:
    env:
      VITE_API_BASE_URL: http://localhost:3000
    cmds:
      - pnpm --dir widget dev --port 5173

  dev:api:
    cmds:
      - pnpm --dir api dev --port 3000
```

**After（portless 名前ベース）**:
```yaml
vars:
  WT_NAME:
    sh: basename $(pwd)

tasks:
  dev:portless:widget:
    env:
      VITE_API_BASE_URL: http://api.{{.WT_NAME}}.localhost:1355
    cmds:
      - portless widget.{{.WT_NAME}} pnpm --dir widget dev

  dev:portless:api:
    cmds:
      - portless api.{{.WT_NAME}} pnpm --dir api dev
```

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

**portlessが見つからない**:
```bash
npm install -g portless
```

**portlessでアクセスできない**:
`*.localhost` の名前解決を確認する。macOSではデフォルトで `*.localhost` は `127.0.0.1` に解決される。

## Reference

- [Task公式ドキュメント](https://taskfile.dev/)
- [lefthook公式ドキュメント](https://github.com/evilmartians/lefthook)
- [Aqua公式ドキュメント](https://aquaproj.github.io/)
- [portless 公式リポジトリ](https://github.com/vercel-labs/portless)
