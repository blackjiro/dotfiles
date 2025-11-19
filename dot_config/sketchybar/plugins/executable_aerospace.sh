#!/usr/bin/env bash

WORKSPACE_NAME_CMD="$HOME/.local/bin/workspace-name"

sid="$1"
NAME_TEXT=$("$WORKSPACE_NAME_CMD" get "$sid" 2>/dev/null || echo "$sid")

if [ "$NAME_TEXT" != "$sid" ]; then
  LABEL="$sid:$NAME_TEXT"
else
  LABEL="$sid"
fi

if [ "$sid" = "$FOCUSED_WORKSPACE" ]; then
  sketchybar --set "space.$sid" label="$LABEL" background.drawing=on
else
  sketchybar --set "space.$sid" label="$LABEL" background.drawing=off
fi
