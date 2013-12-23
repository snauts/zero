local bgImg = eapi.ChopImage("image/background.png", { 800, 480 })

local offset = { x = -400, y = -240 }
eapi.NewTile(staticBody, offset, nil, bgImg, -1000)

local oceanImg = eapi.ChopImage("image/ocean.png", { 800, 240 })

local tile = eapi.NewTile(staticBody, offset, nil, oceanImg, -980)
eapi.Animate(tile, eapi.ANIM_LOOP, 30, 0)

local rayImg = eapi.ChopImage({ "image/ray.png", filter = true }, { 512, 512 })
local rayCenter = eapi.NewBody(gameWorld, { x = -205, y = -8 })

local rayOffset = { x = -96, y = 0 }
local raySize = { x = 192, y = 768 }

for angle = -90, 90, 30 do
	local tile = eapi.NewTile(rayCenter, rayOffset, raySize, rayImg, -990)
	eapi.SetColor(tile, { r = 1.0, g = 0.01176, b = 0.01176 })
	util.RotateTile(tile, angle)
	local start = (angle + 90.0) / 180.0
	local target = vector.Radians(angle + 4)
	eapi.AnimateAngle(tile, eapi.ANIM_REVERSE_LOOP,
			  vector.null, target, 2, start)
end

local mistPos = { x = -400, y = -9 }
local mistSize = { x = 800, y = 4 }
local tile = eapi.NewTile(staticBody, mistPos, mistSize, util.gradient, -985)
eapi.SetColor(tile, { r = 0.4235, g = 0.5843, b = 0.5843 })
