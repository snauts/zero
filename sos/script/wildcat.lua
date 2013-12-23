local function Launch(pos, vel)
	local obj = {
		z = 10,
		pos = pos,
		health = 19,
		class = "Mob",
		Explode = letter.SimpleExplode,
		colorSet = "navy",
		velocity = vel,
	}

	obj = actor.Create(obj)
	obj.angle = 180 + vector.Angle(vel)

	letter.Oscilate(letter.Element(obj, "|", { x = -6, y = 0 }))

	letter.Element(obj, "{", { x = .1, y = 0 })
	letter.Element(obj, "=", { x = 16, y = 0 })
	letter.Element(obj, "=", { x = 24, y = 0 })
	letter.Element(obj, "+", { x = 32, y = 0 })
	letter.Element(obj, "-", { x = 40, y = 0 })

	letter.Element(obj, "|", { x = 32, y = 10 })
	letter.Element(obj, "|", { x = 32, y = -10 })

	letter.Element(obj, "w", { x = 8, y = 36 })
	letter.Element(obj, "i", { x = 8, y = 24 })
	letter.Element(obj, "l", { x = 8, y = 12 })
	letter.Element(obj, "d", { x = 8, y = 0 })
	letter.Element(obj, "c", { x = 8, y = -12 })
	letter.Element(obj, "a", { x = 8, y = -24 })
	letter.Element(obj, "t", { x = 8, y = -36 })

	return obj
end

local function Line(pos, vel, colorFn)
	bullet.Line(pos, vel, bullet[colorFn], 15, 0.9, 1.1, 2)
end

local function Attack(obj)
	local function Shoot()
		local pos = actor.GetPos(obj)
		local colorFn = pos.y > 0 and "Pink" or "Cyan"
		Line(pos, player.Aim(pos, bullet.speed), colorFn)
	end
	eapi.AddTimer(obj.body, 0.5, Shoot)
	return obj
end

wildcat = {
	Launch = Launch,
	Attack = Attack,
}
