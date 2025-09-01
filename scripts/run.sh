#!/bin/bash 

function run {
 if ! pgrep $1 ;
  then
    $@&
  fi
}

pkill dwmblocks &

run "xfce4-power-manager"
run "xfce4-clipman"
run "nm-applet"
run "volumeicon"
run "/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1"
run "/usr/bin/dunst -conf ~/.config/dunstrc"
picom &
sxhkd -c ~/.config/arco-chadwm/sxhkd/sxhkdrc &
xinput disable "ELAN1301:00 04F3:30EF Touchpad" &
xss-lock --transfer-sleep-lock -- /bin/betterlockscreen -l &

xrdb merge ~/.Xresources &
feh --bg-fill ~/Pictures/Wallpaper/wallpaperflare.com_wallpaper.jpg &
xset r rate 300 50 &

while type chadwm >/dev/null; do chadwm && continue || break; done
