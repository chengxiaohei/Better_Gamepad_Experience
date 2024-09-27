for _, v in ipairs({ "_G", "setmetatable", "rawget" }) do
	env[v] = GLOBAL[v]
end

setmetatable(env,
{
	__index = function(table, key) return rawget(_G, key) end
})

CHANGE_CONTROL_LEFT = CONTROL_ROTATE_LEFT
CHANGE_CONTROL_RIGHT = CONTROL_ROTATE_RIGHT
CHANGE_CONTROL_CAMERA = CHANGE_CONTROL_LEFT
CHANGE_CONTROL_HOVER = CONTROL_OPEN_INVENTORY

CHANGE_LANGUAGE_ENGLISH = GetModConfigData("language")
CHANGE_ALWAYS_SHOW_MAP_CONTROL_WIDGET = GetModConfigData("show_map_widget")
CHANGE_SHOW_SELF_INSPECT_BUTTON = GetModConfigData("show_self_inspect")
CHANGE_HIDE_INVENTORY_BAR_HINT = GetModConfigData("hide_inventory_hint")
CHANGE_HIDE_THEWORLD_ITEM_HINT = GetModConfigData("hide_world_item_hint")

local force = GetModConfigData("enable_force_control")
if force == "left" then
	CHANGE_FORCE_BUTTON = CHANGE_CONTROL_LEFT
elseif force == "right" then
	CHANGE_FORCE_BUTTON = CHANGE_CONTROL_RIGHT
else
	CHANGE_FORCE_BUTTON = nil
end
CHANGE_FORCE_BUTTON_LEVEL2 = CHANGE_FORCE_BUTTON and (CHANGE_FORCE_BUTTON == CHANGE_CONTROL_LEFT and CHANGE_CONTROL_RIGHT or CHANGE_CONTROL_LEFT) or nil

CHANGE_IS_FORCE_ATTACK        = CHANGE_FORCE_BUTTON and GetModConfigData("force_attack_target")  -- true or false
CHANGE_IS_LOCK_TARGET_QUICKLY = CHANGE_FORCE_BUTTON and GetModConfigData("force_lock_attack_target")  -- true or false
CHANGE_IS_FORCE_PING_RETICULE = CHANGE_FORCE_BUTTON and GetModConfigData("force_ground_actions")  -- true or false
CHANGE_IS_FORCE_SPACE_ACTION  = CHANGE_FORCE_BUTTON and GetModConfigData("force_space")
CHANGE_IS_FORCE_PAUSE_QUICKLY = CHANGE_FORCE_BUTTON and GetModConfigData("force_pause")

CHANGE_IS_USE_DPAD_SELECT_CRAFTING_MENU  = GetModConfigData("change_craftingmenu")
CHANGE_IS_USE_DPAD_SELECT_SPELLWHEEL_ITEM = GetModConfigData("change_wheel")
CHANGE_IS_FORBID_Y_INSPECT_SELF = GetModConfigData("forbid_inspect_self")
CHANGE_IS_ATTACK_ALL_DIRECTION = GetModConfigData("attack_all_direction")

CHANGE_IS_REVERSE_CAMERA_ROTATION = GetModConfigData("reverse_rotation")
CHANGE_IS_REVERSE_CAMERA_ZOOM     = GetModConfigData("reverse_zoom")
CHANGE_IS_REVERSE_CAMERA_ROTATION_MINIMAP = GetModConfigData("reverse_rotation_minimap")

CHANGE_MAPPING_LB_LT = GetModConfigData("MAPPING_LB_LT")
CHANGE_MAPPING_RB_LT = GetModConfigData("MAPPING_RB_LT")
CHANGE_MAPPING_LB_RB_LT = GetModConfigData("MAPPING_LB_RB_LT")

CHANGE_MAPPING_RB_RT = GetModConfigData("MAPPING_RB_RT")
CHANGE_MAPPING_LB_RB_RT = GetModConfigData("MAPPING_LB_RB_RT")

CHANGE_MAPPING_LB_BACK = GetModConfigData("MAPPING_LB_BACK")
CHANGE_MAPPING_RB_BACK = GetModConfigData("MAPPING_RB_BACK")
CHANGE_MAPPING_LB_RB_BACK = GetModConfigData("MAPPING_LB_RB_BACK")

CHANGE_MAPPING_LB_START = GetModConfigData("MAPPING_LB_START")
CHANGE_MAPPING_RB_START = GetModConfigData("MAPPING_RB_START")
CHANGE_MAPPING_LB_RB_START = GetModConfigData("MAPPING_LB_RB_START")

CHANGE_MAPPING_LB_LSTICK = GetModConfigData("MAPPING_LB_LSTICK")
CHANGE_MAPPING_RB_LSTICK = GetModConfigData("MAPPING_RB_LSTICK")
CHANGE_MAPPING_LB_RB_LSTICK = GetModConfigData("MAPPING_LB_RB_LSTICK")

CHANGE_MAPPING_LB_RSTICK = GetModConfigData("MAPPING_LB_RSTICK")
CHANGE_MAPPING_RB_RSTICK = GetModConfigData("MAPPING_RB_RSTICK")
CHANGE_MAPPING_LB_RB_RSTICK = GetModConfigData("MAPPING_LB_RB_RSTICK")

CHANGE_MAPPING_LB_UP = GetModConfigData("MAPPING_LB_UP")
CHANGE_MAPPING_RB_UP = GetModConfigData("MAPPING_RB_UP")
CHANGE_MAPPING_LB_RB_UP = GetModConfigData("MAPPING_LB_RB_UP")

CHANGE_MAPPING_LB_Y = GetModConfigData("MAPPING_LB_Y")
CHANGE_MAPPING_RB_Y = GetModConfigData("MAPPING_RB_Y")
CHANGE_MAPPING_LB_RB_Y = GetModConfigData("MAPPING_LB_RB_Y")

modimport("scripts/change_functions")
modimport("scripts/change_staff")
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
