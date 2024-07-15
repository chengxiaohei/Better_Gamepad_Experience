local Language_En = locale ~= "zh" and locale ~= "zht" and locale ~= "zhr"

local GamepadButtons = {
	-- Digital
	DPad_Up      = "\238\128\143",--"DPad Up"
	DPad_Down    = "\238\128\140",--"DPad Down"
	DPad_Left    = "\238\128\141",--"DPad Left",
	DPad_Right   = "\238\128\142",--"DPad Right"
	Start        = "\238\128\132",--"Start",
	Back         = "\238\128\133",--"Back",
	Left_Stick   = "\238\128\134",--"Left Stick"
	Right_Stick  = "\238\128\137",--"Right Stick"
	Left_Bumper	 = "\238\128\135",--"Left Bumper",
	Right_Bumper = "\238\128\138",--"Right Bumper"
	Button_A     = "\238\128\128",--"Button A",
	Button_B     = "\238\128\129",--"Button B",
	Button_X     = "\238\128\130",--"Button X",
	Button_Y     = "\238\128\131",--"Button Y",
	-- Analog
	Left_Thumb_Left   = "\238\128\146",--"Left Thumb Left",
	Left_Thumb_Right  = "\238\128\147",--"Left Thumb Right",
	Left_Thumb_Down   = "\238\128\145",--"Left Thumb Down",
	Left_Thumb_Up     = "\238\128\144",--"Left Thumb Up",
	Right_Thumb_Left  = "\238\128\150",--"Right Thumb Left",
	Right_Thumb_Right = "\238\128\151",--"Right Thumb Right",
	Right_Thumb_Down  = "\238\128\149",--"Right Thumb Down",
	Right_Thumb_Up    = "\238\128\148",--"Right Thumb Up",
	Left_Trigger      = "\238\128\136",--"Left Trigger",
	Right_Trigger     = "\238\128\139",--"Right Trigger",
}

name = "Improved Gamepad UX" -- "Better Gamepad Experience"
description = [[ 
	Feature One: Lock Target while Examine and Allow Extra Actions
]]
author = "Change"
version = "0.1.0"
forumthread = "https://github.com/chengxiaohei/Better_Gamepad_Experience"
icon_atlas = "modicon.xml"
icon = "modicon.tex"
client_only_mod = true
all_clients_require_mod = false
dont_starve_compatible = true
reign_of_giants_compatible = true
dst_compatible = true
api_version = 10

configuration_options = {
	{name = "Title", label = Language_En and "Camera Control Settings" or "小地图视角旋转设置", options = {{description = "", data = ""}}, default = ""},
	{
		name = "change_mapscreen_rotation",
		label = Language_En and "Change Camera Rotation" or "更改视角旋转控制按钮",
		hover = Language_En and "Setting Camera Rotation Control Button by Setting Here, Setting Zoom Control Button in Options->Controls->Map Zoom In / Map Zoom Out."
							or  "在这里设置视角旋转控制按钮，在选项->控制->地图放大/地图缩小中设置地图缩放控制按钮。",
		options = {
			{
				description = "Yes (Default)",
				data = true,
				hover = Language_En and "Use "..GamepadButtons.Left_Bumper.." to Rot Left, Use "..GamepadButtons.Right_Bumper.." to Rot Right."
									or  "使用 "..GamepadButtons.Left_Bumper.." 向左旋转视角, 使用 "..GamepadButtons.Right_Bumper.." 向右旋转视角。"
			},
			{
				description = "No",
				data = false,
				hover = Language_En and "Use "..GamepadButtons.Left_Bumper.." to Rot Right, Use "..GamepadButtons.Right_Bumper.." to Rot Left."
									or  "使用 "..GamepadButtons.Left_Bumper.." 向右旋转视角, 使用 "..GamepadButtons.Right_Bumper.." 向左旋转视角。"
			},
		},
		default = true
	},

	{name = "Title", label = "",                                              options = {{description = "", data = ""}}, default = ""},
	{name = "Title", label = Language_En and "Display Settings" or "显示设置", options = {{description = "", data = ""}}, default = ""},
	{
		name = "show_map_widget",
		label = Language_En and "Show Map Widget" or "显示地图按钮控件",
		hover = Language_En and "Show Map Widget." or "显示地图按钮控件。",
		options = {
			{ description = "Yes (Default)", data = true,  hover = Language_En and "Show." or "显示"},
			{ description = "No",            data = false, hover = Language_En and "Hide as Before." or "隐藏"},
		},
		default = true
	},
	{
		name = "show_self_inspect",
		label = Language_En and "Show Self Inspect" or "显示自我检查按钮",
		hover = Language_En and "Show Self Inspect Button in Inventory Bar." or "显示物品栏中的自我检查按钮。",
		options = {
			{ description = "Yes (Default)", data = true,  hover = Language_En and "Show." or "显示"},
			{ description = "No",            data = false, hover = Language_En and "Hide as Before." or "隐藏"},
		},
		default = true
	},

	{name = "Title", label = "",                                                         options = {{description = "", data = ""}}, default = ""},
	{name = "Title", label = Language_En and "Player Control Settings" or "角色控制设置", options = {{description = "", data = ""}}, default = ""},
	{
		name = "change_craftingmenu",
		label = Language_En and "Change Crafting Menu" or "修改建造栏控制方式",
		hover = Language_En and "Allow Interactions with The World while the Crafting Menu is Open by Change Crafting Menu Control Button."
							or  "允许在建造栏打开的情况下，角色仍然可以与世界交互。",
		options = {
			{
				description = "Yes (Default)",
				data = true,
				hover = Language_En and "Use "..GamepadButtons.DPad_Up.." "..GamepadButtons.DPad_Down.." "..GamepadButtons.DPad_Left.." "..GamepadButtons.DPad_Right.." Instead."
									or "使用 "..GamepadButtons.DPad_Up.." "..GamepadButtons.DPad_Down.." "..GamepadButtons.DPad_Left.." "..GamepadButtons.DPad_Right,
			},
			{
				description = "No",
				data = false,
				hover = Language_En and "Use "..GamepadButtons.Button_A.." "..GamepadButtons.Button_B.." "..GamepadButtons.Button_X.." "..GamepadButtons.Button_Y.." as Before."
									or  "使用 "..GamepadButtons.Button_A.." "..GamepadButtons.Button_B.." "..GamepadButtons.Button_X.." "..GamepadButtons.Button_Y,
			},

		},
		default = true
	},
	{
		name = "change_wheel",
		label = Language_En and "Change Skill Wheel" or "修改角色技能轮盘控制方式",
		hover = Language_En and "Allow Interactions with The World while the Skill Wheel is Open by Change Skill Wheel Control Button."
							or  "允许在角色技能轮盘打开的情况下，角色仍然可以与世界交互。",
		options = {
			{
				description = "Yes (Default)",
				data = true,
				hover = Language_En and "Use "..GamepadButtons.DPad_Down.." "..GamepadButtons.DPad_Right.." Instead."
									or "使用 "..GamepadButtons.DPad_Down.." "..GamepadButtons.DPad_Right
			},
			{
				description = "No",
				data = false,
				hover = Language_En and "Use "..GamepadButtons.Button_A.." "..GamepadButtons.Button_B.." as Before."
									or "使用 "..GamepadButtons.Button_A.." "..GamepadButtons.Button_B
			},
		},
		default = true
	},
	{
		name = "forbid_inspect_self",
		label = Language_En and "Forbid Inspect Self" or "禁止检查自我",
		hover = Language_En and "In Case You are Troubled by Pop-up Inspect Screen From Time to Time." or "检查自我界面时不时弹出，让我们关掉它吧。",
		options = {
			{
				description = "Yes (Default)",
				data = true,
				hover = Language_En and "You Can Still Inspect Self On the Player Status Screen."
									or "你仍然可以在角色状态页面检查自我。"
			},
			{
				description = "No",
				data = false,
				hover = Language_En and "Just Use Examine Button ( "..GamepadButtons.Button_Y.." ) to Insepct Self as Before."
									or  "像以前一样，使用检查按键 ( "..GamepadButtons.Button_Y.." ) 检查自我。"
			},
		},
		default = true
	},

	{name = "Title", label = "",                                                        options = {{description = "", data = ""}}, default = ""},
	{name = "Title", label = Language_En and "Force Control Settings" or "强制操作设置", options = {{description = "", data = ""}}, default = ""},
	{
		name = "enable_force_control",
		label = Language_En and "Force Control Button" or "强制操作按钮",
		hover = Language_En and "Setting Force Control Button." or "设置强制操作按钮。",
		options = {
			{ description = GamepadButtons.Left_Bumper.." (Default)", data = "left",  hover = Language_En and "Setting "..GamepadButtons.Left_Bumper.." as Force Control Button." or "设置 "..GamepadButtons.Left_Bumper.." 作为强制操作按键"},
			{ description = GamepadButtons.Right_Bumper,              data = "right", hover = Language_En and "Setting "..GamepadButtons.Right_Bumper.." as Force Control Button." or "设置 "..GamepadButtons.Right_Bumper.." 作为强制操作按键"},
			{ description = "None",                                   data = false,   hover = Language_En and "Disable Force Control." or "关闭强制操作功能"},
		},
		default = "left"
	},
	{
		name = "force_attack_target",
		label = Language_En and "Force Attack" or "强制攻击",
		hover = Language_En and "Hold Force Button ( "..GamepadButtons.Left_Bumper.." or "..GamepadButtons.Right_Bumper.." ) and Press "..GamepadButtons.Button_X.." to Force Attack Friendly Creatures or Wall."
							or  "按住强制操作按钮 ( "..GamepadButtons.Left_Bumper.." 或 "..GamepadButtons.Right_Bumper.." )，然后按下 "..GamepadButtons.Button_X.." 按钮强制攻击友好生物或墙体。",
		options = {
			{ description = "Yes (Default)", data = true,  hover = Language_En and "Enabled." or "启用。"},
			{ description = "No",            data = false, hover = Language_En and "Just Attack Every Creatures or Wall as Before." or "像之前一样直接攻击生物或墙。"},
		},
		default = true
	},
	{
		name = "force_lock_attack_target",
		label = Language_En and "Force Lock Attack Target" or "强制锁定攻击目标",
		hover = Language_En and "Hold Force Button ( "..GamepadButtons.Left_Bumper.." or "..GamepadButtons.Right_Bumper.." ) and Press "..GamepadButtons.Button_Y.." to Force Lock Attackable Target."
							or  "按住强制操作按钮 ( "..GamepadButtons.Left_Bumper.." 或 "..GamepadButtons.Right_Bumper.." )，然后按下 "..GamepadButtons.Button_Y.." 按钮强制锁定攻击目标。",
		options = {
			{ description = "Yes (Default)", data = true,  hover = Language_En and "Enabled." or "启用"},
			{ description = "No",            data = false, hover = Language_En and "Lock Attack Target by Holding "..GamepadButtons.Button_Y.." as Before." or "像之前一样长按 "..GamepadButtons.Button_Y.." 按键锁定攻击目标。"},
		},
		default = true
	},
	{
		name = "force_ground_actions",
		label = Language_En and "Force Ground Actions" or "强制地面施法动作",
		hover = Language_En and "Hold Force Button ( "..GamepadButtons.Left_Bumper.." or "..GamepadButtons.Right_Bumper.." ) and Press "..GamepadButtons.Button_B.." to Force Preform Toss/Cast/Teleport/Play/... Actions."
							or  "按住强制操作按钮 ( "..GamepadButtons.Left_Bumper.." 或 "..GamepadButtons.Right_Bumper.." )，然后按下 "..GamepadButtons.Button_B.." 按钮强制执行扔、投、传送、演奏等地面施法动作。",
		options = {
			{ description = "Yes (Default)", data = true,  hover = Language_En and "Enabled." or "启用"},
			{ description = "No",            data = false, hover = Language_En and "Just Preform Ground Actions as Before." or "像之前一样直接执行地面施法动作。"},
		},
		default = true
	},
	{
		name = "force_pickup_teeth_trap",
		label = Language_En and "Force Pickup Teeth Trap" or "强制捡起狗牙陷阱",
		hover = Language_En and "Hold Force Button ( "..GamepadButtons.Left_Bumper.." or "..GamepadButtons.Right_Bumper.." ) and Press "..GamepadButtons.Button_A.." to Force Pickup Teeth Trap."
							or  "按住强制操作按钮 ( "..GamepadButtons.Left_Bumper.." 或 "..GamepadButtons.Right_Bumper.." )，然后按下 "..GamepadButtons.Button_A.." 按钮强行捡起狗牙陷阱",
		options = {
			{ description = "Yes (Default)", data = true,  hover = Language_En and "Enabled." or "启用"},
			{ description = "No",            data = false, hover = Language_En and "Just Pickup Teeth Trap as Before." or "像之前一样直接捡起狗牙陷阱"},
		},
		default = true
	},
	{
		name = "force_pickup",
		label = Language_En and "Force Pickup Action" or "强制拾起动作",
		hover = Language_En and "You Can Perform Only the Pickup Action by Holding Force Button ( "..GamepadButtons.Left_Bumper.." or "..GamepadButtons.Right_Bumper.." or Both) and Press "..GamepadButtons.Button_A.." ."
							or  "当按住强制操作按钮 ( "..GamepadButtons.Left_Bumper.." 或 "..GamepadButtons.Right_Bumper.." 或两者都按下 )，然后按下 "..GamepadButtons.Button_A.." 按钮强制执行拾起操作。",
		options = {
			{ description = "Both (Default)", data = 2,     hover = Language_En and "Hold Both "..GamepadButtons.Left_Bumper.." and "..GamepadButtons.Right_Bumper.." ." or "同时按住 "..GamepadButtons.Left_Bumper.." 与 "..GamepadButtons.Right_Bumper.." 。"},
			{ description = "Yes",            data = 1,     hover = Language_En and "Hold Force Button ( "..GamepadButtons.Left_Bumper.." or "..GamepadButtons.Right_Bumper.." )." or "按住强制操作按钮 ( "..GamepadButtons.Left_Bumper.." 或 "..GamepadButtons.Right_Bumper.." )。"},
			{ description = "No",             data = false, hover = Language_En and "Just Interact with The World as Before." or "像之前一样直接与世界交互即可。"},
		},
		default = 2
	}
}
