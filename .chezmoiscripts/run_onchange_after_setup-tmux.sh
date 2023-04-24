#!/usr/bin/env bash

# Install tmux plugin manager
echo "Installing tmux plugin manager"
if [ ! -d ~/.config/tmux/plugins/tpm ]; then
	git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
fi
