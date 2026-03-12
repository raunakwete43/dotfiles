#!/usr/bin/env bash

# Cache directory for covers
CACHE="$HOME/.cache/waybar-media"
mkdir -p "$CACHE"

# Get player status
STATUS=$(playerctl status 2>/dev/null)

if [[ $? -ne 0 ]]; then
    echo '{"text": "", "tooltip": "No media"}'
    exit 0
fi

TITLE=$(playerctl metadata title)
ARTIST=$(playerctl metadata artist)
COVER=$(playerctl metadata mpris:artUrl)

ICON="$CACHE/cover.jpg"

# Download cover if changed
if [[ -n "$COVER" ]]; then
    if [[ "$COVER" == file://* ]]; then
        cp "${COVER#file://}" "$ICON" 2>/dev/null
    else
        curl -s "$COVER" -o "$ICON"
    fi
fi

# Playback icon
if [[ "$STATUS" == "Playing" ]]; then
    STATE="▶"
else
    STATE="⏸"
fi

echo "{\"text\": \"$STATE $ARTIST - $TITLE\", \"tooltip\": \"$ARTIST - $TITLE\", \"class\": \"$STATUS\", \"alt\": \"$ICON\"}"
