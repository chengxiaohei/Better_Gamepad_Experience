for _, v in ipairs({ "_G", "setmetatable", "rawget" }) do
	env[v] = GLOBAL[v]
end

setmetatable(env,
{
	__index = function(table, key) return rawget(_G, key) end
})

CHANGE_CONTROLLER_LEFT_SHOULDER_HOLD_TIME=1.0
CHANGE_CONTROL_CAMERA = CONTROL_ROTATE_LEFT

modimport("scripts/change_playercontroller")
modimport("scripts/change_inventorybar")
modimport("scripts/change_craftingmenu")
modimport("scripts/change_playerhud")
modimport("scripts/change_wheel")
modimport("scripts/change_controls")