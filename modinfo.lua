local lstick = "\238\128\134"
local bbutton = "\238\128\129"
local bumperL = "\238\128\135"
local bumperR = "\238\128\138"
local triggerL = "\238\128\136"
local triggerR = "\238\128\139"
name = "Extra Controller Features 2"
description = [[ 
Changes up how controllers work with Don't Starve Together and adds some new buttons for extra fun!

*  Menu Misc 3 + Rotate Camera (]]..lstick..[[+]]..bumperL..bumperR..[[): Zoom
*  Menu Misc 3 + Alt Action (]]..lstick..[[+]]..bbutton..[[): Walk To - lets you walk to a point in front of you in case you want to check your map while moving
*  Menu Misc 3 + Open Crafting/Open Inventory (]]..lstick..[[+]]..triggerL..triggerR..[[): Adjust distance of Walk To or Soul Hop
]]
author = "Change"
version = "2.3"
forumthread = "/topic/104877-extra-controller-features/"
icon_atlas = "modicon.xml"
icon = "modicon.tex"
client_only_mod = true
all_clients_require_mod = false
dont_starve_compatible = true
reign_of_giants_compatible = true
dst_compatible = true
api_version = 10

configuration_options = {
	-- {
	-- 	name = "misc",
	-- 	label = "Misc Control",
	-- 	hover = "Change Menu Misc 3 to Menu Misc 4 if necessary",
	-- 	options = {
	-- 		{
	-- 			description = "3",
	-- 			data = 3
	-- 		},
	-- 		{
	-- 			description = "4",
	-- 			data = 4
	-- 		}
	-- 	},
	-- 	default = 3
	-- },
	
	-- {
	-- 	name = "placer_enabled",
	-- 	label = "Enable Placer Mod",
	-- 	hover = "Choose whether you want the new building system or not.",
	-- 	options = {
	-- 		{
	-- 			description = "Yes",
	-- 			data = true
	-- 		},
	-- 		{
	-- 			description = "No",
	-- 			data = false
	-- 		}
	-- 	},
	-- 	default = true
	-- },
	
	-- {
	-- 	name = "item_hotkeys",
	-- 	label = "Enable Item Hotkeys",
	-- 	hover = "Press the Right Stick + the D-PAD to quickly select items (same combo + right bumper to set said items)",
	-- 	options = {
	-- 		{
	-- 			description = "Yes",
	-- 			data = true
	-- 		},
	-- 		{
	-- 			description = "No",
	-- 			data = false
	-- 		}
	-- 	},
	-- 	default = false
	-- },
	
	{
		name = "refuel_hotkeys",
		label = "Enable Refuel Hotkeys",
		hover = "Press the Left Stick + the A/X/Y to quickly refuel equipped items",
		options = {
			{
				description = "Yes",
				data = true
			},
			{
				description = "No",
				data = false
			}
		},
		default = true
	},
	
	-- {
	-- 	name = "combatchange",
	-- 	label = "Combat Change",
	-- 	hover = "Enable the changes the mod does to attack with a controller",
	-- 	options = {
	-- 		{
	-- 			description = "Yes",
	-- 			data = true
	-- 		},
	-- 		{
	-- 			description = "No",
	-- 			data = false
	-- 		}
	-- 	},
	-- 	default = true
	-- },
}
