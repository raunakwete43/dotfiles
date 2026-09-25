hl.monitor({
	output = "eDP-1",
	mode = "2880x1800@120",
	position = "0x0",
	scale = 1.5,
	bitdepth = 10,
	vrr = 3,
	supports_hdr = 0,
})

-- hl.monitor({
-- 	output = "eDP-1",
-- 	mode = "2880x1800@60",
-- 	position = "0x0",
-- 	scale = 1.5,
-- 	bitdepth = 10,
-- })

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})
