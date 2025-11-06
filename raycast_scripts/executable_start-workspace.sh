#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Start Workspace
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🚀
# @raycast.packageName Workspace
# @raycast.argument1 { "type": "text", "placeholder": "Workspace name" }

# Documentation:
# @raycast.author blackjiro
# @raycast.authorURL https://raycast.com/blackjiro

WORKSPACE_NAME="$1"

# Ghosttyを開いてzellijセッションを起動
open -n -a Ghostty --args -e zellij -s "$WORKSPACE_NAME"

# ブラウザを開く
sleep 1
open -n /Applications/Google\ Chrome.app
