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

name = "Better Gamepad UX" -- "Better Gamepad User Experience"
description = Language_En and [[
* It's Best to Keep the Default Control Settings in the Settings.
* Setting Separated Backpack Layout while Using Gamepad
* Move Camera with ]]..GamepadButtons.Left_Bumper..[[ and ]]..GamepadButtons.Right_Thumb_Left..GamepadButtons.Right_Thumb_Up..GamepadButtons.Right_Thumb_Right..GamepadButtons.Right_Thumb_Down..[[ 
* Move Action Point with ]]..GamepadButtons.Right_Bumper..[[ and ]]..GamepadButtons.Right_Thumb_Left..GamepadButtons.Right_Thumb_Up..GamepadButtons.Right_Thumb_Right..GamepadButtons.Right_Thumb_Down..[[ 
* Select Items in the Inventroy Bar with ]]..GamepadButtons.Right_Trigger..[[ 
* Move Items Between Opened Containers with ]]..GamepadButtons.Right_Bumper..[[ and ]]..GamepadButtons.DPad_Left..GamepadButtons.DPad_Right..[[ 
* Lock Attack Target with Force Button(]]..GamepadButtons.Left_Bumper..[[ by Default) and Examine Button ]]..GamepadButtons.Button_Y..[[ 
* Attack Friendly Creatures with Force Button(]]..GamepadButtons.Left_Bumper..[[ by Default) and Attack Button ]]..GamepadButtons.Button_X..[[ 
* Trigger the Same Function as the Space Bar on the Keyboard with ]]..GamepadButtons.Left_Bumper..[[ ]]..GamepadButtons.Right_Bumper..[[ and Action Button ]]..GamepadButtons.Button_A..[[ 
* Teleport with Force Button(]]..GamepadButtons.Left_Bumper..[[ by Default) and AltAction Button ]]..GamepadButtons.Button_B..[[ 
]] or [[
* 开启本Mod后，最好将系统设置中的控制器设置保持默认。
* 在使用手柄时，也可以在系统设置中设置背包布局了
* 使用 ]]..GamepadButtons.Left_Bumper..[[ 加 ]]..GamepadButtons.Right_Thumb_Left..GamepadButtons.Right_Thumb_Up..GamepadButtons.Right_Thumb_Right..GamepadButtons.Right_Thumb_Down..[[ 移动视角
* 使用 ]]..GamepadButtons.Right_Bumper..[[ 加 ]]..GamepadButtons.Right_Thumb_Left..GamepadButtons.Right_Thumb_Up..GamepadButtons.Right_Thumb_Right..GamepadButtons.Right_Thumb_Down..[[ 移动操作目标点
* 使用 ]]..GamepadButtons.Right_Trigger..[[ 从物品栏中选取物品
* 使用 ]]..GamepadButtons.Right_Bumper..[[ 加 ]]..GamepadButtons.DPad_Left..GamepadButtons.DPad_Right..[[ 在打开的容器之间移动物品
* 使用强制按钮（默认为 ]]..GamepadButtons.Left_Bumper..[[ ）加检查按钮 ]]..GamepadButtons.Button_Y..[[ 锁定攻击目标
* 使用强制按钮（默认为 ]]..GamepadButtons.Left_Bumper..[[ ）加攻击按钮 ]]..GamepadButtons.Button_X..[[ 攻击友好生物
* 使用 ]]..GamepadButtons.Left_Bumper..[[ 加 ]]..GamepadButtons.Right_Bumper..[[ 加动作按钮 ]]..GamepadButtons.Button_A..[[ 实现与按下键盘空格键一样的功能
* 使用强制按钮（默认为 ]]..GamepadButtons.Left_Bumper..[[ ）加副动作按钮 ]]..GamepadButtons.Button_B..[[ 进行传送等操作
]]

author = "程小黑OvO"
version = "0.1.4"
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
	{
		name = "attack_all_direction",
		label = Language_En and "Allow Attack Targets Behind" or "允许攻击身后的目标",
		hover = Language_En and "Allow Attack All Targets Nearby Even though it Behind You." or "允许攻击角色附近的所有目标，即使目标在角色的身后",
		options = {
			{
				description = "Yes (Default)",
				data = true,
				hover = Language_En and "Now You Can Attack All Targets Nearby." or "现在你可以攻击到你附近的所有目标了",
			},
			{
				description = "No",
				data = false,
				hover = Language_En and "Now You Can Only Attack Targets you're facing" or "现在你只能攻击到你面前的目标",
			}
		},
		default = true
	},

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
		name = "force_space",
		label = Language_En and "Force Space Actions" or "强制使用空格键",
		hover = Language_En and "Hold Both Bumper Button ( "..GamepadButtons.Left_Bumper.." and "..GamepadButtons.Right_Bumper.." ) and Press "..GamepadButtons.Button_A.." to Interact with The World Just as Press Space Button."
							or  "同时按住两个肩键 ( "..GamepadButtons.Left_Bumper.." 和 "..GamepadButtons.Right_Bumper.." )，然后按下 "..GamepadButtons.Button_A.." 实现与按下键盘空格键一样的功能",
		options = {
			{ description = "Yes (Default)", data = true,  hover = Language_En and "Enabled." or "启用"},
			{ description = "No",            data = false, hover = Language_En and "Disable." or "不启用"},
		},
		default = true
	},

	{name = "Title", label = Language_En and "Shortcut Key Mappings" or "快捷键映射", options = {{description = "", data = ""}}, default = ""},
	{
		name = "MAPPING_LB_LT",
		label = Language_En and GamepadButtons.Left_Bumper.."+"..GamepadButtons.Left_Trigger.."to Quick Use"
							or  GamepadButtons.Left_Bumper.."+"..GamepadButtons.Left_Trigger.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_RB_LT",
		label = Language_En and GamepadButtons.Right_Bumper.."+"..GamepadButtons.Left_Trigger.."to Quick Use"
							or  GamepadButtons.Right_Bumper.."+"..GamepadButtons.Left_Trigger.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_LB_RB_LT",
		label = Language_En and GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Left_Trigger.."to Quick Use"
							or  GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Left_Trigger.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_RB_RT",
		label = Language_En and GamepadButtons.Right_Bumper.."+"..GamepadButtons.Right_Trigger.."to Quick Use"
							or  GamepadButtons.Right_Bumper.."+"..GamepadButtons.Right_Trigger.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_LB_RB_RT",
		label = Language_En and GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Right_Trigger.."to Quick Use"
							or  GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Right_Trigger.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_LB_BACK",
		label = Language_En and GamepadButtons.Left_Bumper.."+"..GamepadButtons.Back.."to Quick Use"
							or  GamepadButtons.Left_Bumper.."+"..GamepadButtons.Back.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_RB_BACK",
		label = Language_En and GamepadButtons.Right_Bumper.."+"..GamepadButtons.Back.."to Quick Use"
							or  GamepadButtons.Right_Bumper.."+"..GamepadButtons.Back.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_LB_RB_BACK",
		label = Language_En and GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Back.."to Quick Use"
							or  GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Back.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_LB_START",
		label = Language_En and GamepadButtons.Left_Bumper.."+"..GamepadButtons.Start.."to Quick Use"
							or  GamepadButtons.Left_Bumper.."+"..GamepadButtons.Start.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_RB_START",
		label = Language_En and GamepadButtons.Right_Bumper.."+"..GamepadButtons.Start.."to Quick Use"
							or  GamepadButtons.Right_Bumper.."+"..GamepadButtons.Start.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_LB_RB_START",
		label = Language_En and GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Start.."to Quick Use"
							or  GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Start.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_LB_LSTICK",
		label = Language_En and GamepadButtons.Left_Bumper.."+"..GamepadButtons.Left_Stick.."to Quick Use"
							or  GamepadButtons.Left_Bumper.."+"..GamepadButtons.Left_Stick.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_RB_LSTICK",
		label = Language_En and GamepadButtons.Right_Bumper.."+"..GamepadButtons.Left_Stick.."to Quick Use"
							or  GamepadButtons.Right_Bumper.."+"..GamepadButtons.Left_Stick.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_LB_RB_LSTICK",
		label = Language_En and GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Left_Stick.."to Quick Use"
							or  GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Left_Stick.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_LB_RSTICK",
		label = Language_En and GamepadButtons.Left_Bumper.."+"..GamepadButtons.Right_Stick.."to Quick Use"
							or  GamepadButtons.Left_Bumper.."+"..GamepadButtons.Right_Stick.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_RB_RSTICK",
		label = Language_En and GamepadButtons.Right_Bumper.."+"..GamepadButtons.Right_Stick.."to Quick Use"
							or  GamepadButtons.Right_Bumper.."+"..GamepadButtons.Right_Stick.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_LB_RB_RSTICK",
		label = Language_En and GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Right_Stick.."to Quick Use"
							or  GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Right_Stick.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_LB_UP",
		label = Language_En and GamepadButtons.Left_Bumper.."+"..GamepadButtons.DPad_Up.."to Quick Use"
							or  GamepadButtons.Left_Bumper.."+"..GamepadButtons.DPad_Up.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_RB_UP",
		label = Language_En and GamepadButtons.Right_Bumper.."+"..GamepadButtons.DPad_Up.."to Quick Use"
							or  GamepadButtons.Right_Bumper.."+"..GamepadButtons.DPad_Up.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
	{
		name = "MAPPING_LB_RB_UP",
		label = Language_En and GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.DPad_Up.."to Quick Use"
							or  GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.DPad_Up.."快捷使用",
		hover = Language_En and "Mapping an Inventory Slot Number for this Shortcut Key." or "为该快捷键映射一个物品栏格子编号",
		options = {
			{ description = "None",          data = false, hover = ""},
			{ description = "Inv 1 Item",    data = 1,     hover = ""},
			{ description = "Inv 2 Item",    data = 2,     hover = ""},
			{ description = "Inv 3 Item",    data = 3,     hover = ""},
			{ description = "Inv 4 Item",    data = 4,     hover = ""},
			{ description = "Inv 5 Item",    data = 5,     hover = ""},
			{ description = "Inv 6 Item",    data = 6,     hover = ""},
			{ description = "Inv 7 Item",    data = 7,     hover = ""},
			{ description = "Inv 8 Item",    data = 8,     hover = ""},
			{ description = "Inv 9 Item",    data = 9,     hover = ""},
			{ description = "Inv 10 Item",   data = 10,    hover = ""},
			{ description = "Inv 11 Item",   data = 11,    hover = ""},
			{ description = "Inv 12 Item",   data = 12,    hover = ""},
			{ description = "Inv 13 Item",   data = 13,    hover = ""},
			{ description = "Inv 14 Item",   data = 14,    hover = ""},
			{ description = "Inv 15 Item",   data = 15,    hover = ""},
		},
		default = false
	},
}
