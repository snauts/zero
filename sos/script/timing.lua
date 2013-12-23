local index = 0
local timeout = 13.15
local taikoRef = nil
local nextTimer = nil
local reference = nil
local patternList = { }

local function PlayTaiko(num, volume)
	eapi.PlaySound(gameWorld, "sound/taiko" .. num .. ".ogg", 0, volume)
end

local function Taiko(body, speed)
	if speed > 0.19 then
		util.Delay(body, 1.0 * speed, PlayTaiko, 1, 1.0)
		util.Delay(body, 2.0 * speed, PlayTaiko, 2, 0.5)
		util.Delay(body, 3.0 * speed, PlayTaiko, 1, 0.5)
		util.Delay(body, 4.0 * speed, PlayTaiko, 2, 0.5)
		util.Delay(body, 4.0 * speed, Taiko, body, speed * 0.9)
	else
		local num = 1
		for i = 0, 0.1, 0.02 do
			util.Delay(body, i, PlayTaiko, num, 1.0)
			num = 3 - num
		end
	end
end

local function DummyBody()
	return eapi.NewBody(gameWorld, vector.null)
end

local function NewReference()
	reference = DummyBody()
	return reference
end

local function Init(list)
	patternList = list
	NewReference()
end

local function NextTimer()
	nextTimer = eapi.AddTimer(reference, timeout, timing.Advance)
	if taikoRef then eapi.Destroy(taikoRef) end
	taikoRef = DummyBody()
	Taiko(taikoRef, 0.5)
end

local function Reset()
	if nextTimer then
		eapi.CancelTimer(nextTimer)
		NextTimer()
	end
end

local function Sweep()
	util.Map(letter.Obliterate, util.CopyTable(actor.store))
end

local function TheEnd()
	local blackInvisible = { r = 0, g = 0, b = 0, a = 0 }
	local tile = actor.FillScreen(util.white, 10000, blackInvisible)
	eapi.AnimateColor(tile, eapi.ANIM_CLAMP, util.Gray(0), 2, 0)
	util.Delay(staticBody, 2, util.Goto, "end")
end

local function Advance()
	Sweep()
	nextTimer = nil
	index = index + 1
	eapi.Destroy(reference)
	local pattenFn = patternList[index]
	if pattenFn then
		pattenFn(NewReference())
		NextTimer()
	else
		eapi.AddTimer(staticBody, 1, b29.Damage)
		eapi.AddTimer(staticBody, 3, b29.Destroy)
		eapi.AddTimer(staticBody, 6, TheEnd)
	end
end

timing = {
	Init = Init,
	Reset = Reset,
	Advance = Advance,
}
