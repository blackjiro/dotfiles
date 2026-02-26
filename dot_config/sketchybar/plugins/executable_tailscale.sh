#!/bin/bash

STATE=$(/usr/local/bin/tailscale status --json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('BackendState',''))" 2>/dev/null)

case "$STATE" in
    Running)
        sketchybar --set $NAME drawing=on icon.color=0xff44ff44
        ;;
    Stopped)
        sketchybar --set $NAME drawing=on icon.color=0x88ffffff
        ;;
    *)
        sketchybar --set $NAME drawing=off
        ;;
esac
