for _, v in ipairs({ "_G", "setmetatable", "rawget" }) do
	env[v] = GLOBAL[v]
end

setmetatable(env,
{
	__index = function(table, key) return rawget(_G, key) end
})

Language_En = locale ~= "zh" and locale ~= "zht" and locale ~= "zhr"

CHANGE_SHOW_SELF_INSPECT_BUTTON = true

CHANGE_IS_ADD_CONTAINER_MOVE_LIMIT = false  -- Switch Flag (Open or Close)
CHANGE_USE_DEFAULT_LIMIT_PATTERN = true    -- Hold CHANGE_CONTROL_RIGHT to Remove Limit
CHANGE_USE_ANOTHER_LIMIT_PATTERN = false   -- Hold CHANGE_CONTROL_RIGHT to Add Limit
-- assert ((CHANGE_IS_ADD_CONTAINER_MOVE_LIMIT and CHANGE_USE_DEFAULT_LIMIT_PATTERN == not CHANGE_USE_ANOTHER_LIMIT_PATTERN) or not CHANGE_IS_ADD_CONTAINER_MOVE_LIMIT)

CHANGE_ALWAYS_SHOW_MAP_CONTROL_WIDGET = true

CHANGE_CONTROL_LEFT = CONTROL_ROTATE_LEFT
CHANGE_CONTROL_RIGHT = CONTROL_ROTATE_RIGHT
CHANGE_CONTROL_CAMERA = CHANGE_CONTROL_LEFT
CHANGE_CONTROL_HOVER = CONTROL_OPEN_INVENTORY

CHANGE_FORCE_BUTTON = CHANGE_CONTROL_LEFT  -- CHANGE_CONTROL_LEFT or CHANGE_CONTROL_RIGHT or nil
CHANGE_FORCE_BUTTON_LEVEL2 = CHANGE_FORCE_BUTTON and (CHANGE_FORCE_BUTTON == CHANGE_CONTROL_LEFT and CHANGE_CONTROL_RIGHT or CHANGE_CONTROL_LEFT) or nil
CHANGE_IS_LOCK_TARGET_QUICKLY = true  -- true or false
CHANGE_IS_FORCE_PING_RETICULE = true  -- true or false
CHANGE_IS_FORCE_PICK_UP_TRAP = true  -- true or false
CHANGE_IS_FORCE_PICK_UP_ITEM = 2  -- false or 1 or 2

CHANGE_IS_USE_DPAD_SELECT_CRAFTING_MENU  = true
CHANGE_IS_USE_DPAD_SELECT_SPELLBOOK_ITEM = false
CHANGE_IS_FORBID_Y_INSPECT_SELF = true
CHANGE_IS_SWAP_CAMERA_ROTATION = true

modimport("scripts/change_mapscreen")
modimport("scripts/change_optionsscreen")
modimport("scripts/change_playercontroller")
modimport("scripts/change_playerhud")
modimport("scripts/change_inventorybar")
modimport("scripts/change_craftingmenu")
modimport("scripts/change_wheel")
modimport("scripts/change_controls")
modimport("scripts/change_reticule")
modimport("scripts/change_placer")
