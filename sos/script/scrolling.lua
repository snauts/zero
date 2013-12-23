local textVel = { x = 0, y = -320 }
local darkGreen = { r = 0.0, g = 0.1, b = 0.0 }
local lessDarkGreen = { r = 0.1, g = 0.3, b = 0.1 }

local function Highlight(tileSet)
	local duration = 0.2 + 0.4 * math.random()
	local start = -duration + math.random() * (1.6 + duration)

	local function Flash(tile)
		eapi.AnimateColor(tile, eapi.ANIM_REVERSE_CLAMP,
				  lessDarkGreen, duration, start)
	end

	util.Map(Flash, tileSet)
end

local function RandomAxisOffset()
	return math.random(0, 2) - 1
end

local function Tremble(tileSet)
	local speed = 0.1 + 0.1 * math.random()
	local pos = { x = RandomAxisOffset(), y = RandomAxisOffset() }

	local function Jerk(tile)
		eapi.AnimatePos(tile, eapi.ANIM_REVERSE_LOOP, pos, speed, 0)
	end

	util.Map(Jerk, tileSet)
end

local function CoinFlip()
	return math.random() > 0.5
end

local function Emit(pos, life)
	local body = eapi.NewBody(gameWorld, pos)
	local char = string.char(math.random(33, 126))
	local tileSet = util.Print(vector.null, char, darkGreen, -100, body)
	if CoinFlip() then Highlight(tileSet) end
	if CoinFlip() then Tremble(tileSet) end
	util.DelayedDestroy(body, life)
	eapi.SetVel(body, textVel)
end

local function RowOfChars(y, life)
	for x = -400, 400, 12 do
		Emit({ x = x, y = y }, life)
	end
end

for y = -240, 224, 16 do
	RowOfChars(y, (256 + y) / 320.0)
end

local function EmitRows()
	eapi.AddTimer(staticBody, 0.05, EmitRows)
	RowOfChars(240, 1.6)
end
EmitRows()

function Print(pos, str, fontSet, colorName)
	return color.Print(pos, str, colorName, nil, nil, 0.1, fontSet)
end

function CenterRed(text, yOffset)
	local pos = util.TextCenter(text, util.defaultFontset)
	return Print(vector.Offset(pos, 0, yOffset), text, nil, "red")
end
