dofile("script/color.lua")

dofile("script/scrolling.lua")

Print({ x = -112, y = 0 }, "The en", util.bigFontset, "green")
Print({ x = 80, y = 0 }, "d", util.bigFontset, "red")

CenterRed("Thank you for playing!", 0)

local text = nil
local pos = { x = -396, y = -240 }
if player.deaths > 0 then
	text = "Deaths: " .. player.deaths
elseif player.score > 0 then
	text = "Score: " .. player.score
else
	text = "Maybe there is a victory after all..."
end
Print(pos, text, nil, "red")
