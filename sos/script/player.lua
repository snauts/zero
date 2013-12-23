local LEFT   = 1
local RIGHT  = 2
local UP     = 3
local DOWN   = 4

local playerSpeed = 250
local shootInterval = 0.02
local shootSpeed = 1200

actor.Cage("Blocker", 0.6, 0.5)

actor.SimpleCollide("Blocker", "Blockable", actor.Blocker)

local function GetDirection(moves)
	return { x = moves[RIGHT] - moves[LEFT], y = moves[UP] - moves[DOWN] }
end

local function SetSpeed(player)
	eapi.SetVel(player.body, vector.Normalize(player.vel, player.speed))
end

local function Move(player, axis)
	return function(keyDown)
		player.moves[axis] = (keyDown and 1) or 0
		player.vel = GetDirection(player.moves)
		SetSpeed(player)
	end
end

local function Create(pos)
	local obj = {
		z = 0.0,
		pos = pos,
		life = 0.5,
		class = "Blockable",
		moves = { 0, 0, 0, 0 },
		bb = actor.Square(4),
		speed = playerSpeed,
	}

	local bornTime = 1.0
	obj = actor.Create(obj)

	local function Add(symbol, offset, colorSet)		
		local subObj = letter.Add(obj, symbol, offset, colorSet)
		letter.Arrive(subObj, bornTime)
		return subObj
	end

	Add("o", { x = -.1, y = 0 }, "red")
	Add("r", { x = -8, y = 0 }, "green")
	Add("e", { x = -16, y = 0 }, "green")
	Add("Z", { x = -24, y = -1 }, "green")

	for i = -1, 1, 2 do
		Add("r", { x = -2, y = i * 10 }, "green")
		Add("e", { x = -4, y = i * 20 }, "green")
		Add("z", { x = -6, y = i * 30 }, "green")
	end
	
	local rotor = Add("|", { x = 4, y = -1 }, "green")
	util.Delay(rotor.body, bornTime + 0.05, letter.Oscilate, rotor)

	local function AddPlayerShape()
		actor.MakeShape(obj, obj.bb, "Player")
		player.EnableShoot(obj)
	end
	eapi.AddTimer(obj.body, bornTime, AddPlayerShape)

	player.EnableInput(obj)
	player.obj = obj
	return obj
end

local sparkRnd = 0.0
local function FadingStripe(player, offset, spread)
	local rnd = 2.0 * sparkRnd - 1.0
	sparkRnd = (sparkRnd + 0.11) % 1.0
	offset = vector.Offset(offset, 0, 4 * rnd)
	local spark = letter.Add(player, "<", offset, "orange")
	letter.Rotate(spark, rnd * spread)
	letter.Expire(spark, 0.1)
end

local shootSparkVel = { x = 50, y = 0 }
local function ExplodeShoot(shoot)
	letter.Sparks(shoot, 5, shootSparkVel, 2.0, 180)
	actor.Delete(shoot)
end

local function EmitShoot(player, type, angle, offset)
	local obj = {
		z = -1.0,
		life = 0.5,
		damage = 1,
		class = "Shoot",
		bb = actor.Square(2),
		Explode = ExplodeShoot,
		pos = vector.Add(actor.GetPos(player), offset),
		velocity = vector.Rotate({ x = shootSpeed, y = 0 }, angle),
	}

	obj = actor.Create(obj)
	FadingStripe(player, offset, 45)
	local subObj = letter.Add(obj, type, { x = 0, y = -1 }, "orange")
	letter.Rotate(subObj, angle)
	return obj
end

local function ShootAngle()
	return 4 * (math.random() - 0.5)
end

local function PlayGunFire(fileName)
	player.gunfire = eapi.PlaySound(gameWorld, fileName, -1, 0.05)
end

local function StopGunFire()
	eapi.FadeSound(player.gunfire, 0.1)
	player.gunfire = nil
end

local function Shoot(player)
	local timer = nil
	local topWing = { x = 2, y = 12 }
	local bottomWing = { x = 2, y = -12 }

	local function Start()
		EmitShoot(player, "=", ShootAngle(), topWing)
		EmitShoot(player, "=", ShootAngle(), bottomWing)
		timer = eapi.AddTimer(player.body, shootInterval, Start)
	end

	local function Cancel()
		if timer then
			eapi.CancelTimer(timer)
			timer = nil
		end
	end

	return function(keyDown)
		if keyDown then
			PlayGunFire("sound/gunfire.ogg")
			Start()
		else
			StopGunFire()
			Cancel()
		end
	end
end

local function EnableInput(player)
	input.Bind("Up", true, Move(player, UP))
	input.Bind("Down", true, Move(player, DOWN))
	input.Bind("Left", true, Move(player, LEFT))
	input.Bind("Right", true, Move(player, RIGHT))
end

local function EnableShoot(player)
	player.ShootFn = player.ShootFn or Shoot(player)
	input.Bind("Shoot", true, player.ShootFn)
end

local function DisableInput(player)
	input.Bind("Up")
	input.Bind("Down")
	input.Bind("Left")
	input.Bind("Right")
	input.Bind("Shoot")
end

local function GetPos()
	if not player.obj.destroyed then
		player.lastPos = actor.GetPos(player.obj)
	end
	return player.lastPos
end

local sparkVel = { x = 50, y = 0 }
local function HitPlayer(pShape, eShape)
	local enemy = actor.store[eShape]

	DisableInput(player.obj)
	player.lastPos = GetPos()
	letter.Sparks(player.obj, 20, sparkVel, 2.0, 180)
	letter.Explode(player.obj, 128, 60)

	if not(enemy.class == "Boss") then enemy.Explode(enemy) end

	eapi.PlaySound(gameWorld, "sound/burst.ogg")
	util.Delay(staticBody, player.obj.life, Create, player.lastPos)
	player.deaths = player.deaths + 1
	player.PrintScore()
	timing.Reset()
end

local function Aim(pos, speed, jitter)
	jitter = jitter or 0.0
	local target = vector.Rnd(GetPos(), jitter)
	return vector.Normalize(vector.Sub(target, pos), speed)
end

actor.SimpleCollide("Player", "Mob", HitPlayer)
actor.SimpleCollide("Player", "Boss", HitPlayer)
actor.SimpleCollide("Player", "Bullet", HitPlayer)

local function HitMob(mShape, sShape)
	local mob = actor.store[mShape]
	local shoot = actor.store[sShape]
	mob.health = mob.health - shoot.damage
	player.UpdateScore(shoot.damage)
	if mob.health <= 0 then
		util.PlaySound(gameWorld, "sound/explode.ogg", 0.1, 0, 0.5)
		mob.Explode(mob)
	end
	shoot.Explode(shoot)
end

actor.SimpleCollide("Mob", "Shoot", HitMob)

local function HitBoss(bShape, sShape)
	local boss = actor.store[bShape]
	local shoot = actor.store[sShape]
	shoot.Explode(shoot)
	return shoot
end

local function HitScorer(bShape, sShape)
	player.UpdateScore(HitBoss(bShape, sShape).damage)
end

actor.SimpleCollide("Boss", "Shoot", HitBoss)
actor.SimpleCollide("Scorer", "Shoot", HitScorer)

local scorePos = { x = -396, y = -240 }
local function PrintScore()
	if player.scoreTiles then
		util.Map(eapi.Destroy, player.scoreTiles)
	end
	local text = nil
	if player.deaths > 0 then
		text = "Deaths: " .. player.deaths
	else
		text = "Score: " .. player.score
	end
	player.scoreTiles = util.PrintOrange(scorePos, text, nil, nil, 0.1)
end

local function UpdateScore(value)
	if player.deaths == 0 then
		player.score = player.score + value
		PrintScore()
	end
end

player = {
	Aim = Aim,
	score = 0,
	deaths = 0,
	GetPos = GetPos,
	Create = Create,
	lastPos = vector.null,
	PrintScore = PrintScore,
	UpdateScore = UpdateScore,
	EnableInput = EnableInput,
	EnableShoot = EnableShoot,
}
