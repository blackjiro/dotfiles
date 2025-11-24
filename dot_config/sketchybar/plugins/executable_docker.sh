#!/bin/bash

if /usr/local/bin/docker info > /dev/null 2>&1; then
    sketchybar --set $NAME drawing=on
else
    sketchybar --set $NAME drawing=off
fi
