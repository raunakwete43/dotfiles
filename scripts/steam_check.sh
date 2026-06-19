#!/bin/bash

# Check if Steam is already running
if pgrep -x "steam" > /dev/null; then
    echo "Steam is already running."
else
    echo "Steam is not running. Starting Steam..."
    
    # Start Steam in background
    nohup steam > /dev/null 2>&1 &
fi
