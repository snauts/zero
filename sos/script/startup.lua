dofile("script/color.lua")

dofile("script/scrolling.lua")

Print({ x = -64, y = 128 }, "Zer", util.bigFontset, "green")
Print({ x = 32, y = 128 }, "o", util.bigFontset, "red")

local function ColorAdjust(x)
	return x + 0.25 * (1 - x)
end

local function Blink(tileSet)
	local function Highlight(tile)
		color = util.Map(ColorAdjust, eapi.GetColor(tile))
		eapi.AnimateColor(tile, eapi.ANIM_REVERSE_LOOP, color, 0.2, 0)
	end
	util.Map(Highlight, tileSet)
end

CenterRed("There is no victory.", 128)

Blink(CenterRed("Press \"X\" to start game!", -208))

local function Start() util.Goto("game") end

input.Bind("Shoot", false, util.KeyDown(Start))

