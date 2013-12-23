local function AddSlave(master, Fn, pos, vel, delta)
	local slavePos = vector.Add(pos, vector.Normalize(vel, delta))
	local slave = Fn(slavePos, vector.null)
	actor.Link(slave, master)

	eapi.SetStepC(slave.body, eapi.STEPFUNC_ROT, math.pi / 2)
end

local function Combine(Fn, pos, vel)
	local master = Fn(pos, vel)
	AddSlave(master, Fn, pos, vel, 8)
	AddSlave(master, Fn, pos, vel, -8)
	return master
end

local function Annihilate(bomb)
	local count = 0
	local flip = true
	local pos = vector.Offset(actor.GetPos(bomb), 20, 0)
	local vel = player.Aim(pos, 1.5 * bullet.speed)

	local function Neutron()
		local obj = Combine(bullet.Choose(flip), pos, vel)
		eapi.SetAcc(obj.body, vector.Scale(vel, -1))
		vel = vector.Rotate(vel, util.fibonacci)
		flip = not flip
		local function StopAcc()
			eapi.SetAcc(obj.body, vector.null)
		end
		eapi.AddTimer(obj.body, 2, StopAcc)
		if count < 100 then
			eapi.AddTimer(obj.body, 0.01, Neutron)
			count = count + 1
		end
	end
	Neutron()

	letter.SimpleExplode(bomb)
end

local function FatMan(pos, vel)
	local obj = {
		z = 5,
		pos = pos,
		angle = 0,
		health = 67,
		class = "Mob",
		Explode = Annihilate,
		colorSet = "darkGray",
		velocity = vel,
	}

	obj = actor.Create(obj)

	letter.Element(obj, "(", { x = -8, y = 0 })
	local function Arc(dir, tH, tail)
		letter.Element(obj, "F", { x = .1, y = 7 * dir })
		letter.Element(obj, "a", { x = 8, y = 12 * dir })
		letter.Element(obj, "t", { x = 16, y = tH * dir })
		letter.Element(obj, "m", { x = 24, y = 14 * dir })
		letter.Element(obj, "a", { x = 32, y = 12 * dir })
		letter.Element(obj, "n", { x = 40, y = 5 * dir })

		letter.Element(obj, tail, { x = 48, y = 8 * dir - 1 })
		letter.Element(obj, "-", { x = 56, y = 14 * dir - 1 })
		letter.Element(obj, "|", { x = 60, y = 8 * dir - 1 })
	end
	Arc(1, 12, "/")
	Arc(-1, 14, "\\")

	return obj
end

nuke = {
	FatMan = FatMan,
	Annihilate = Annihilate,
}
