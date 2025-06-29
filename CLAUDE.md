# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository managed by [chezmoi](https://www.chezmoi.io/). It contains configuration files for various development tools, shell environments, and Mac-specific utilities.

## Common Commands

### Chezmoi Operations
- Apply changes to home directory: `chezmoi apply`
- Apply with verbose output: `chezmoi apply -v`
- See what would change: `chezmoi diff`
- Add a file from home directory: `chezmoi add ~/path/to/file`
- Add a templated file: `chezmoi add --template ~/path/to/file`
- Edit source files: `chezmoi edit`
- Update from remote: `chezmoi update`

### Working with Templates
Files ending in `.tmpl` are chezmoi templates that support:
- Variable substitution: `{{ .chezmoi.hostname }}`
- 1Password integration: `{{ onepasswordDocument "uuid" }}` or `{{ onepasswordRead "op://vault/item/field" }}`

### Sensitive Information Handling
When adding sensitive files (SSH keys, API tokens, etc.):
1. Use 1Password integration as documented in TIPS.md
2. For documents: `op document create ~/path/to/file --tags chezmoi --title filename --vault dev`
3. Use the returned UUID in templates: `{{- onepasswordDocument "uuid" -}}`

### External File Management
For files modified by external applications (e.g., karabiner.json):
1. Copy to `symlinked/` directory
2. Create a symlink template pointing to the source
3. See TIPS.md for detailed karabiner example

## Repository Structure

- `dot_*` prefixes become `.` in the target (e.g., `dot_gitconfig` → `.gitconfig`)
- `private_*` prefixes set file permissions to 600
- `executable_*` prefixes make files executable
- `.tmpl` suffix indicates a chezmoi template file
- `symlink_*` prefixes create symbolic links

## Key Configurations

- **Neovim**: Full LazyVim-based configuration in `dot_config/nvim/`
- **Shell**: Fish shell configuration
- **Terminal Emulators**: Alacritty, Ghostty, WezTerm configurations
- **Window Manager**: Aerospace tiling window manager
- **Keyboard**: Karabiner-Elements for custom keyboard mappings
- **Development Tools**: Git, SSH, Starship prompt configurations

## Testing Changes

Before applying changes:
1. Preview changes: `chezmoi diff`
2. Apply to specific files only: `chezmoi apply ~/path/to/file`
3. Use verbose mode to debug: `chezmoi apply -v`

## Bootstrap Process

For new machines:
```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply blackjiro
```

## Claude-Specific Settings

This repository includes Claude Code configurations:
- Terminal notifications are configured via `terminal-notifier`
- Custom commands in `dot_claude/commands/`
- Settings allow Docker, Git, mise, and other development tools