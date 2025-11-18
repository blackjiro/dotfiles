#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Set Current Workspace Name
# @raycast.mode silent
# @raycast.argument1 { "type": "text", "placeholder": "Workspace Name" }

# Optional parameters:
# @raycast.icon 🏷️
# @raycast.packageName AeroSpace

# Documentation:
# @raycast.description Set name for current AeroSpace workspace
# @raycast.author blackjiro
# @raycast.authorURL https://raycast.com/blackjiro

# Check if argument is provided
if [ -z "$1" ]; then
    echo "Error: Workspace name is required"
    exit 1
fi

# Set workspace name
$HOME/.local/bin/workspace-name set current "$1"

# Show success notification
echo "Workspace name set to: $1"
