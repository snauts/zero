local function Launch(pos, vel)
	local obj = {
		z = 10,
		pos = pos,
		health = 37,
		class = "Mob",
		Explode = letter.SimpleExplode,
		colorSet = "khaki",
		velocity = vel,
	}

	obj = actor.Create(obj)
	obj.angle = 180 + vector.Angle(vel)

	local function Fuselage(dir)
		local y = 16 * dir
		letter.Oscilate(letter.Element(obj, "|", { x = -6, y = y }))
		letter.Element(obj, "{", { x = .1, y = y })
		letter.Element(obj, "O", { x = 8, y = y })
		letter.Element(obj, "Z", { x = 16, y = y })
		letter.Element(obj, "z", { x = 24, y = y })
		letter.Element(obj, "=", { x = 32, y = y })
		letter.Element(obj, "+", { x = 40, y = y })
		letter.Element(obj, "|", { x = 40, y = dir * 26 })
		letter.Element(obj, "-", { x = 48, y = y })

		letter.Element(obj, "T", { x = 8, y = dir * 30 })
		letter.Element(obj, "w", { x = 12, y = dir * 42 })
		letter.Element(obj, "i", { x = 16, y = dir * 54 })
		letter.Element(obj, "n", { x = 20, y = dir * 66 })
	end
	Fuselage(-1)
	Fuselage(1)

	letter.Element(obj, "H", { x = 8, y = 0 })
	letter.Element(obj, "|", { x = 40, y = 0 })
	return obj
end

local function Line(pos, vel, colorFn)
	bullet.Line(pos, vel, bullet[colorFn], 9, 0.95, 1.05, 10)
end

local function CyanLine(pos, vel)
	Line(pos, vel, "Cyan")
end

local function PinkLine(pos, vel)
	Line(pos, vel, "Pink")
end

local function Attack(obj)
	local function Shoot()
		local pos = actor.GetPos(obj)
		local vel1 = { x = bullet.speed, y = 0 }
		local vel2 = vector.Rotate(vel1, 30)
		bullet.Circle(pos, vel1, CyanLine, 6)
		bullet.Circle(pos, vel2, PinkLine, 6)
	end
	eapi.AddTimer(obj.body, 0.5, Shoot)
	return obj
end

twin = {
	Launch = Launch,
	Attack = Attack,
}
