-- Suppresses maximization requests coming from applications for all windows.
hl.window_rule({
	match = {
		class = ".*",
	},
	suppress_event = "maximize",
})

-- Disable blur for empty class/title
hl.window_rule({
	match = {
		class = "^()$",
		title = "^()$",
	},
	no_blur = true,
})

-- Browsers → workspace 2
-- hl.window_rule({
-- 	match = {
-- 		class = "(.*)(browser)$",
-- 	},
-- 	workspace = "2 silent",
-- })

-- App launcher
hl.window_rule({
	match = {
		class = "^(xfce4-appfinder)$",
	},
	float = true,
})

hl.window_rule({
	match = {
		class = "^(xfce4-appfinder)$",
	},
	center = true,
})

-- Calculator
hl.window_rule({
	match = {
		class = "org.gnome.Calculator",
	},
	float = true,
})

hl.window_rule({
	match = {
		class = "org.gnome.Calculator",
	},
	center = true,
})

-- Ristretto
hl.window_rule({
	match = {
		class = "^(ristretto)$",
	},
	float = true,
})

hl.window_rule({
	match = {
		class = "^(ristretto)$",
	},
	center = true,
})

-- VLC Sub
hl.window_rule({
	match = {
		class = "^vlc$",
		initial_title = "^VLSub",
	},
	float = true,
})

hl.window_rule({
	match = {
		class = "^vlc$",
		initial_title = "^VLSub",
	},
	center = true,
})

-- Rofi
hl.window_rule({
	match = {
		class = "^(Rofi)$",
	},
	float = true,
})

hl.window_rule({
	match = {
		class = "^(Rofi)$",
	},
	center = true,
})

-- File managers → workspace 3
hl.window_rule({
	match = {
		class = "^(thunar)$",
	},
	workspace = "3 silent",
})

hl.window_rule({
	match = {
		class = "^(yazi)$",
	},
	workspace = "3 silent",
})

-- Media → workspace 5
hl.window_rule({
	match = {
		class = "^(vlc)$",
	},
	workspace = "5 silent",
})

hl.window_rule({
	match = {
		class = "^(mpv)$",
	},
	workspace = "5 silent",
})

-- Coding → workspace 4
hl.window_rule({
	match = {
		class = "^(dev.zed.Zed)$",
	},
	workspace = "4 silent",
})

hl.window_rule({
	match = {
		class = "^(Code)(.*)$",
	},
	workspace = "4 silent",
})

hl.window_rule({
	match = {
		class = "^(code)(.*)$",
	},
	workspace = "4 silent",
})

-- qBittorrent → workspace 9
hl.window_rule({
	match = {
		class = "^(org.qbittorrent)(.*)$",
	},
	workspace = "9 silent",
})

hl.window_rule({
	match = {
		class = "^(org.qbittorrent)(.*)$",
	},
	float = true,
})

hl.window_rule({
	match = {
		class = "^(org.qbittorrent)(.*)$",
	},
	center = true,
})
