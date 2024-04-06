local lstick = "\238\128\134"
local bbutton = "\238\128\129"
local bumperL = "\238\128\135"
local bumperR = "\238\128\138"
local triggerL = "\238\128\136"
local triggerR = "\238\128\139"
name = "Better Gamepad Experience"
description = [[ 
	Feature One: Lock Target while Examine and Allow Extra Actions
]]
author = "Change"
version = "0.1.0"
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
	{
		name = "invert_rotation",
		label = "Swap RotLeft and RotRight",
		hover = "Invert \"How the Camera Rotates\" (Not Include Map Screen)",
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
}
