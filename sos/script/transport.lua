--           _
--          //
-- (Transport<

local fuselage = "(Transport<"

local function Launch(pos, vel)
	local obj = {
		z = 5,
		pos = pos,
		angle = 0,
		health = 43,
		class = "Mob",
		Explode = transport.Explode,
		colorSet = "moss",
		velocity = vel,
	}

	obj = actor.Create(obj)

	letter.Element(obj, "/", { x = 72, y = 12 })
	letter.Element(obj, "/", { x = 80, y = 12 })
	letter.Element(obj, "-", { x = 80, y = 20 })

	for i = 1, string.len(fuselage), 1 do
		local char = string.sub(fuselage, i, i)
		local offset = { x = (i - 1) * 8, y = 0 }
		letter.Element(obj, char, offset)
	end

	obj.offset = { x = 84, y = 0 }
	rocket.Afterburner(obj)

	return obj
end

local function CargoHold(parent, dir, offset)
	local pos = actor.GetPos(parent)
	pos = vector.Add(pos, offset)

	local obj = {
		z = 5,
		dir = dir,
		pos = pos,
		angle = 0,
		life = 1.0,
		health = 17,
		class = "Mob",
		colorSet = "moss",
		Explode = letter.SimpleExplode,
	}

	obj = actor.Create(obj)
	actor.Link(obj, parent)
	local symbol = dir > 0 and "(" or ")"

	obj.door = letter.Element(obj, symbol, vector.null)

	return obj
end

local function ScatterVelocity(pos, spread)
	if math.random() < 0.05 then
		return player.Aim(pos, bullet.speed)
	else
		local angle = spread * math.random()
		return vector.Rotate({ x = bullet.speed, y = 0 }, angle)
	end
end

local function Scatter(obj, spread)
	spread = spread or 360
	local pos = actor.GetPos(obj, staticBody)
	bullet.Emit(pos, ScatterVelocity(pos, spread), obj.colorSet)
	actor.Delete(obj)
end

local function Detonate(bShape, aShape)
	Scatter(actor.store[aShape], 180)
end

actor.SimpleCollide("Blocker", "Detonate", Detonate)

local function CargoBullet(parent, offset, colorSet)
	local parnetPos = actor.GetPos(parent)
	local obj = bullet.Mob(vector.Add(parnetPos, offset), colorSet)
	actor.Link(obj, parent)
	obj.Explode = Scatter
	return obj
end

local function BlastOpen(obj, parentVel)
	if not obj.destroyed then
		actor.Unlink(obj)
		letter.Spin(obj.door, -0.5 * obj.dir)
		local blastVel = { x = -50 * obj.dir, y = -50 }
		eapi.SetVel(obj.body, vector.Add(parentVel, blastVel))
		eapi.SetAcc(obj.body, { x = 50, y = 0 })
		letter.Expire(obj.door, obj.life)
		actor.DelayedDelete(obj, obj.life)
	end
end

local function Release(row)
	if row.done then return else row.done = true end
	local parentVel = eapi.GetVel(row.parent.body)
	BlastOpen(row.open, parentVel)
	BlastOpen(row.close, parentVel)

	local gravity = -100
	for i = 1, #row.bullets, 1 do
		local obj = row.bullets[i]
		if not obj.destroyed then
			actor.Unlink(obj)
			eapi.SetVel(obj.body, parentVel)
			eapi.SetAcc(obj.body, { x = 50, y = gravity })
			actor.MakeShape(obj, actor.Square(3), "Detonate")
			gravity = gravity * 1.05
		end
	end
end

local function Explode(obj)
	util.Map(Release, obj.cargo)
	letter.SimpleExplode(obj)
end

local function AddCargo(obj)
	local flip = true
	local rowSize = 8
	obj.cargo = { }
	for y = 1, 4, 1 do
		local row = { }
		row.bullets = { }
		row.parent = obj
		obj.cargo[y] = row
		local last = rowSize + y + 1
		row.open = CargoHold(obj, 1, { x = 8 * y, y = -12 * y })
		row.close = CargoHold(obj, -1, { x = 8 * last, y = -12 * y })
		for x = 1, rowSize, 1 do
			local offset = { x = 8 * (x + y), y = -12 * y }
			local colorSet = flip and "pink" or "cyan"
			local obj = CargoBullet(obj, offset, colorSet)
			row.bullets[x] = obj
			flip = not flip
		end
		rowSize = rowSize - 2

		util.Delay(obj.body, 4.0 - y * 0.5, Release, row)
	end
end

local function Just(y)
	AddCargo(Launch({ x = 400, y = y }, { x = -100, y = 0 }))
end

transport = {
	Just = Just,
	Launch = Launch,
	Explode = Explode,
	AddCargo = AddCargo,
}
