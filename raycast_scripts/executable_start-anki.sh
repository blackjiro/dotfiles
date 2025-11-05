#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title start-anki
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.author blackjiro
# @raycast.authorURL https://raycast.com/blackjiro


# Ankiを開く
open -a "Anki"
sleep 2
aerospace move-node-to-workspace 1

# Obsidianを開く
open -a "Obsidian"
sleep 2
aerospace move-node-to-workspace 2

echo "Anki と Obsidian をスペース1で起動しました"
