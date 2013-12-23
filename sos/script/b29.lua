local function Engine(obj, offset)
	local function Element(symbol, subOffset, class)
		local pos = vector.Add(offset, subOffset)
		return letter.Element(obj, symbol, pos, class)
	end
	local propeller = Element("|", { x = -10, y = 0 }, "Scorer")
	obj.propellers[#obj.propellers + 1] = propeller
	letter.Oscilate(propeller)
	Element("{", { x = -4, y = 0 })
	Element("B", { x = 12, y = 0 })
	Element("2", { x = 20, y = 0 })
	Element("9", { x = 28, y = 0 })
	Element("/", { x = 2, y = 12 })
	Element("\\", { x = 2, y = -12 })
	for i = 1, 4, 1 do
		Element("-", { x = 2 + i * 8, y = -18 + i })
		Element("-", { x = 2 + i * 8, y =  18 - i })
	end
end

local function Dup(obj, symbol, offset, x, y)
	letter.Element(obj, symbol, offset)
	letter.Element(obj, symbol, vector.Offset(offset, x, y))
end

local function Wing(obj, dir, symbol)
	local len = 15
	for i = 1, len, 1 do
		Dup(obj, "-", { x = 12 + i * 8, y = dir * 31 }, 0, dir * 4)
	end
	for i = 1, 20, 1 do
		local h = dir * (31 - i)
		Dup(obj, "-", { x = 12 + (len + i) * 8, y = h }, 0, dir * 4)
	end

	Dup(obj, symbol, { x = 48, y = dir * 40 }, 4, 0)
	Dup(obj, symbol, { x = 54, y = dir * 52 }, 4, 0)
	Engine(obj, { x = 48, y = -dir * 78 })
	Dup(obj, symbol, { x = 72, y = dir * 100 }, 4, 0)
	Dup(obj, symbol, { x = 78, y = dir * 112 }, 4, 0)
	Engine(obj, { x = 72, y = -dir * 138 })

	for i = 0, 4, 1 do
		local h = dir * (160 + i * 12)
		Dup(obj, symbol, { x = 96 + i * 6, y = h }, 4, 0)
	end
	for i = 0, 14, 1 do
		local h = dir * (40 + i * 12)
		letter.Element(obj, symbol, { x = 96 + i * 4, y = h })
	end
	for i = 0, 4, 1 do
		local h = dir * (16 + i * 12)
		Dup(obj, symbol, { x = 300 + i * 6, y = h }, 4, 0)
	end
	for i = 0, 4, 1 do
		local h = dir * (14 + i * 12)
		letter.Element(obj, symbol, { x = 326 + i * 4, y = h })
	end
	for i = 0, 3, 1 do
		letter.Element(obj, "-", { x = 128 + i * 8, y = dir * 216 })
	end
	for i = 0, 1, 1 do
		letter.Element(obj, "-", { x = 332 + i * 8, y = dir * 70 })
	end
end

local sway = 25

local function Swing(body)
	local pos = eapi.GetPos(body)
	eapi.SetVel(body, { x = 0, y = sway })
	eapi.SetAcc(body, { x = 0, y = -sway })
	eapi.SetPos(body, { x = pos.x, y = 0 })
	util.Delay(body, 2, Swing, body)
	sway = -sway
end

local function Launch()
	local pos = { x = 400, y = 0 }

	local obj = {
		z = 5,
		angle = 0,
		pos = pos,
		pindex = 1,
		class = "Boss",
		colorSet = "b29",
		propellers = { },
		Explode = letter.SimpleExplode,
	}

	local mainBody = eapi.NewBody(gameWorld, vector.Offset(pos, -1, 0))

	obj = actor.Create(obj)
	Wing(obj, 1, "/")
	Wing(obj, -1, "\\")

	Dup(obj, "/", { x = 12, y = 24 }, -4, 0)
	Dup(obj, "/", { x = 6, y = 12 }, -4, 0)
	Dup(obj, "|", { x = 4, y = 0 }, -4, 0)
	Dup(obj, "\\", { x = 6, y = -12 }, -4, 0)
	Dup(obj, "\\", { x = 12, y = -24 }, -4, 0)

	letter.Element(obj, "-", { x = 12, y = 6 })
	letter.Element(obj, "|", { x = 18, y = 0 })
	letter.Element(obj, "-", { x = 12, y = -6 })

	letter.Element(obj, "-", { x = 18, y = 18 })
	letter.Element(obj, "-", { x = 18, y = -18 })

	letter.Element(obj, "/", { x = 22, y = 12 })
	letter.Element(obj, "\\", { x = 22, y = -12 })

	letter.Element(obj, "/", { x = 28, y = 24 })
	letter.Element(obj, "\\", { x = 28, y = -24 })

	letter.Element(obj, ">", { x = 326, y = 0 })

	local text = "SuperFortress"
	for i = 1, string.len(text), 1 do
		local char = string.sub(text, i, i)
		local offset = { x = 40 + (i - 1) * 8, y = 0 }
		letter.Element(obj, char, offset)
	end

	eapi.SetVel(mainBody, { x = -200, y = 0 })
	util.Delay(mainBody, 2, Swing, mainBody)

	eapi.Link(obj.body, mainBody)
	eapi.SetStepC(obj.body, eapi.STEPFUNC_ROT, 32 * math.pi)

	b29.obj = obj
	return obj
end

local function Damage()
	local propellers = b29.obj.propellers
	local obj = propellers[b29.obj.pindex]
	obj.offset = { x = 0, y = 0 }
	rocket.Afterburner(obj, { x = 200, y = 0 })
	letter.Sparks(obj, 50, { x = 50, y = 0 }, 2.0, 180)
	util.PlaySound(gameWorld, "sound/explode.ogg", 0.1, 0, 0.5)
	b29.obj.pindex = b29.obj.pindex + 1
end

local function Line(pos, vel, Fn)
	bullet.Line(pos, vel, Fn, 5, 0.95, 1.05)
end

local function Fanout(pos, flip)
	for angle = -90, 90, 15 do
		local vel = player.Aim(pos, bullet.speed)
		Line(pos, vector.Rotate(vel, angle), bullet.Choose(flip))
		flip = not flip
	end
end

local flip = false
local function WingShoot(Fn)
	local pos = eapi.GetPos(b29.obj.body, gameWorld)
	Fn(vector.Offset(pos, 80, -100), flip, -1)
	Fn(vector.Offset(pos, 80, 100), not flip, 1)
	flip = not flip
end

local function Crossfire()
	WingShoot(Fanout)
end

local function FullArc(pos, vel, BulletFn, count)
	bullet.Arc(pos, vel, BulletFn, count, 360 - (360 / count))
end

local function Ripples()
	local cAngle = 0
	local cBase = { x = bullet.speed, y = 0 }

	local function Circular(pos, flip, dir)
		local function Arc(pos, vel)
			bullet.Arc(pos, vel, bullet.Choose(flip), 5, 5)
			flip = not flip
		end
		local vel = vector.Rotate(cBase, dir * cAngle)
		FullArc(pos, vel, Arc, 13)
	end

	return function()
		WingShoot(Circular)
		cAngle = (cAngle + 5) % 360
	end
end

local function Destroy()
	util.PlaySound(gameWorld, "sound/explode.ogg", 0.1, 0, 0.5)
	util.Map(actor.Delete, b29.obj.propellers)
	letter.Explode(b29.obj, 64, 60)
end

local function EmitCloud(pos)
	pos = vector.Rnd(pos, 24)
	local Fn = bullet.Choose(math.random() > 0.5)
	for angle = -30, 30, 30 do
		local vel = player.Aim(pos, bullet.speed, 128)
		Fn(pos, vector.Rotate(vel, angle))
	end
end

local function Clouds(body)
	local count = 10
	local function Emit()
		local pos = eapi.GetPos(b29.obj.body, gameWorld)
		EmitCloud(vector.Offset(pos, 80, -100))
		EmitCloud(vector.Offset(pos, 128, 0))
		EmitCloud(vector.Offset(pos, 80, 100))
		if count > 0 then
			eapi.AddTimer(body, 0.02, Emit)
			count = count - 1
		end
	end
	Emit()
end

local function Freak()
	local width = 90
	local wStep = -0.5
	local maxWidth = 12
	local minWidth = 10

	local adjust = 0
	local aStep = 0.5
	local maxAdjust = 25

	local function Fork(pos, flip, dir)
		for angle = -width, width, width * 2 do
			local vel = player.Aim(pos, bullet.speed)
			local Fn = bullet.Choose(dir > 0)
			Fn(pos, vector.Rotate(vel, angle + adjust))
		end
	end

	return function()
		WingShoot(Fork)
		adjust = adjust + aStep
		if math.abs(adjust) > maxAdjust then aStep = -aStep end

		width = width + wStep
		if (width > maxAdjust and wStep > 0) or (width < minWidth) then
			wStep = -wStep
		end
	end
end

b29 = {
	Freak = Freak(),
	Damage = Damage,
	Launch = Launch,
	Clouds = Clouds,
	Destroy = Destroy,
	Ripples = Ripples(),
	Crossfire = Crossfire,
}
