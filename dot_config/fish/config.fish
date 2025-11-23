# Fish shell configuration

# Set Homebrew PATH based on OS
if test -x /opt/homebrew/bin/brew
    eval "$(/opt/homebrew/bin/brew shellenv)"
    fish_add_path /opt/homebrew/opt/libpq/bin
end

# Shell options
set fish_greeting # Disable greeting
set -g -x FZF_DEFAULT_COMMAND "fd . $HOME"
set -g -x SHELL (which fish)
set -x VISUAL nvim

# PATH configuration
fish_add_path $HOME/bin
fish_add_path $HOME/.local/share/aquaproj-aqua/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin
fish_add_path /opt/homebrew/opt/openjdk@11/bin
fish_add_path /usr/local/bin
fish_add_path /opt/homebrew/share/google-cloud-sdk/bin

# Abbreviations
abbr --add -- cdf 'cd (fd . $HOME --type d --hidden --exclude .git | fzf )'
abbr --add -- vd 'cd (fd . $HOME --type d --hidden --exclude .git | fzf ) && nvim .'
abbr --add -- vf 'fd . $HOME --type f --hidden --exclude .git | fzf | xargs nvim'
abbr --add -- zmf 'cd (fd . $HOME --type d --hidden --exclude .git | fzf) && zellij attach $(basename $(pwd)) || zellij -s $(basename $(pwd))'
abbr --add -- gwcd 'cd (git worktree list | awk '\''{print $1}'\'' | fzf)'
abbr --add -- gwrm 'git worktree remove (git worktree list | awk '\''{print $1}'\'' | fzf)'
abbr --add -- dot 'cd (chezmoi source-path); and vi .'
abbr --add -- dotc 'cd (chezmoi source-path); claude'
abbr --add -- dc 'docker compose'
abbr --add -- dcr 'docker compose run --rm'
abbr --add -- dce 'docker compose exec'
abbr --add -- cl 'claude'
abbr --add -- cld 'claude --dangerously-skip-permissions'
abbr --add -- clp 'claude --permission-mode plan'
abbr --add -- clap 'claude --append-system-prompt "$(cat ~/.claude/auto-plan-mode.txt)"'
abbr --add -- clapd 'claude --append-system-prompt "$(cat ~/.claude/auto-plan-mode.txt)" --dangerously-skip-permissions'
abbr --add -- lg 'lazygit'

# Aliases
alias vim nvim
alias vi nvim
alias claude '~/.claude/local/claude'
alias odaily 'vi (obsidian-cli print-default --path-only)/Daily/(date +%Y-%m-%d).md'

# Google Cloud SDK
if test -f "$HOME/google-cloud-sdk/path.fish.inc"
    . "$HOME/google-cloud-sdk/path.fish.inc"
end

# Initialize tools
direnv hook fish | source

# mise (asdf replacement)
if type -q mise
    mise activate fish | source
end

# Starship prompt
if type -q starship
    starship init fish | source
end

# Prevent Cursor to hang in shell command execution
source $(code --locate-shell-integration-path fish)

# antigravigy
fish_add_path $HOME/.antigravity/antigravity/bin

