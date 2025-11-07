# Repository Guidelines

## Project Structure & Module Organization

- `bootstrap.sh` は新規 Mac を初期化する最上位エントリーポイントで、Homebrew と chezmoi の設定を一括適用します。
- `dot_*` で始まるファイルやディレクトリはワークステーションに配布される実ファイルです。特に `dot_config/` に各アプリ (例: `nvim`, `wezterm`, `zellij`) の設定、`dot_claude/` と `dot_codex/` にエージェント用スクリプトや設定があります。
- 秘密情報は `*.tmpl` または `private_*` ディレクトリに置き、実行時に chezmoi がマージします。公開ファイルにシークレットを書かないでください。
- 実行可能スクリプトは `executable_*` という命名で格納され、Raycast 用のものは `raycast_scripts/` にまとまっています。

## Build, Test, and Development Commands

- `./bootstrap.sh` : 新規環境向けの包括セットアップ。ローカル検証時は `DRY_RUN=1 ./bootstrap.sh` で副作用を抑えて確認します。
- `chezmoi apply` : カレントマシンに変更を適用。`chezmoi diff` とセットで使い、適用前に差分を確認してください。
- `brew bundle --file=dot_Brewfile.tmpl` : Homebrew パッケージの同期。必要なタップを含むため、`HOMEBREW_NO_AUTO_UPDATE=1` を付けて高速化できます。

## Coding Style & Naming Conventions

- dotfiles は基本的に 2 スペースインデント、Lua や TOML も同じ幅で統一します。Neovim Lua では `local` でスコープを閉じ、テーブル末尾にカンマを残すスタイルです。
- シェルスクリプトは `#!/usr/bin/env bash` をヘッダに置き、`set -euo pipefail` を必須化します。関数名は `snake_case`、Raycast スクリプトも同様です。
- ファイル命名は `dot_<target>`、秘密鍵は `private_<service>`、テンプレートは `.tmpl` 拡張子を守ってください。
- フォーマットは `stylua --config-path dot_config/nvim/stylua.toml`、`fish_indent`, `zellij fmt` など既存のツールを再利用します。

## Testing Guidelines

- dotfiles 変更後は `chezmoi doctor` でパスや権限の健全性を確認し、`chezmoi diff` が意図した差分のみであることを確認します。
- シェル/CLI スクリプトは `shellcheck raycast_scripts/executable_*.sh executable_*.sh` を実行し、警告ゼロを維持します。
- Neovim 設定は `nvim --headless "+Lazy! sync" +qa` でプラグイン解決を検査し、必要なら `:checkhealth` の結果をログに残してください。

## Commit & Pull Request Guidelines

- Git 履歴は命令形の短い英語文 (`Add Raycast script`, `Remove automatic ...`) で揃っています。同じ形式で 50 文字以内を目安にします。
- 1 つの論理変更につき 1 コミット。chezmoi 生成物とテンプレートを混在させないでください。
- PR 説明には (1) 目的、(2) 手動検証手順、(3) スクリーンショットまたはログ (必要な場合) を箇条書きで記載し、関連 Issue やチケットをリンクします。
- 機密情報が含まれないことを最後に再確認し、チーム通知用に `dot_codex/executable_notify.py` を用いて進捗を共有するとレビューが迅速になります。

## Security & Local Configuration Tips

- `.tmpl` で囲った値は `chezmoi apply --refresh-externals` 時にだけ解決されるため、ローカルで直接編集する際は `chezmoi edit --apply <path>` を使い履歴を残してください。
- SSH・クラウドキーは `dot_ssh/` や `dot_aws/` のテンプレートを通じて暗号化保管してください。誤って平文キーをコミットした場合は即座に履歴ごと削除し、キーをローテーションします。
- Raycast 連携や通知スクリプトを更新する場合、`private_Library/private_Application Support/superfile/` など private ツリーの依存に注意し、存在しないファイルを参照しないようガードを追加してください。
