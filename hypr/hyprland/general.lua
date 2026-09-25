hl.config({
	general = {
		gaps_in = 3,
		gaps_out = 5,

		border_size = 2,

		col = {
			active_border = {
				colors = {
					"rgba(f5e0dcee)",
					"rgba(b4befeee)",
				},
				angle = 45,
			},

			inactive_border = "rgba(595959aa)",
		},

		resize_on_border = true,

		allow_tearing = true,

		layout = "dwindle",
	},
})

hl.config({
	decoration = {
		rounding = 10,

		-- Change transparency of focused and unfocused windows
		active_opacity = 1.0,
		inactive_opacity = 1.0,

		shadow = {
			enabled = false,
		},

		blur = {
			enabled = false,
			size = 3,
			passes = 1,

			vibrancy = 0.1696,
		},
	},
})

hl.config({
	xwayland = {
		use_nearest_neighbor = false,
		force_zero_scaling = false,
		create_abstract_socket = true,
	},

	cursor = {
		no_hardware_cursors = 0,
		enable_hyprcursor = true,
		use_cpu_buffer = 0,
		sync_gsettings_theme = true,
	},

	misc = {
		vrr = 2,
		disable_hyprland_guiutils_check = true,
		enable_swallow = true,
		swallow_regex = "^(Alacritty|kitty|foot|wezterm|otter-term)$",
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		focus_on_activate = true,
		animate_manual_resizes = true,
		animate_mouse_windowdragging = true,
		mouse_move_enables_dpms = false,
		key_press_enables_dpms = true,
		middle_click_paste = false,
	},
})

hl.window_rule({
	match = {
		pin = 1,
	},

	border_color = "rgba(afc6ffAA) rgba(afc6ff77)",
})
