local function Afterburner(obj, vel)
	local function Emit()
		local spark = letter.Add(obj, "@", obj.offset, "gray")
		if vel then eapi.SetVel(spark.body, vel) end
		letter.Spin(spark, -2, math.random(0, 359))
		eapi.AddTimer(obj.body, 0.05, Emit)
		letter.Expire(spark, 0.4)
		actor.Unlink(spark)
	end
	Emit()
end

local function Explode(obj)
	letter.Explode(obj, -64, 60)
end

local function SelectText(vel)
	return vel.x < 0 and "<Rocket" or ">tekcoR"
end

local function Launch(pos, vel)
	local obj = {
		z = 5,
		pos = pos,
		health = 5,
		class = "Mob",
		Explode = Explode,
		colorSet = "orange",
		velocity = vel,
	}

	obj = actor.Create(obj)
	obj.angle = 180 + vector.Angle(vel)
	local rocketText = SelectText(vel)
	for i = 1, string.len(rocketText), 1 do
		local char = string.sub(rocketText, i, i)
		local offset = { x = (i - 1) * 8, y = 0 }
		local subObj = letter.Element(obj, char, offset)
		if vel.x > 0 then letter.Flip(subObj, { true, true }) end
	end
	Afterburner(obj)
	return obj
	
end

rocket = {
	Launch = Launch,
	Afterburner = Afterburner,
}
