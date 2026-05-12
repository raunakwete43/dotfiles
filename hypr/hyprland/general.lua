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

		allow_tearing = false,

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

hl.window_rule({
	match = {
		pin = 1,
	},

	border_color = "rgba(afc6ffAA) rgba(afc6ff77)",
})
