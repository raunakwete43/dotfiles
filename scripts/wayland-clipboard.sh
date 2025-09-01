#!/usr/bin/env bash

cliphist list | wofi -S dmenu | cliphist decode | wl-copy
