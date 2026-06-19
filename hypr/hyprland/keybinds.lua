-- Set programs that you use
local terminal = "kitty"
local fileManager = "thunar"
local menu = "bash ~/.config/rofi/launchers/type-1/launcher.sh"
local logout = "bash ~/.config/rofi/scripts/powermenu_wayland"
local clipboard = "bash ~/Downloads/scripts/wayland-clipboard.sh"
local touchpad = "bash ~/Downloads/scripts/touchpad_hypr.sh"
local browser = "thorium-browser-avx2"
local private_browser = "brave --incognito"
local high_res = "bash ~/.config/hypr/scripts/resolution.sh"

-- Basic
hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + ALT + D", hl.dsp.exec_cmd(high_res))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + X", hl.dsp.exec_cmd(logout))
hl.bind("SUPER + SHIFT + Return", hl.dsp.exec_cmd(fileManager))
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + R", hl.dsp.exec_cmd(menu))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + T", hl.dsp.layout("togglesplit"))
hl.bind(
	"SUPER + F",
	hl.dsp.window.fullscreen({
		mode = "maximized",
		action = "toggle",
	})
)
hl.bind("SUPER + C", hl.dsp.window.center())

-- Resize windows
hl.bind(
	"SUPER + SHIFT + Right",
	hl.dsp.window.resize({
		x = 30,
		y = 0,
		relative = true,
	}),
	{ repeating = true }
)

hl.bind(
	"SUPER + SHIFT + Left",
	hl.dsp.window.resize({
		x = -30,
		y = 0,
		relative = true,
	}),
	{ repeating = true }
)

hl.bind(
	"SUPER + SHIFT + Up",
	hl.dsp.window.resize({
		x = 0,
		y = -30,
		relative = true,
	}),
	{ repeating = true }
)

hl.bind(
	"SUPER + SHIFT + Down",
	hl.dsp.window.resize({
		x = 0,
		y = 30,
		relative = true,
	}),
	{ repeating = true }
)

-- Move focus with mainMod + arrow keys
hl.bind("SUPER + Left", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + Right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + Up", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + Down", hl.dsp.focus({ direction = "d" }))

hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "d" }))

-- Move focused window around the current workspace
hl.bind("SUPER + CTRL + Left", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + CTRL + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + CTRL + Up", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + CTRL + Down", hl.dsp.window.move({ direction = "d" }))

-- Switch workspaces with mainMod + [0-9]
for i = 1, 9 do
	hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = tostring(i) }))
end

hl.bind("SUPER + 0", hl.dsp.focus({ workspace = "10" }))

-- Move active window to workspace
for i = 1, 9 do
	hl.bind(
		"SUPER + SHIFT + " .. i,
		hl.dsp.window.move({
			workspace = tostring(i),
			follow = false,
		})
	)
end

hl.bind(
	"SUPER + SHIFT + 0",
	hl.dsp.window.move({
		workspace = "10",
		follow = false,
	})
)

-- Special workspace
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))

hl.bind(
	"SUPER + SHIFT + S",
	hl.dsp.window.move({
		workspace = "special:magic",
		follow = false,
	})
)

hl.bind("ALT + Tab", hl.dsp.window.cycle_next())

hl.bind(
	"ALT + SHIFT + Tab",
	hl.dsp.window.cycle_next({
		next = false,
	})
)

hl.bind(
	"ALT + Tab",
	hl.dsp.window.alter_zorder({
		mode = "top",
	})
)

-- Toggle previous workspace
hl.bind("SUPER + Tab", hl.dsp.focus({ workspace = "previous" }))

-- Scroll through workspaces
hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))

hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mouse
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })

hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media shortcuts
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"),
	{ locked = true, repeating = true }
)

hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"),
	{ locked = true, repeating = true }
)

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })

-- Apps
hl.bind("SUPER + W", hl.dsp.exec_cmd(browser))
hl.bind("SUPER + SHIFT + W", hl.dsp.exec_cmd(private_browser))
hl.bind("SUPER + D", hl.dsp.exec_cmd("xfce4-appfinder"))
hl.bind("SUPER + CTRL + P", hl.dsp.exec_cmd(clipboard))
hl.bind("XF86TouchpadToggle", hl.dsp.exec_cmd(touchpad))

-- Screenshot
hl.bind("SUPER + Print", hl.dsp.exec_cmd("hyprshot -m window -o ~/Pictures/Screenshots/"))

hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output -o ~/Pictures/Screenshots/"))

hl.bind("SHIFT + CTRL + S", hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots/"))

-- Zoom
hl.bind(
	"SUPER + SHIFT + equal",
	hl.dsp.exec_cmd(
		"hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 1.1}')"
	),
	{ repeating = true }
)

hl.bind(
	"SUPER + SHIFT + minus",
	hl.dsp.exec_cmd(
		"hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 0.9}')"
	),
	{ repeating = true }
)

hl.bind("SUPER + equal", hl.dsp.exec_cmd("hyprctl -q keyword cursor:zoom_factor 1"))

hl.bind(
	"SUPER + SHIFT + mouse_down",
	hl.dsp.exec_cmd(
		"hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 1.1}')"
	)
)

hl.bind(
	"SUPER + SHIFT + mouse_up",
	hl.dsp.exec_cmd(
		"hyprctl -q keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor | awk '/^float.*/ {print $2 * 0.9}')"
	)
)

hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))

-- Idle inhibitor
hl.bind(
	"SUPER + I",
	hl.dsp.exec_cmd(
		[[sh -c 'pgrep hypridle >/dev/null && { pkill hypridle; notify-send "󰒳 Stay Awake ON"; } || { hypridle & notify-send "󰒲 Stay Awake OFF"; }']]
	)
)
