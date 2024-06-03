for _, v in ipairs({ "_G", "setmetatable", "rawget" }) do
	env[v] = GLOBAL[v]
end

setmetatable(env,
{
	__index = function(table, key) return rawget(_G, key) end
})

CHANGE_CONTROLLER_LEFT_SHOULDER_HOLD_TIME=1.0
CHANGE_ADD_EXTRAL_BACKPACK_INTEGRATE_SETTING = true
CHANGE_INTEGRATE_BACKPACK = false

CHNAGE_IS_CHANGE_INVENTORY_BAR = true

CHANGE_IS_ADD_CONTAINER_MOVE_LIMIT = true  -- Switch Flag (Open or Close)
CHANGE_USE_DEFAULT_LIMIT_PATTERN = true    -- Hold CHANGE_CONTROL_RIGHT to Remove Limit
CHANGE_USE_ANOTHER_LIMIT_PATTERN = false   -- Hold CHANGE_CONTROL_RIGHT to Add Limit
-- assert ((CHANGE_IS_ADD_CONTAINER_MOVE_LIMIT and CHANGE_USE_DEFAULT_LIMIT_PATTERN == not CHANGE_USE_ANOTHER_LIMIT_PATTERN) or not CHANGE_IS_ADD_CONTAINER_MOVE_LIMIT)


CHANGE_CONTROL_LEFT = CONTROL_ROTATE_LEFT
CHANGE_CONTROL_RIGHT = CONTROL_ROTATE_RIGHT
CHANGE_CONTROL_CAMERA = CHANGE_CONTROL_LEFT

modimport("scripts/change_profile")
modimport("scripts/change_playercontroller")
modimport("scripts/change_inventorybar")
modimport("scripts/change_craftingmenu")
modimport("scripts/change_playerhud")
modimport("scripts/change_wheel")
modimport("scripts/change_controls")
modimport("scripts/change_test")