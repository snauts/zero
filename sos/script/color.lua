local function Print(pos, str, colorName, z, body, shadow, fontset)
	local lo = color[colorName].lo
	local hi = color[colorName].hi
	return util.PrintGradient(pos, str, lo, hi, z, body, shadow, fontset)
end

color = {
	Print = Print,

	khaki = {
		lo = { r = 0.255, g = 0.230, b = 0.189 },
		hi = { r = 0.764, g = 0.690, b = 0.568 },
	},
	darkGray = {
		lo = { r = 0.15, g = 0.15, b = 0.15 },
		hi = { r = 0.25, g = 0.25, b = 0.25 },
	},
	b29 = {
		lo = { r = 0.764, g = 0.690, b = 0.568 },
		hi = { r = 0.4, g = 0.7, b = 0.9 },
	},
	moss = {
		lo = { r = 0.1, g = 0.2, b = 0.1 },
		hi = { r = 0.5, g = 0.7, b = 0.5 },
	},
	navy = {
		lo = { r = 0.1, g = 0.2, b = 0.3 },
		hi = { r = 0.3, g = 0.6, b = 0.9 },
	},
	gray = {
		lo = { r = 0.2, g = 0.2, b = 0.2 },
		hi = { r = 0.4, g = 0.4, b = 0.4 },
	},
	pink = {
		lo = { r = 0.6, g = 0.1, b = 0.6 },
		hi = { r = 1.0, g = 0.2, b = 1.0 },
	},
	cyan = {
		lo = { r = 0.0, g = 0.4, b = 0.6 },
		hi = { r = 0.0, g = 0.9, b = 1.0 },
	},
	green = {
		lo = { r = 0.0, g = 0.2, b = 0.0 },
		hi = { r = 0.2, g = 0.8, b = 0.0 },
	},
	red = {
		lo = { r = 0.3, g = 0.0, b = 0.0 },
		hi = { r = 1.0, g = 0.0, b = 0.0 },
	},
	orange = {
		lo = { r = 1.0, g = 0.3, b = 0.0 },
		hi = { r = 1.0, g = 1.0, b = 0.0 },
	},
}
