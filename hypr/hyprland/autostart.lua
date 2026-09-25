hl.on("hyprland.start", function()
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("nm-applet")
	hl.exec_cmd("blueman-applet")
	hl.exec_cmd("/usr/libexec/hyprpolkitagent")
	hl.exec_cmd("swaync")
	hl.exec_cmd("sh ~/.config/hypr/scripts/waybar.sh")
	hl.exec_cmd("wl-paste --watch cliphist store")

	-- hl.exec_cmd(\"bash /home/manu/Downloads/scripts/headphone.sh\")

	hl.exec_cmd("xss-lock --transfer-sleep-lock -- hyprlock")

	hl.exec_cmd("bash /home/manu/.config/hypr/scripts/pixel_shift_timer.sh")

	-- hl.exec_cmd(\"/usr/bin/gnome-keyring-daemon --start --components=secrets,ssh\")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY")
	hl.exec_cmd("systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)

hl.exec_cmd("pgrep waybar || sh ~/.config/hypr/scripts/waybar.sh")

hl.exec_cmd("wl-paste --watch cliphist store")
