#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract fields from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

# Get git information
git_branch=$(cd "$cwd" && git branch --show-current 2>/dev/null || echo '')
git_status=$(cd "$cwd" && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

# Get Python virtual environment
venv=${VIRTUAL_ENV##*/}

# Try to get ccusage information if all required fields are present
# Check if required fields exist before calling ccusage
has_required_fields=$(echo "$input" | jq -r 'has("session_id") and has("transcript_path") and has("cwd") and has("model") and .workspace.project_dir != null')

if [ "$has_required_fields" = "true" ]; then
    ccusage_info=$(echo "$input" | bunx ccusage statusline 2>/dev/null || echo '')
else
    ccusage_info=""
fi

# Build and output the status line
printf "\033[34m%s\033[0m" "$(basename "$cwd")"
[ -n "$git_branch" ] && printf " \033[90m%s\033[0m" "$git_branch"
[ "$git_status" -gt 0 ] && printf "\033[36m*\033[0m"
[ -n "$venv" ] && printf " \033[90m%s\033[0m" "$venv"
[ -n "$ccusage_info" ] && printf " %s" "$ccusage_info"

