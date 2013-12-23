local symbolPos = { x = -4, y = -8 }
local function Put(symbol, body, z, colorSet, fontSet)
	return color.Print(symbolPos, symbol, colorSet, z, body, 0.1, fontSet)
end

local function Add(parent, symbol, offset, colorSet, fontSet)
	fontSet = fontSet or util.defaultFontset
	local pos = vector.Add(actor.GetPos(parent), offset)
	local obj = { body = eapi.NewBody(gameWorld, pos), class = "letter" }
	obj.tileSet = Put(symbol, obj.body, parent.z, colorSet, fontSet)
	actor.Link(obj, parent)
	obj.offset = offset
	return obj
end

local function Rotate(obj, angle)
	local function RotateLetter(tile) util.RotateTile(tile, angle) end
	util.Map(RotateLetter, obj.tileSet)
end

local function RotateLeft(tile)
	util.AnimateRotation(tile, 1)
end

local function RotateRight(tile)
	util.AnimateRotation(tile, -1)
end

local function AnimateRotation()
	return math.random() > 0.5 and RotateLeft or RotateRight
end

local function Spin(obj, speed, angle)
	local function Do(tile) util.AnimateRotation(tile, speed, angle) end
	util.Map(Do, obj.tileSet)
end

local function FadeOut(duration)
	return function(tile)
		local color = util.SetColorAlpha(eapi.GetColor(tile), 0)
		eapi.AnimateColor(tile, eapi.ANIM_CLAMP, color, duration, 0)
	end
end

local function GetVelocity(child, force, spread)
	local vel = vector.Normalize(child.offset, force)
	return vector.Rotate(vel, math.random(-spread, spread))
end

local function Expire(obj, life)
	actor.DelayedDelete(obj, life)
	util.Map(FadeOut(life), obj.tileSet)
end

local function IfLetter(Do)
	return function(obj)
		if obj.class == "letter" then Do(obj) end
	end
end

local function Explode(parent, force, spread)
	local life = parent.life or 1.0
	local function Kick(child)
		actor.Unlink(child)
		Expire(child, life)
		util.Map(AnimateRotation(), child.tileSet)
		eapi.SetVel(child.body, GetVelocity(child, force, spread))
	end
	util.Map(IfLetter(Kick), util.CopyTable(parent.children))
	actor.Delete(parent)
end

local sparkOffset = { x = 0, y = 2 }
local function Sparks(parent, count, dir, jitter, spread, colorSet)
	local life = parent.life or 1.0
	local length = vector.Length(dir)
	local maxLen = length + jitter * length
	colorSet = colorSet or "orange"
	for i = 1, count, 1 do
		local vel = vector.Normalize(dir, math.random(length, maxLen))
		vel = vector.Rotate(vel, math.random(-spread, spread))
		local obj = Add(parent, ".", sparkOffset, colorSet)
		actor.Unlink(obj)
		eapi.SetVel(obj.body, vel)
		Expire(obj, life)
	end
end

local squeezeSize = { x = 8, y = 2 }
local squeezePos = { x = -4, y = -1 }

local function Squeeze(tile)
	eapi.AnimatePos(tile, eapi.ANIM_REVERSE_LOOP, squeezePos, 0.1, 0)
	eapi.AnimateSize(tile, eapi.ANIM_REVERSE_LOOP, squeezeSize, 0.1, 0)
end

local function Oscilate(obj)
	util.Map(Squeeze, obj.tileSet)
end

local function Flip(obj, axis)
	local function FlipTile(tile)
		eapi.FlipX(tile, axis[1])
		eapi.FlipY(tile, axis[2])
	end
	util.Map(FlipTile, obj.tileSet)
end

local function ArriveAngle(tile, life, angle)
	util.RotateTile(tile, angle)
	eapi.AnimateAngle(tile, eapi.ANIM_CLAMP, vector.null, 0, life, 0)
end

local function ArrivePos(tile, life, offset)
	local pos = eapi.GetPos(tile)
	eapi.SetPos(tile, vector.Add(pos, offset))
	eapi.AnimatePos(tile, eapi.ANIM_CLAMP, pos, life, 0)
end

local function ArriveColor(tile, life)
	local color = eapi.GetColor(tile)
	eapi.SetColor(tile, util.SetColorAlpha(color, 0.0))
	color = util.SetColorAlpha(color, 1.0)
	eapi.AnimateColor(tile, eapi.ANIM_CLAMP, color, life, 0)
end

local function Arrive(obj, life)
	local angle = math.random(0, 360)
	local offset = vector.Rnd(vector.null, 96)

	local function Home(tile)
		ArriveAngle(tile, life, angle)
		ArrivePos(tile, life, offset)
		ArriveColor(tile, life)
	end
	util.Map(Home, obj.tileSet)
end

local function Element(obj, symbol, offset, class)
	obj.offset = vector.Rotate(offset, obj.angle)
	actor.MakeShape(obj, actor.BoxAtPos(obj.offset, 3), class)
	local subObj = letter.Add(obj, symbol, obj.offset, obj.colorSet)
	letter.Rotate(subObj, obj.angle)
	return subObj
end

local function SimpleExplode(obj)
	letter.Explode(obj, 64, 60)
end

local function IsHarm(obj)
	return obj.class == "Mob" or obj.class == "Bullet"
end

local function Obliterate(obj)
	if not obj.destroyed and IsHarm(obj) then
		local function Kick(child)
			actor.Unlink(child)
			Expire(child, 1.0)
			util.Map(AnimateRotation(), child.tileSet)
		end
		util.Map(IfLetter(Kick), util.CopyTable(obj.children))
		actor.Delete(obj)
	end
end

letter = {
	Add = Add,
	Flip = Flip,
	Spin = Spin,
	Arrive = Arrive,
	Expire = Expire,
	Rotate = Rotate,
	Sparks = Sparks,
	Explode = Explode,
	Element = Element,
	Oscilate = Oscilate,
	Obliterate = Obliterate,
	SimpleExplode = SimpleExplode,
}
