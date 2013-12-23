local function Explode(obj)
	local dir = vector.Normalize(obj.velocity, 50)
	letter.Sparks(obj, 10, dir, 1.0, 90, obj.colorSet)
	actor.Delete(obj)
end

local function Emit(pos, vel, colorSet)
	local obj = {
		z = 50,
		pos = pos,
		class = "Bullet",
		Explode = Explode,
		colorSet = colorSet,
		bb = actor.Square(3),
		velocity = vel,
	}

	obj = actor.Create(obj)
	local subObj = letter.Add(obj, "o", { x = 0, y = 1 }, colorSet)
	return obj
end

local function Cyan(pos, vel)
	return Emit(pos, vel, "cyan")
end

local function Pink(pos, vel)
	return Emit(pos, vel, "pink")
end

local function Line(pos, vel, BulletFn, count, min, max, spread)
	local angle = 0
	bullet.z_epsilon = 0
	local step = (max - min) / (count - 1)
	for i = 1, count, 1 do
		local vel = vector.Scale(vel, min + step * i)
		if spread then
			vel = vector.Rotate(vel, spread * (angle - 0.5))
			angle = (angle + util.golden) % 1
		end
		BulletFn(pos, vel)
	end
end

local function Arc(pos, vel, BulletFn, count, angle)
	bullet.z_epsilon = 0
	if count == 1 then
		BulletFn(pos, vel)
	else
		local step = angle / (count - 1)
		local angle = -angle / 2
		for i = 1, count, 1 do
			BulletFn(pos, vector.Rotate(vel, angle))
			angle = angle + step
		end
	end
end

local function Circle(pos, vel, BulletFn, count)
	Arc(pos, vel, BulletFn, count, 360 - (360 / count))
end

local function Choose(predicate)
	return predicate and bullet.Cyan or bullet.Pink
end

local function Mob(pos, colorSet)
	local obj = {
		z = 50,
		pos = pos,
		health = 3,
		class = "Mob",
		colorSet = colorSet,
		bb = actor.Square(3),
		velocity = vector.null,
		Explode = actor.Delete,
	}

	obj = actor.Create(obj)
	local subObj = letter.Add(obj, "o", { x = 0, y = 1 }, colorSet)
	return obj
end

bullet = {
	Arc = Arc,
	Emit = Emit,
	Cyan = Cyan,
	Pink = Pink,
	Line = Line,
	Choose = Choose,
	Circle = Circle,
	speed = 200,
	Mob = Mob,
}
