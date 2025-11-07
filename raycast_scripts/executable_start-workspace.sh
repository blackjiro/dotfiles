#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title !Start Workspace
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🚀
# @raycast.packageName Workspace

# Documentation:
# @raycast.author blackjiro
# @raycast.authorURL https://raycast.com/blackjiro


# Ghosttyを開いてzellijセッションを起動
open -n -a Ghostty --args -e zellij -n workspace_odaily

# ブラウザを開く
sleep 1
open -n /Applications/Google\ Chrome.app
