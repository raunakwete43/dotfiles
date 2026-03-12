#!/usr/bin/env bash

SEARCH_DIR="$HOME"

query="$1"

# When launcher opens (empty input)
if [[ -z "$query" ]]; then
    exit 0
fi

# FAST indexed search if available
if command -v plocate >/dev/null; then
    plocate -i "$query" \
        | grep "^$SEARCH_DIR" \
        | head -150
else
    fd --type f \
       --hidden \
       --follow \
       --ignore-case \
       --exclude .git \
       --exclude node_modules \
       --exclude .cache \
       "$query" "$SEARCH_DIR"
fi

# When user selects entry
if [[ "$ROFI_RETV" == "1" ]]; then
    xdg-open "$query" >/dev/null 2>&1 &
fi
