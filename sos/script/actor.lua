local store = { }

local size = util.GetCameraSize()

local function Cage(type, x1, x2)
	local bb = { { b = -x1 * size.y, t = -x2 * size.y,
		       l = -x1 * size.x, r =  x1 * size.x },
		     { t =  x1 * size.y, b =  x2 * size.y,
		       l = -x1 * size.x, r =  x1 * size.x },
		     { l = -x1 * size.x, r = -x2 * size.x,
		       b = -x2 * size.y, t =  x2 * size.y },
		     { r =  x1 * size.x, l =  x2 * size.x,
		       b = -x2 * size.y, t =  x2 * size.y }, }
	for i = 1, 4, 1 do eapi.NewShape(staticBody, nil, bb[i], type) end
end

local function Square(x)
	return { b = -x, t = x, l = -x, r = x }
end

local function GetPos(actor, relativeTo)
	return eapi.GetPos(actor.body, relativeTo or gameWorld)
end

local function MakeTile(obj)
	local offset = obj.offset
	local size = obj.spriteSize
	obj.tile = eapi.NewTile(obj.body, offset, size, obj.sprite, obj.z)
	return obj.tile
end

local function MakeShape(obj, bb, class)
	class = class or obj.class
	local shape = eapi.NewShape(obj.body, nil, bb or obj.bb, class)
	obj.shape[shape] = shape
	store[shape] = obj
	return shape
end

local function Create(actor)
	actor.shape = { }
	actor.blinkIndex = 0
	local parent = actor.parentBody or gameWorld
	actor.body = eapi.NewBody(parent, actor.pos)
	actor.blinkTime = eapi.GetTime(actor.body)
	if actor.bb and actor.class then
		MakeShape(actor)
	end
	if actor.sprite then
		MakeTile(actor)
	end
	if actor.velocity then
		eapi.SetVel(actor.body, actor.velocity)
	end
	return actor	
end


local function DeleteShapeObject(shape)
	eapi.Destroy(shape)
	store[shape] = nil
end

local function DeleteShape(actor)
	util.Map(DeleteShapeObject, actor.shape)
	actor.shape = { }
end

local function Delete(actor)
	if actor.destroyed then return end
	util.Map(Delete, util.CopyTable(actor.children))
	if actor.parent then actor.parent.children[actor] = nil end
	util.MaybeCall(actor.OnDelete, actor)
	DeleteShape(actor)
	eapi.Destroy(actor.body)
	actor.destroyed = true
end

local function Link(child, parent)
	if parent.children == nil then parent.children = { } end
	eapi.Link(child.body, parent.body)
	parent.children[child] = child
	child.parent = parent
end

local function Unlink(child)
	if child.parent then
		child.parent.children[child] = nil
		eapi.Unlink(child.body)
		child.parent = nil
	end
end

local function ReapActor(rShape, aShape)
	Delete(store[aShape])
end

local function Blocker(bShape, aShape, box)
        local actor = store[aShape]
        local pos = GetPos(actor)

	local movex = math.abs(box.l) > math.abs(box.r) and box.r or box.l
	local movey = math.abs(box.b) > math.abs(box.t) and box.t or box.b

	if math.abs(movex) > math.abs(movey) then
		movex = 0
	else
		movey = 0
	end

	eapi.SetPos(actor.body, vector.Offset(pos, -movex, -movey))
	return false, actor
end

local function SimpleCollide(type1, type2, Func, priority, update)
	update = (update == nil) and true or update
	local function Callback(shape1, shape2, resolve)
		if not resolve then return end
		Func(shape1, shape2, resolve)
	end
	eapi.Collide(gameWorld, type1, type2, Callback, update, priority or 10)
end

Cage("Reaper", 0.8, 0.7)

SimpleCollide("Reaper", "Mob", ReapActor)

Cage("BulletReaper", 0.8, 0.55)
SimpleCollide("BulletReaper", "Bullet", ReapActor)
SimpleCollide("BulletReaper", "Shoot", ReapActor)

local function DelayedDelete(obj, time)
	eapi.AddTimer(obj.body, time, function() Delete(obj) end)
	DeleteShape(obj)
end

local function BoxAtPos(pos, size)
	return { l = pos.x - size, r = pos.x + size,
		 b = pos.y - size, t = pos.y + size }		 
end

local function LoadMisc(frame)
	return eapi.NewSpriteList({ "image/misc.png", filter = true }, frame)
end

util.white = LoadMisc({ { 8, 8 }, { 16, 16 } })
util.gradient = LoadMisc({ { 8, 40 }, { 16, 16 } })

local function ESC(keyDown)
	if keyDown then
		if state.level == "startup" then
			eapi.Quit()
		else
			util.Goto("startup")
		end
	end
end

input.Bind("Quit", false, ESC)

local function FillScreen(sprite, z, color, body)
	body = body or staticBody
	local offset = vector.Scale(size, -0.5)
	local tile = eapi.NewTile(body, offset, size, sprite, z)
	if color then eapi.SetColor(tile, color) end
	return tile
end

local function LoadSprite(fileName, size)
	return eapi.ChopImage({ fileName, filter = true }, size)
end

actor = {
	store = store,
	BoxAtPos = BoxAtPos,
	MakeShape = MakeShape,
	FillScreen = FillScreen,
	SimpleCollide = SimpleCollide,
	DelayedDelete = DelayedDelete,
	DeleteShape = DeleteShape,
	LoadSprite = LoadSprite,
	MakeTile = MakeTile,
	Blocker = Blocker,
	Create = Create,
	Square = Square,
	Delete = Delete,
	GetPos = GetPos,
	Unlink = Unlink,
	Cage = Cage,
	Link = Link,
}
return actor
