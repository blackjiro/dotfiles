#!/usr/bin/env bash

WORKSPACE_NAME_CMD="$HOME/.local/bin/workspace-name"

# Get current focused workspace from environment variable set by aerospace
WORKSPACE="${FOCUSED_WORKSPACE:-1}"

# Get the workspace name (returns number if not set)
if [[ -x "$WORKSPACE_NAME_CMD" ]]; then
    NAME=$("$WORKSPACE_NAME_CMD" get "$WORKSPACE" 2>/dev/null || echo "$WORKSPACE")
else
    NAME="$WORKSPACE"
fi

# Update sketchybar item
sketchybar --set workspace_name label="$NAME"
