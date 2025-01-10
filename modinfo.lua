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

local MappingOptions = {
	{ description = "None",                                               data = false,  hover = ""},
	{ description = Language_En and "Inv 1 Item"     or "一号格子物品",    data = 1,      hover = ""},
	{ description = Language_En and "Inv 2 Item"     or "二号格子物品",    data = 2,      hover = ""},
	{ description = Language_En and "Inv 3 Item"     or "三号格子物品",    data = 3,      hover = ""},
	{ description = Language_En and "Inv 4 Item"     or "四号格子物品",    data = 4,      hover = ""},
	{ description = Language_En and "Inv 5 Item"     or "五号格子物品",    data = 5,      hover = ""},
	{ description = Language_En and "Inv 6 Item"     or "六号格子物品",    data = 6,      hover = ""},
	{ description = Language_En and "Inv 7 Item"     or "七号格子物品",    data = 7,      hover = ""},
	{ description = Language_En and "Inv 8 Item"     or "八号格子物品",    data = 8,      hover = ""},
	{ description = Language_En and "Inv 9 Item"     or "九号格子物品",    data = 9,      hover = ""},
	{ description = Language_En and "Inv 10 Item"    or "十号格子物品",    data = 10,     hover = ""},
	{ description = Language_En and "Inv 11 Item"    or "十一号格子物品",  data = 11,     hover = ""},
	{ description = Language_En and "Inv 12 Item"    or "十二号格子物品",  data = 12,     hover = ""},
	{ description = Language_En and "Inv 13 Item"    or "十三号格子物品",  data = 13,     hover = ""},
	{ description = Language_En and "Inv 14 Item"    or "十四号格子物品",  data = 14,     hover = ""},
	{ description = Language_En and "Inv 15 Item"    or "十五号格子物品",  data = 15,     hover = ""},
	{ description = Language_En and "Hand Equipment" or "手部装备物品",    data = -1,     hover = ""},
	{ description = Language_En and "Body Equipment" or "身体装备物品",    data = -2,     hover = ""},
	{ description = Language_En and "Head Equipment" or "头部装备物品",    data = -3,     hover = ""},
}
local MappingHoverText = Language_En and "Mapping an Inventory or Equipment Slot for this Shortcut Key." or "为该快捷键映射一个物品栏或装备栏格子"

name = "Better Gamepad UX" -- "Better Gamepad User Experience"
description = Language_En and [[
* It's Best to Keep the Default Control Settings in the Settings.
* Setting Separated Backpack Layout while Using Gamepad
* Move Camera with ]]..GamepadButtons.Left_Bumper..[[ and ]]..GamepadButtons.Right_Thumb_Left..GamepadButtons.Right_Thumb_Up..GamepadButtons.Right_Thumb_Right..GamepadButtons.Right_Thumb_Down..[[ 
* Move Action Point with ]]..GamepadButtons.Right_Bumper..[[ and ]]..GamepadButtons.Right_Thumb_Left..GamepadButtons.Right_Thumb_Up..GamepadButtons.Right_Thumb_Right..GamepadButtons.Right_Thumb_Down..[[, Restore to Default with ]]..GamepadButtons.Right_Bumper..[[ and ]]..GamepadButtons.Right_Stick..[[ 
* Select Items in the Inventroy Bar with ]]..GamepadButtons.Right_Trigger..[[ 
* Move Items Between Opened Containers with ]]..GamepadButtons.Right_Bumper..[[ and ]]..GamepadButtons.DPad_Left..GamepadButtons.DPad_Right..[[ 
* Attack Friendly Creatures with Force Button ]]..GamepadButtons.Left_Bumper..[[ and Attack Button ]]..GamepadButtons.Button_X..[[ 
* Teleport with Force Button ]]..GamepadButtons.Left_Bumper..[[ and AltAction Button ]]..GamepadButtons.Button_B..[[ 
* While Focus on Crafting Menu Pinbar, Use ]]..GamepadButtons.DPad_Left..GamepadButtons.DPad_Right..[[ to Switch Skins and Use ]]..GamepadButtons.Right_Bumper..[[ + ]]..GamepadButtons.DPad_Left..GamepadButtons.DPad_Right..[[ to Switch Pages
* Customize your Shortcut Key Mapping
]] or [[
* 开启本Mod后，最好将系统设置中的控制器设置保持默认。
* 在使用手柄时，也可以在系统设置中设置背包布局了
* 使用 ]]..GamepadButtons.Left_Bumper..[[ 加 ]]..GamepadButtons.Right_Thumb_Left..GamepadButtons.Right_Thumb_Up..GamepadButtons.Right_Thumb_Right..GamepadButtons.Right_Thumb_Down..[[ 移动视角
* 使用 ]]..GamepadButtons.Right_Bumper..[[ 加 ]]..GamepadButtons.Right_Thumb_Left..GamepadButtons.Right_Thumb_Up..GamepadButtons.Right_Thumb_Right..GamepadButtons.Right_Thumb_Down..[[ 移动操作目标点，使用 ]]..GamepadButtons.Right_Bumper..[[ 加 ]]..GamepadButtons.Right_Stick..[[ 来恢复至默认状态
* 使用 ]]..GamepadButtons.Right_Trigger..[[ 从物品栏中选取物品
* 使用 ]]..GamepadButtons.Right_Bumper..[[ 加 ]]..GamepadButtons.DPad_Left..GamepadButtons.DPad_Right..[[ 在打开的容器之间移动物品
* 使用强制按钮 ]]..GamepadButtons.Left_Bumper..[[ 加攻击按钮 ]]..GamepadButtons.Button_X..[[ 攻击友好生物
* 使用强制按钮 ]]..GamepadButtons.Left_Bumper..[[ 加副动作按钮 ]]..GamepadButtons.Button_B..[[ 进行传送等操作
* 当光标在左侧的快捷制作栏上时，使用]]..GamepadButtons.DPad_Left..GamepadButtons.DPad_Right..[[ 切换皮肤，使用 ]]..GamepadButtons.Right_Bumper..[[ 加 ]]..GamepadButtons.DPad_Left..GamepadButtons.DPad_Right..[[ 切换页面
* 自定义快捷键映射
]]

author = "程小黑OvO"
version = "0.1.22"
forumthread = "https://github.com/chengxiaohei/Better_Gamepad_Experience"
icon_atlas = "modicon.xml"
icon = "modicon.tex"
client_only_mod = true
all_clients_require_mod = false
dont_starve_compatible = true
reign_of_giants_compatible = true
dst_compatible = true
api_version = 10
priority = 100

configuration_options = {
	{name = "Title", label = Language_En and "Display Settings" or "显示设置", options = {{description = "", data = ""}}, default = ""},
	{
		name = "language",
		label = Language_En and "Language" or "语言",
		hover = Language_En and "Setting Language." or "设置语言。",
		options = {
			{ description = "English", data = true,  hover = Language_En and "English." or "英文"},
			{ description = "Chinese", data = false, hover = Language_En and "Chinese." or "中文"},
		},
		default = true
	},
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
		label = Language_En and "Show Self Inspect Button" or "显示自我检查按钮",
		hover = Language_En and "Show Self Inspect Button in Inventory Bar." or "显示物品栏中的自我检查按钮。",
		options = {
			{ description = "Yes (Default)", data = true,  hover = Language_En and "Show." or "显示"},
			{ description = "No",            data = false, hover = Language_En and "Hide as Before." or "隐藏"},
		},
		default = true
	},
	{
		name = "show_backpack_widget",
		label = Language_En and "Show Backpack Widget" or "显示背包控件",
		hover = Language_En and "Setting Backpack Layout to Separated in Settings Page of Original Game to Show Backpace Widget on the Right of Screen." or "在原版游戏的设置页面将更改背包布局为分开，即可在屏幕右侧显示背包控件。",
		options = {
			{
				description = "None (Default)",
				data = false,
				hover = ""
			},
		},
		default = false
	},
	{
		name = "hide_inventory_hint",
		label = Language_En and "Hide Inventory Bar Hint Message" or "隐藏物品栏物品的提示信息",
		hover = Language_En and "Hide Inventory Bar Hint Message" or "隐藏物品栏物品的提示信息",
		options = {
			{ description = "No (Default)", data = "none", hover = Language_En and "Show." or "显示"},
			{ description = "Action Text",  data = "part", hover = Language_En and "Show Name and Icons" or "显示名称和图标"},
			{ description = "Yes",          data = "all",  hover = Language_En and "Hide." or "隐藏"},
		},
		default = "none"
	},
	{
		name = "hide_world_item_hint",
		label = Language_En and "Hide World Items Hint Message" or "隐藏世界物品的提示信息",
		hover = Language_En and "Hide World Items Hint Message" or "隐藏世界物品的提示信息",
		options = {
			{ description = "No (Default)", data = "none",    hover = Language_En and "Show." or "显示"},
			{ description = "Action Text",  data = "part", hover = Language_En and "Show Name and Icons" or "显示名称和图标"},
			{ description = "Yes",          data = "all",     hover = Language_En and "Hide." or "隐藏"},
		},
		default = "none"
	},

	{name = "Title", label = Language_En and "Camera Control Settings" or "视角控制设置", options = {{description = "", data = ""}}, default = ""},
	{
		name = "reverse_rotation_hud_screen",
		label = Language_En and "Reverse Camera Rotation" or "反转视角旋转",
		hover = Language_En and "Reverse Camera Rotation" or "反转视角旋转",
		options = {
			{
				description = "No (Default)",
				data = false,
				hover = Language_En and "Use "..GamepadButtons.Left_Bumper.."and"..GamepadButtons.Right_Thumb_Left.." Rotate Camera Left, Use "..GamepadButtons.Left_Bumper.."and"..GamepadButtons.Right_Thumb_Right.." Rotate Camera Right."
									or "使用 "..GamepadButtons.Left_Bumper.." 加 "..GamepadButtons.Right_Thumb_Left.." 向左旋转视角，使用 "..GamepadButtons.Left_Bumper.." 加 "..GamepadButtons.Right_Thumb_Right.." 向右旋转视角。"
			},
			{
				description = "Yes",
				data = true,
				hover = Language_En and "Use "..GamepadButtons.Left_Bumper.." and "..GamepadButtons.Right_Thumb_Right.." Rotate Camera Left, Use "..GamepadButtons.Left_Bumper.." and "..GamepadButtons.Right_Thumb_Left.." Rotate Camera Right."
									or "使用 "..GamepadButtons.Left_Bumper.." 加 "..GamepadButtons.Right_Thumb_Right.." 向左旋转视角，使用 "..GamepadButtons.Left_Bumper.." 加 "..GamepadButtons.Right_Thumb_Left.." 向右旋转视角。"
			},
		},
		default = false
	},
	{
		name = "reverse_rotation_map_screen",
		label = Language_En and "Reverse Map Rotation" or "反转地图旋转",
		hover = Language_En and "Reverse Map Rotation" or "反转地图旋转",
		options = {
			{
				description = "No (Default)",
				data = false,
				hover = Language_En and "Use "..GamepadButtons.Left_Bumper.." Rotate Map Left, Use "..GamepadButtons.Right_Bumper.." Rotate Map Right."
									or "使用 "..GamepadButtons.Left_Bumper.." 向左旋转地图，使用 "..GamepadButtons.Right_Bumper.." 向右旋转地图。"
			},
			{
				description = "Yes",
				data = true,
				hover = Language_En and "Use "..GamepadButtons.Right_Bumper.." Rotate Map Left, Use "..GamepadButtons.Left_Bumper.." Rotate Map Right."
									or "使用 "..GamepadButtons.Right_Bumper.." 向左旋转地图，使用 "..GamepadButtons.Left_Bumper.." 向右旋转地图。"
			},
		},
		default = false
	},
	{
		name = "reverse_zoom_hud_screen",
		label = Language_En and "Reverse Camera Zoom" or "反转视角缩放",
		hover = Language_En and "Reverse Camera Zoom" or "反转视角缩放",
		options = {
			{
				description = "No (Default)",
				data = false,
				hover = Language_En and "Use "..GamepadButtons.Left_Bumper.." and "..GamepadButtons.Right_Thumb_Up.." Zoom In, Use "..GamepadButtons.Left_Bumper.." and "..GamepadButtons.Right_Thumb_Down.." Zoom Out."
									or "使用 "..GamepadButtons.Left_Bumper.." 加 "..GamepadButtons.Right_Thumb_Up.." 拉近视角，使用 "..GamepadButtons.Left_Bumper.." 加 "..GamepadButtons.Right_Thumb_Down.." 拉远视角。"
			},
			{
				description = "Yes",
				data = true,
				hover = Language_En and "Use "..GamepadButtons.Left_Bumper.." and "..GamepadButtons.Right_Thumb_Down.." Zoom In, Use "..GamepadButtons.Left_Bumper.." and "..GamepadButtons.Right_Thumb_Up.." Zoom Out."
									or "使用 "..GamepadButtons.Left_Bumper.." 加 "..GamepadButtons.Right_Thumb_Down.." 拉近视角，使用 "..GamepadButtons.Left_Bumper.." 加 "..GamepadButtons.Right_Thumb_Up.." 拉远视角。"
			},
		},
		default = false
	},
	{
		name = "reverse_zoom_map_screen",
		label = Language_En and "Reverse Map Zoom" or "反转地图缩放",
		hover = Language_En and "Setting in Settings Page" or "在游戏设置页面中设置即可",
		options = {
			{
				description = "None",
				data = false,
				hover = ""
			},
		},
		default = false
	},

	{name = "Title", label = Language_En and "Player Control Settings" or "角色控制设置", options = {{description = "", data = ""}}, default = ""},
	{
		name = "change_craftingmenu",
		label = Language_En and "Modify Crafting Menu Interaction" or "修改建造栏交互方式",
		hover = Language_En and "Allow Interact with The World while the Crafting Menu is Open by Modify Crafting Menu Interaction."
							or  "允许在建造栏打开的情况下，角色仍然可以与世界交互。",
		options = {
			{
				description = "Yes (Default)",
				data = true,
				hover = Language_En and "Use "..GamepadButtons.DPad_Up.." "..GamepadButtons.DPad_Down.." "..GamepadButtons.DPad_Left.." "..GamepadButtons.DPad_Right.." to Interact with Crafting Menu Instead."
									or "使用 "..GamepadButtons.DPad_Up.." "..GamepadButtons.DPad_Down.." "..GamepadButtons.DPad_Left.." "..GamepadButtons.DPad_Right.." 与建造栏交互",
			},
			{
				description = "No",
				data = false,
				hover = Language_En and "Use "..GamepadButtons.Button_A.." "..GamepadButtons.Button_B.." "..GamepadButtons.Button_X.." "..GamepadButtons.Button_Y.." to Interact with Crafting Menu as Before."
									or  "使用 "..GamepadButtons.Button_A.." "..GamepadButtons.Button_B.." "..GamepadButtons.Button_X.." "..GamepadButtons.Button_Y.." 与建造栏交互",
			},

		},
		default = true
	},
	{
		name = "change_wheel",
		label = Language_En and "Modify Skill Wheel Interaction" or "修改角色技能轮盘交互方式",
		hover = Language_En and "Allow Interact with The World while the Skill Wheel is Open by Modify Skill Wheel Interaction."
							or  "允许在角色技能轮盘打开的情况下，角色仍然可以与世界交互。",
		options = {
			{
				description = "Yes (Default)",
				data = true,
				hover = Language_En and "Use "..GamepadButtons.DPad_Down.." "..GamepadButtons.DPad_Right.." to Interact with Skill Wheel Instead."
									or "使用 "..GamepadButtons.DPad_Down.." "..GamepadButtons.DPad_Right.. "与角色技能轮盘交互",
			},
			{
				description = "No",
				data = false,
				hover = Language_En and "Use "..GamepadButtons.Button_A.." "..GamepadButtons.Button_B.." to Interact with Skill Wheel as Before."
									or "使用 "..GamepadButtons.Button_A.." "..GamepadButtons.Button_B.." 与角色技能轮盘交互",
			},
		},
		default = true
	},
	{
		name = "forbid_inspect_self",
		label = Language_En and "Forbid Inspect Self" or "禁止检查自我",
		hover = Language_En and "In Case You are Troubled by Pop-up Inspect Screen From Time to Time." or "检查自我界面时常弹出，让我们关掉它吧。",
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
				hover = Language_En and "Just Use Examine Button "..GamepadButtons.Button_Y.." to Insepct Self as Before."
									or  "像以前一样，使用检查按键 "..GamepadButtons.Button_Y.." 检查自我。"
			},
		},
		default = true
	},
	{
		name = "interact_all_direction",
		label = Language_En and "Allow Interact Targets Behind" or "允许与身后目标交互",
		hover = Language_En and "Allow Interact with All Targets Nearby Even though it Behind You." or "允许与角色附近的所有目标交互，即使目标在角色的身后",
		options = {
			{
				description = "Yes",
				data = true,
				hover = Language_En and "Now You Can Interact All Targets Nearby." or "现在你可以与你附近的所有目标交互",
			},
			{
				description = "No (Default)",
				data = false,
				hover = Language_En and "Now You Can Only Interact Targets you're facing as Before" or "现在你只能与你面前的目标交互",
			}
		},
		default = false
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
				hover = Language_En and "Now You Can Only Attack Targets you're facing as Before" or "现在你只能攻击到你面前的目标",
			}
		},
		default = true
	},
	{
		name = "interaction_target_detect_radius",
		label = Language_En and "Interact Radius" or "可交互目标检测半径",
		hover = Language_En and "Adjust the Detection Radius of Interactable Items Detection."
							or "调整检测附近可交互物品时的检测半径。",
		options = {
			{ description = "6 (Default)", data = 6,  hover = ""},
			{ description = "9",           data = 9,  hover = ""},
			{ description = "12",          data = 12, hover = ""},
			{ description = "15",          data = 15, hover = ""},
			{ description = "18",          data = 18, hover = ""},
			{ description = "21",          data = 21, hover = ""},
			{ description = "24",          data = 24, hover = ""},
			{ description = "27",          data = 27, hover = ""},
			{ description = "30",          data = 30, hover = ""},
			{ description = "33",          data = 33, hover = ""},
			{ description = "36",          data = 36, hover = ""}
		},
		default = 6
	},
	{
		name = "add_attackable_target_detect_radius",
		label = Language_En and "Attack Radius" or "可攻击目标检测半径",
		hover = Language_En and "Adjust the Detection Radius of Attackable Target Detection."
							or "调整检测附近可攻击目标时的检测半径。",
		options = {
			{ description = "4 (Default)", data = 0,  hover = ""},
			{ description = "6",           data = 2,  hover = ""},
			{ description = "8",           data = 4,  hover = ""},
			{ description = "10",          data = 6,  hover = ""},
			{ description = "12",          data = 8,  hover = ""},
			{ description = "14",          data = 10, hover = ""},
			{ description = "16",          data = 12, hover = ""},
			{ description = "18",          data = 14, hover = ""},
			{ description = "20",          data = 16, hover = ""},
			{ description = "22",          data = 18, hover = ""},
			{ description = "24",          data = 20, hover = ""},
			{ description = "26",          data = 22, hover = ""},
			{ description = "28",          data = 24, hover = ""},
			{ description = "30",          data = 26, hover = ""},
			{ description = "32",          data = 28, hover = ""},
			{ description = "34",          data = 30, hover = ""},
			{ description = "36",          data = 32, hover = ""},
		},
		default = 0
	},

	{name = "Title", label = Language_En and "Force Control Settings" or "强制操作设置", options = {{description = "", data = ""}}, default = ""},
	{
		name = "enable_force_control",
		label = Language_En and "Enable Force Control" or "强制操作",
		hover = Language_En and "Setting Force Control Button to "..GamepadButtons.Left_Bumper or "设置 "..GamepadButtons.Left_Bumper.." 为强制操作按钮。",
		options = {
			{ description = "Yes (Default)", data = true,  hover = Language_En and "Enabled." or "启用。"},
			{ description = "No"           , data = false, hover = Language_En and "Disable." or "不启用。"},
		},
		default = true
	},
	{
		name = "force_attack_target",
		label = Language_En and "Force Attack" or "强制攻击",
		hover = Language_En and "Hold Force Button ( "..GamepadButtons.Left_Bumper.." ) and Press "..GamepadButtons.Button_X.." to Force Attack Friendly Creatures or Wall."
							or  "按住强制操作按钮 ( "..GamepadButtons.Left_Bumper.." )，然后按下 "..GamepadButtons.Button_X.." 按钮强制攻击友好生物或墙体。",
		options = {
			{ description = "Yes (Default)", data = true,  hover = Language_En and "Enabled." or "启用。"},
			{ description = "No",            data = false, hover = Language_En and "Just Attack Every Creatures or Wall as Before." or "像之前一样直接攻击生物或墙。"},
		},
		default = true
	},
	{
		name = "force_ground_actions",
		label = Language_En and "Force Ground Actions" or "强制地面施法动作",
		hover = Language_En and "Hold Force Button ( "..GamepadButtons.Left_Bumper.." ) and Press "..GamepadButtons.Button_B.." to Force Preform Toss/Cast/Teleport/Play/... Actions."
							or  "按住强制操作按钮 ( "..GamepadButtons.Left_Bumper.." )，然后按下 "..GamepadButtons.Button_B.." 按钮强制执行扔、投、传送、演奏等地面施法动作。",
		options = {
			{ description = "Yes (Default)", data = true,  hover = Language_En and "Enabled." or "启用"},
			{ description = "No",            data = false, hover = Language_En and "Just Preform Ground Actions as Before." or "像之前一样直接执行地面施法动作。"},
		},
		default = true
	},
	{
		name = "force_pause",
		label = Language_En and "Force Pause Server" or "强制暂停服务器",
		hover = Language_En and "Hold Force Button ( "..GamepadButtons.Left_Bumper.." ) and Press "..GamepadButtons.Start.." to Force Pause Server."
							or  "按住强制操作按钮 ( "..GamepadButtons.Left_Bumper.." )，然后按下 "..GamepadButtons.Start.." 按钮强制暂停服务器。",
		options = {
			{ description = "Yes (Default)", data = true,  hover = Language_En and "Enabled." or "启用"},
			{ description = "No",            data = false, hover = Language_En and "Disable." or "不启用"},
		},
		default = true
	},

	{name = "Title", label = Language_En and "Shortcut Key Mappings" or "快捷键映射", options = {{description = "", data = ""}}, default = ""},
	{
		name = "MAPPING_LB_LT",
		label = Language_En and GamepadButtons.Left_Bumper.."+"..GamepadButtons.Left_Trigger.." to Quick Use"
							or  GamepadButtons.Left_Bumper.."+"..GamepadButtons.Left_Trigger.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_RB_LT",
		label = Language_En and GamepadButtons.Right_Bumper.."+"..GamepadButtons.Left_Trigger.." to Quick Use"
							or  GamepadButtons.Right_Bumper.."+"..GamepadButtons.Left_Trigger.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_LB_RB_LT",
		label = Language_En and GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Left_Trigger.." to Quick Use"
							or  GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Left_Trigger.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_RB_RT",
		label = Language_En and GamepadButtons.Right_Bumper.."+"..GamepadButtons.Right_Trigger.." to Quick Use"
							or  GamepadButtons.Right_Bumper.."+"..GamepadButtons.Right_Trigger.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_LB_RB_RT",
		label = Language_En and GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Right_Trigger.." to Quick Use"
							or  GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Right_Trigger.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_LB_BACK",
		label = Language_En and GamepadButtons.Left_Bumper.."+"..GamepadButtons.Back.." to Quick Use"
							or  GamepadButtons.Left_Bumper.."+"..GamepadButtons.Back.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_RB_BACK",
		label = Language_En and GamepadButtons.Right_Bumper.."+"..GamepadButtons.Back.." to Quick Use"
							or  GamepadButtons.Right_Bumper.."+"..GamepadButtons.Back.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_LB_RB_BACK",
		label = Language_En and GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Back.." to Quick Use"
							or  GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Back.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_LB_START",
		label = Language_En and GamepadButtons.Left_Bumper.."+"..GamepadButtons.Start.." to Quick Use"
							or  GamepadButtons.Left_Bumper.."+"..GamepadButtons.Start.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_RB_START",
		label = Language_En and GamepadButtons.Right_Bumper.."+"..GamepadButtons.Start.." to Quick Use"
							or  GamepadButtons.Right_Bumper.."+"..GamepadButtons.Start.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_LB_RB_START",
		label = Language_En and GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Start.." to Quick Use"
							or  GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Start.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_LB_LSTICK",
		label = Language_En and GamepadButtons.Left_Bumper.."+"..GamepadButtons.Left_Stick.." to Quick Use"
							or  GamepadButtons.Left_Bumper.."+"..GamepadButtons.Left_Stick.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_RB_LSTICK",
		label = Language_En and GamepadButtons.Right_Bumper.."+"..GamepadButtons.Left_Stick.." to Quick Use"
							or  GamepadButtons.Right_Bumper.."+"..GamepadButtons.Left_Stick.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_LB_RB_LSTICK",
		label = Language_En and GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Left_Stick.." to Quick Use"
							or  GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Left_Stick.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_LB_RSTICK",
		label = Language_En and GamepadButtons.Left_Bumper.."+"..GamepadButtons.Right_Stick.." to Quick Use"
							or  GamepadButtons.Left_Bumper.."+"..GamepadButtons.Right_Stick.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_LB_RB_RSTICK",
		label = Language_En and GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Right_Stick.." to Quick Use"
							or  GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Right_Stick.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_LB_UP",
		label = Language_En and GamepadButtons.Left_Bumper.."+"..GamepadButtons.DPad_Up.." to Quick Use"
							or  GamepadButtons.Left_Bumper.."+"..GamepadButtons.DPad_Up.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_RB_UP",
		label = Language_En and GamepadButtons.Right_Bumper.."+"..GamepadButtons.DPad_Up.." to Quick Use"
							or  GamepadButtons.Right_Bumper.."+"..GamepadButtons.DPad_Up.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_LB_RB_UP",
		label = Language_En and GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.DPad_Up.." to Quick Use"
							or  GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.DPad_Up.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_LB_Y",
		label = Language_En and GamepadButtons.Left_Bumper.."+"..GamepadButtons.Button_Y.." to Quick Use"
							or  GamepadButtons.Left_Bumper.."+"..GamepadButtons.Button_Y.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_RB_Y",
		label = Language_En and GamepadButtons.Right_Bumper.."+"..GamepadButtons.Button_Y.." to Quick Use"
							or  GamepadButtons.Right_Bumper.."+"..GamepadButtons.Button_Y.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
	{
		name = "MAPPING_LB_RB_Y",
		label = Language_En and GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Button_Y.." to Quick Use"
							or  GamepadButtons.Left_Bumper..GamepadButtons.Right_Bumper.."+"..GamepadButtons.Button_Y.." 快捷使用",
		hover = MappingHoverText,
		options = MappingOptions,
		default = false
	},
}
