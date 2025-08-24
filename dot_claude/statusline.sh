#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract fields from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
style=$(echo "$input" | jq -r '.output_style.name')

# Get git information
git_branch=$(cd "$cwd" && git branch --show-current 2>/dev/null || echo '')
git_status=$(cd "$cwd" && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

# Get Python virtual environment
venv=${VIRTUAL_ENV##*/}

# Get ccusage information
ccusage_info=$(echo "$input" | bunx ccusage statusline 2>/dev/null || echo '')

# Build and output the status line
printf "\033[34m%s\033[0m" "$(basename "$cwd")"
[ -n "$git_branch" ] && printf " \033[90m%s\033[0m" "$git_branch"
[ "$git_status" -gt 0 ] && printf "\033[36m*\033[0m"
[ -n "$venv" ] && printf " \033[90m%s\033[0m" "$venv"
printf " \033[90m%s\033[0m" "$model"
[ -n "$ccusage_info" ] && printf " %s" "$ccusage_info"
printf " \033[90m[%s]\033[0m" "$style"

