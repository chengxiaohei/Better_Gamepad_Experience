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
CHANGE_CONTROL_OPTION = CHANGE_CONTROL_RIGHT

CHANGE_LANGUAGE_ENGLISH = GetModConfigData("language")
CHANGE_ALWAYS_SHOW_MAP_CONTROL_WIDGET = GetModConfigData("show_map_widget")
CHANGE_SHOW_SELF_INSPECT_BUTTON = GetModConfigData("show_self_inspect")
CHANGE_HIDE_INVENTORY_BAR_HINT = GetModConfigData("hide_inventory_hint")
CHANGE_HIDE_THEWORLD_ITEM_HINT = GetModConfigData("hide_world_item_hint")
CHANGE_INVENTORY_BAR_HINT_REMOVE_TEXT = true -- @TODO
CHANGE_THEWORLD_ITEM_HINT_REMOVE_TEXT = true -- @TODO

CHANGE_FORCE_BUTTON = GetModConfigData("enable_force_control") and CHANGE_CONTROL_LEFT
CHANGE_FORCE_BUTTON_LEVEL2 = GetModConfigData("enable_force_control") and CHANGE_CONTROL_RIGHT

CHANGE_IS_FORCE_ATTACK        = CHANGE_FORCE_BUTTON and GetModConfigData("force_attack_target")  -- true or false
CHANGE_IS_FORCE_PING_RETICULE = CHANGE_FORCE_BUTTON and GetModConfigData("force_ground_actions")  -- true or false
CHANGE_IS_FORCE_PAUSE_QUICKLY = CHANGE_FORCE_BUTTON and GetModConfigData("force_pause")

CHANGE_IS_USE_DPAD_SELECT_CRAFTING_MENU  = GetModConfigData("change_craftingmenu")
CHANGE_IS_USE_DPAD_SELECT_SPELLWHEEL_ITEM = GetModConfigData("change_wheel")
CHANGE_IS_FORBID_Y_INSPECT_SELF = GetModConfigData("forbid_inspect_self")
CHANGE_IS_INTERACT_ALL_DIRECTION = GetModConfigData("interact_all_direction") -- Default: false
CHANGE_IS_ATTACK_ALL_DIRECTION = GetModConfigData("attack_all_direction") -- Default: true
CHANGE_INTERACTION_TARGET_DETECT_RADIUS = GetModConfigData("interaction_target_detect_radius")  --Default: 6
CHANGE_ADD_ATTACKABLE_TARGET_DETECT_RADIUS = GetModConfigData("add_attackable_target_detect_radius")  -- Default: 0

CHANGE_IS_REVERSE_CAMERA_ROTATION = GetModConfigData("reverse_rotation")
CHANGE_IS_REVERSE_CAMERA_ZOOM     = GetModConfigData("reverse_zoom")

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
