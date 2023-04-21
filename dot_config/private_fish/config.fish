eval (/opt/homebrew/bin/brew shellenv)


set -g -x fish_greeting ''
set -g -x FZF_DEFAULT_COMMAND "fd . $HOME"

# path
fish_add_path $HOME/.n/bin
fish_add_path $HOME/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin
fish_add_path /opt/homebrew/opt/openjdk@11/bin
fish_add_path /usr/local/bin

# abbrs
abbr uscpa tmuxinator start uscpa
abbr vf "fd . $HOME --type f --hidden --exclude .git | fzf | xargs nvim"
abbr vd "cd (fd . $HOME --type d --hidden --exclude .git | fzf ) && nvim ."

# Setting rbenv
status --is-interactive; and rbenv init - fish | source

# Setting go (homebrew)
set -x GOPATH $HOME/go
set -x GOROOT "$(brew --prefix golang)/libexec"
fish_add_path $GOPATH/bin
fish_add_path $GOROOT/bin

# Setting pyenv
alias brew="env PATH=(string replace (pyenv root)/shims '' \"\$PATH\") brew"
set -x PYENV_ROOT $HOME/.pyenv
fish_add_path $PYENV_ROOT/bin
pyenv init - | source

# Setting n
set -x N_PREFIX $HOME/.n
fish_add_path $N_PREFIX/n/bin


# alias awsume=". awsume"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/hirokigoto/google-cloud-sdk/path.fish.inc' ]
    . '/Users/hirokigoto/google-cloud-sdk/path.fish.inc'
end


source /opt/homebrew/opt/asdf/libexec/asdf.fish

set -x VISUAL nvim
alias vim="nvim"
alias vi="nvim"
