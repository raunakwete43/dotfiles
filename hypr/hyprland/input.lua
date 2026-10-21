hl.config({

	input = {
		-- repeat_rate = 50,
		-- repeat_delay = 300,
		numlock_by_default = true,
		left_handed = false,
		kb_layout = "us",
		follow_mouse = 1,
		-- accel_profile = "flat",
		accel_profile = "adaptive",

		touchpad = {
			disable_while_typing = true,
			natural_scroll = true,
		},
	},
	-- input = {
	-- 	accel_profile = "adaptive",
	-- 	-- sensitivity = 0.1,
	-- 	kb_layout = "us",
	-- 	follow_mouse = 1,
	--
	-- 	touchpad = {
	-- 		disable_while_typing = true,
	-- 		natural_scroll = true,
	-- 	},
	-- },
})

hl.device({
	name = "epic-mouse-v1",
	sensitivity = 0.5,
})
