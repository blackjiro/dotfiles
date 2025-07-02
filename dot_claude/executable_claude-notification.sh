#!/bin/bash

# Claude Code notification hook script
# Reads JSON from stdin and sends notification with extracted title and message

# Read stdin
input=$(cat)

# Extract title and message using jq
title=$(echo "$input" | jq -r '.title // "Claude Code"')
message=$(echo "$input" | jq -r '.message // "Notification"')

# Get current git branch and repository name for context
branch=$(git branch --show-current 2>/dev/null || echo "unknown")
repo=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" || echo "unknown")

# Add repo and branch info to the message
enhanced_message="$message [$repo ($branch)]"

# Send notification using terminal-notifier
terminal-notifier -title "$title" -message "$enhanced_message" -sound default