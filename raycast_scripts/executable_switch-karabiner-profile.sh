#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Switch Karabiner Profile
# @raycast.mode silent
# @raycast.argument1 { "type": "dropdown", "placeholder": "Profile", "data": [{"title": "Default (ANSI)", "value": "Default profile"}, {"title": "JIS", "value": "JIS profile"}] }

# Optional parameters:
# @raycast.icon keyboard
# @raycast.packageName Karabiner-Elements

# Documentation:
# @raycast.description Switch Karabiner-Elements keyboard profile
# @raycast.author blackjiro
# @raycast.authorURL https://raycast.com/blackjiro

KARABINER_CLI="/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

if [ ! -f "$KARABINER_CLI" ]; then
    echo "Karabiner-Elements CLI not found"
    exit 1
fi

"$KARABINER_CLI" --select-profile "$1"
echo "Switched to: $1"
