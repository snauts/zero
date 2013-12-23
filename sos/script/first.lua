dofile("config.lua")
dofile("script/util.lua")
dofile("script/vector.lua")

camera     = nil
gameWorld  = nil
staticBody = nil

state = {  }
if util.FileExists("saavgaam") then 
	dofile("saavgaam")
end

util.Preload()
util.Goto("startup")
