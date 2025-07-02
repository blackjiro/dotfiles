#!/bin/bash

# Claude Code terminal notifier script
# Reads JSON from stdin and sends notification with branch info

# Read stdin
input=$(cat)

# Get current git branch and repository name
branch=$(git branch --show-current 2>/dev/null || echo "unknown")
repo=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" || echo "unknown")

# Create message with repo and branch info
message="Claude Code completed on $repo ($branch)"

# Send notification using terminal-notifier
terminal-notifier -title "Claude Code" -message "$message" -sound default