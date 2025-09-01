#!/bin/bash

powermenu ()
{
  options="󰍃 Logout\n Lock\n Suspend\n Poweroff\n Reboot\n󰜺 Cancel"
  selected=$(echo -e $options | dmenu -i -nb '#191919' -nf '#fea63c' -sb '#fea63c' -sf '#191919' -fn 'JetBrainsMono Nerd Font:bold:pixelsize=18')
  if [[ $selected = "󰍃 Logout" ]]; then
    loginctl kill-session self
  elif [[ $selected = " Lock" ]]; then
    betterlockscreen -l
  elif [[ $selected = " Suspend" ]]; then
    systemctl suspend
 elif [[ $selected = " Poweroff" ]]; then
    systemctl poweroff
 elif [[ $selected = " Reboot" ]]; then
    systemctl reboot
 elif [[ $selected = "󰜺 Cancel" ]]; then
    return
  fi
}

powermenu
