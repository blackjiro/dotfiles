#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Set Current Workspace Name
# @raycast.mode silent
# @raycast.argument1 { "type": "text", "placeholder": "Workspace Name (empty to clear)", "optional": true }

# Optional parameters:
# @raycast.icon 🏷️
# @raycast.packageName AeroSpace

# Documentation:
# @raycast.description Set name for current AeroSpace workspace
# @raycast.author blackjiro
# @raycast.authorURL https://raycast.com/blackjiro

# Set workspace name (or clear if empty)
if [ -z "$1" ]; then
    $HOME/.local/bin/workspace-name set current
    echo "Workspace name cleared"
else
    $HOME/.local/bin/workspace-name set current "$1"
    echo "Workspace name set to: $1"
fi
