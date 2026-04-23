#!/usr/bin/env bash

SESSION="default"

tmux new-session -d -s $SESSION -n "btop" "btop"
tmux new-window -t $SESSION:2 -n "amdgpu_top" "amdgpu_top"

tmux new-window -t $SESSION:3 -n "watch"
tmux send-keys -t $SESSION:3 "watch -n 1 'sensors | grep -E \"PPT|Tctl\"; sensors | grep RPM'" C-m
tmux split-window -v -t $SESSION:3
tmux send-keys -t $SESSION:3.2 "watch -n 1 'cat /sys/class/drm/card1/device/pp_dpm_sclk'" C-m

tmux new-window -t $SESSION:4 -n "scripts" "cd ~/Downloads/scripts; fish"
tmux new-window -t $SESSION:5  "fish"

if [ -z "$TMUX" ]; then
  tmux attach-session -t $SESSION
fi
