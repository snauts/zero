dofile("script/background.lua")
dofile("script/letter.lua")
dofile("script/color.lua")
dofile("script/timing.lua")
dofile("script/player.lua")
dofile("script/bullet.lua")
dofile("script/rocket.lua")
dofile("script/wildcat.lua")
dofile("script/ultra-ce-ce.lua")
dofile("script/twin.lua")
dofile("script/nuke.lua")
dofile("script/transport.lua")
dofile("script/b29.lua")

player.Create({ x = -300, y = 0 })

eapi.SetColor(camera, { r = 0.4235, g = 0.5843, b = 0.5843 })

local function RocketBarrage(body)
	local x = 500
	local function Launch()
		local pos = { x = x - 500, y = 240 }
		rocket.Launch(pos, player.Aim(pos, 192, 64))
		eapi.AddTimer(body, 0.20, Launch)
		x = (x + util.golden * 1000) % 1000
	end
	Launch()
end

local function WildcatFormation(body)
	local side = 1
	local gold = 1
	local function Launch()
		local vel = { x = -150, y = side * (15 - 5 * gold) }
		local pos = { x = 400, y = side * (100 + 50 * gold) }
		eapi.AddTimer(body, 0.50, Launch)
		wildcat.Attack(wildcat.Launch(pos, vel))
		if side > 0 then gold = (gold + util.golden) % 1 end
		side = -side
	end
	Launch()
end

local function TwinFuselageMenace(body)
	local y = 200
	local function Launch()
		local pos = { x = 400, y = y - 200 }
		twin.Attack(twin.Launch(pos, { x = -150, y = 0 }))
		eapi.AddTimer(body, 0.5, Launch)
		y = (y + util.golden * 400) % 400
	end
	Launch()
end

local function ReleaseTheFlies(body)
	local x = 200
	local dir = 1
	local function Launch()
		local pos = { x = x, y = dir * 256 }
		local newX = (x + util.golden * 400) % 400
		local aim = { x = newX, y = -dir * 256 }
		local vel = vector.Normalize(vector.Sub(aim, pos), 400)
		cece.Attack(cece.Launch(pos, vel))
		eapi.AddTimer(body, 0.25, Launch)
		dir = -dir
		x = newX
	end
	Launch()
end

local function ShameOnYouYankies(body)
	local index = 0
	local targets = {
		{ eta = 2.00, angle = 0 },
		{ eta = 2.40, angle = 120 },
		{ eta = 3.60, angle = -120 },
	}
	local base = { x = 100, y = 0 }
	local function Adjust(target)
		local angle = target.angle + 45
		target.pos = vector.Rotate(base, angle)
		target.pos = vector.Offset(target.pos, 120, 0)
	end
	util.Map(Adjust, targets)
	local vel = { x = -50, y = -100 }
	local function Launch()
		local target = targets[index + 1]
		local offset = vector.Scale(vel, -target.eta)
		local obj = nuke.FatMan(vector.Add(target.pos, offset), vel)
		util.Delay(obj.body, target.eta, nuke.Annihilate, obj)
		index = (index + 1) % #targets
		local next = targets[index + 1]
		local delay = target.eta + 2.0 - next.eta
		eapi.AddTimer(body, delay, Launch)
	end
	Launch()
end

local function HereComesTheCargo(body)
	local y = 150
	local function Launch()
		transport.Just(y - 150)
		eapi.AddTimer(body, 1.0, Launch)
		y = (y + util.golden * 350) % 350
	end
	Launch()
end

local function CaughtInCrossfire(body)
	local function Launch()
		b29.Crossfire()
		eapi.AddTimer(body, 0.5, Launch)
	end
	eapi.AddTimer(body, 2, Launch)
	b29.Launch()
end

local function RipplesOfDoom(body)
	local function Launch()
		b29.Ripples()
		eapi.AddTimer(body, 0.5, Launch)
	end
	eapi.AddTimer(body, 1, b29.Damage)
	eapi.AddTimer(body, 2, Launch)
end

local function CloudsOfDeath(body)
	local function Launch()
		b29.Clouds(body)
		eapi.AddTimer(body, 1.0, Launch)
	end
	eapi.AddTimer(body, 1, b29.Damage)
	eapi.AddTimer(body, 2, Launch)
end

local function ControlFreak(body)
	local function Launch()
		b29.Freak()
		eapi.AddTimer(body, 0.02, Launch)
	end
	eapi.AddTimer(body, 1, b29.Damage)
	eapi.AddTimer(body, 2, Launch)
end

timing.Init({
	RocketBarrage,
	WildcatFormation,
	TwinFuselageMenace,
	ReleaseTheFlies,
	ShameOnYouYankies,
	HereComesTheCargo,
	CaughtInCrossfire,
	ControlFreak,
	RipplesOfDoom,
	CloudsOfDeath,
})

eapi.AddTimer(staticBody, 2, timing.Advance)
