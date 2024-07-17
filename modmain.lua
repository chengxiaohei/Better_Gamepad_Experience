for _, v in ipairs({ "_G", "setmetatable", "rawget" }) do
	env[v] = GLOBAL[v]
end

setmetatable(env,
{
	__index = function(table, key) return rawget(_G, key) end
})

Language_En = locale ~= "zh" and locale ~= "zht" and locale ~= "zhr"

CHANGE_CONTROL_LEFT = CONTROL_ROTATE_LEFT
CHANGE_CONTROL_RIGHT = CONTROL_ROTATE_RIGHT
CHANGE_CONTROL_CAMERA = CHANGE_CONTROL_LEFT
CHANGE_CONTROL_HOVER = CONTROL_OPEN_INVENTORY

CHANGE_ALWAYS_SHOW_MAP_CONTROL_WIDGET = GetModConfigData("show_map_widget")
CHANGE_SHOW_SELF_INSPECT_BUTTON = GetModConfigData("show_self_inspect")

local force = GetModConfigData("enable_force_control")
if force == "left" then
	CHANGE_FORCE_BUTTON = CHANGE_CONTROL_LEFT
elseif force == "right" then
	CHANGE_FORCE_BUTTON = CHANGE_CONTROL_RIGHT
else
	CHANGE_FORCE_BUTTON = nil
end
CHANGE_FORCE_BUTTON_LEVEL2 = CHANGE_FORCE_BUTTON and (CHANGE_FORCE_BUTTON == CHANGE_CONTROL_LEFT and CHANGE_CONTROL_RIGHT or CHANGE_CONTROL_LEFT) or nil

CHANGE_IS_FORCE_ATTACK = GetModConfigData("force_attack_target")  -- true or false
CHANGE_IS_LOCK_TARGET_QUICKLY = GetModConfigData("force_lock_attack_target")  -- true or false
CHANGE_IS_FORCE_PING_RETICULE = GetModConfigData("force_ground_actions")  -- true or false
CHANGE_IS_FORCE_PICK_UP_TRAP = GetModConfigData("force_pickup_teeth_trap")  -- true or false
CHANGE_IS_FORCE_PICK_UP_ITEM = GetModConfigData("force_pickup")  -- false or 1 or 2

CHANGE_IS_USE_DPAD_SELECT_CRAFTING_MENU  = GetModConfigData("change_craftingmenu")
CHANGE_IS_USE_DPAD_SELECT_SPELLBOOK_ITEM = GetModConfigData("change_wheel")
CHANGE_IS_FORBID_Y_INSPECT_SELF = GetModConfigData("forbid_inspect_self")
CHANGE_IS_SWAP_CAMERA_ROTATION = GetModConfigData("change_mapscreen_rotation")

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
