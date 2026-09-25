hl.config({
	animations = {
		enabled = true,
	},
})

hl.curve("myBezier", {
	type = "bezier",
	points = {
		{ 0.05, 0.9 },
		{ 0.1, 1.05 },
	},
})

-- local anims = {
-- 	{ leaf = "windowsIn", speed = 7, style = "popin 80%" },
-- 	{ leaf = "windowsOut", speed = 7, style = "popin 80%" },
-- 	{ leaf = "windowsMove", speed = 4 },
-- 	{ leaf = "fade", speed = 4 },
-- 	{ leaf = "workspaces", speed = 8 },
-- 	{ leaf = "layers", speed = 8, style = "slide" },
-- }
--
-- for _, a in ipairs(anims) do
-- 	hl.animation({
-- 		leaf = a.leaf,
-- 		enabled = true,
-- 		speed = a.speed,
-- 		bezier = "fluent_decel",
-- 		style = a.style,
-- 	})
-- end

--
hl.animation({
	leaf = "windows",
	enabled = true,
	speed = 7,
	bezier = "myBezier",
})

hl.animation({
	leaf = "windowsOut",
	enabled = true,
	speed = 7,
	bezier = "default",
	style = "popin 80%",
})

hl.animation({
	leaf = "border",
	enabled = true,
	speed = 10,
	bezier = "default",
})

hl.animation({
	leaf = "borderangle",
	enabled = true,
	speed = 8,
	bezier = "default",
})

hl.animation({
	leaf = "fade",
	enabled = true,
	speed = 7,
	bezier = "default",
})

hl.animation({
	leaf = "workspaces",
	enabled = true,
	speed = 8,
	bezier = "default",
})
