local function Launch(pos, vel)
	local obj = {
		z = 5,
		pos = pos,
		health = 13,
		class = "Mob",
		Explode = letter.SimpleExplode,
		colorSet = "red",
		velocity = vel,
	}

	obj = actor.Create(obj)
	obj.angle = 180 + vector.Angle(vel)

	letter.Element(obj, "-", { x = -8, y = 0 })
	letter.Element(obj, "C", { x = .1, y = 0 })
	letter.Element(obj, "=", { x = 8, y = 0 })
	letter.Element(obj, "<", { x = 16, y = 0 })
	letter.Element(obj, "/", { x = 4, y = 12 })
	letter.Element(obj, "\\", { x = 4, y = -12 })

	return obj
end

local function Attack(obj)
	local vel = nil
	local BulletFn = bullet.Choose(obj.velocity.x > 0)
	local function Shoot()
		local pos = actor.GetPos(obj)
		if not vel then vel = player.Aim(pos, bullet.speed) end
		BulletFn(pos, vel)
	end
	util.Repeater(Shoot, 3, 0.25, obj.body, 0.2)
	return obj
end

cece = {
	Launch = Launch,
	Attack = Attack,
}
