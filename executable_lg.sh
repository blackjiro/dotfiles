#!/bin/bash
eval "$(/opt/homebrew/bin/brew shellenv)"
alacritty --working-directory $(pwd) -e lazygit
