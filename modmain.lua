for _, v in ipairs({ "_G", "setmetatable", "rawget" }) do
	env[v] = GLOBAL[v]
end

setmetatable(env,
{
	__index = function(table, key) return rawget(_G, key) end
})

CHANGE_CONTROLLER_LEFT_SHOULDER_HOLD_TIME=1.0
CHANGE_CONTROL_CAMERA = CONTROL_ROTATE_LEFT
CHANGE_ADD_EXTRAL_BACKPACK_INTEGRATE_SETTING = true
CHANGE_INTEGRATE_BACKPACK = false

CHNAGE_IS_CHANGE_INVENTORY_BAR = true

modimport("scripts/change_profile")
modimport("scripts/change_playercontroller")
modimport("scripts/change_inventorybar")
modimport("scripts/change_craftingmenu")
modimport("scripts/change_playerhud")
modimport("scripts/change_wheel")
modimport("scripts/change_controls")
modimport("scripts/change_test")