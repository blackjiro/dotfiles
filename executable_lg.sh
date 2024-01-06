#!/bin/bash
eval "$(/opt/homebrew/bin/brew shellenv)"
/bin/bash -c "rio --working-dir $(pwd) -e lazygit"
