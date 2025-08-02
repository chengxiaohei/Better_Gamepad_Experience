require "class"
local InvSlot = require "widgets/invslot"
local TileBG = require "widgets/tilebg"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local EquipSlot = require "widgets/equipslot"
local ItemTile = require "widgets/itemtile"
local Text = require "widgets/text"
local HudCompass = require "widgets/hudcompass"

local TEMPLATES = require "widgets/templates"

local HUD_ATLAS = "images/hud.xml"
local HUD2_ATLAS = "images/hud2.xml"

local HUD_CHARACTERS = 
{
    ["wanda"] = HUD2_ATLAS,
}

local W = 68
local SEP = 12
local YSEP = 8
local INTERSEP = 28

local CURSOR_STRING_DELAY = 10
local TIP_YFUDGE = 16
local HINT_UPDATE_INTERVAL = 2.0 -- once per second


AddClassPostConstruct("widgets/inventorybar", function(self)

	local OpenHint_SetString_Old = self.openhint.SetString
	self.openhint.SetString = function(_self, ...)
		OpenHint_SetString_Old(_self, "")
	end

	self.CursorLeft = function (self, ...)
		if TheInput:GetActiveControlScheme(CONTROL_SCHEME_CAM_AND_INV) == 1 and TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
			return true
		end

		if ((IsOtherModEnabled("Gesture Wheel") and GetOtherModConfig("Gesture Wheel", "RIGHTSTICK")) or
			(IsOtherModEnabled("Gesture Wheel (Chinese)") and GetOtherModConfig("Gesture Wheel (Chinese)", "RIGHTSTICK"))) and
			TheInput:IsControlPressed(CONTROL_MENU_MISC_3) then
			return true
		end

		if self.pin_nav and not self.owner.HUD.controls.craftingmenu.is_left_aligned then
			local k, slot = next(self.current_list or {})
			if slot == nil or not slot.inst:IsValid() then
				self.current_list = self.equip
			end
		end

		local active_item = self.owner.replica.inventory:GetActiveItem()

		if self:CursorNav(Vector3(-1,0,0)) then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		elseif not self.open and not active_item and not self.pin_nav and self.owner.HUD.controls.craftingmenu.is_left_aligned and
			self:PinBarNav(self.owner.HUD.controls.craftingmenu:InvNavToPin(self.active_slot, -1, 0)) then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		end
	end

	self.CursorRight = function (self, ...)
		if TheInput:GetActiveControlScheme(CONTROL_SCHEME_CAM_AND_INV) == 1 and TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
			return true
		end

		if ((IsOtherModEnabled("Gesture Wheel") and GetOtherModConfig("Gesture Wheel", "RIGHTSTICK")) or
			(IsOtherModEnabled("Gesture Wheel (Chinese)") and GetOtherModConfig("Gesture Wheel (Chinese)", "RIGHTSTICK"))) and
			TheInput:IsControlPressed(CONTROL_MENU_MISC_3) then
			return true
		end

		if self.pin_nav and self.owner.HUD.controls.craftingmenu.is_left_aligned then
			local k, slot = next(self.current_list or {})
			if slot == nil or not slot.inst:IsValid() then
				self.current_list = self.inv
			end
		end

		if self:CursorNav(Vector3(1,0,0)) then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		elseif not self.open and not self.pin_nav and not self.owner.HUD.controls.craftingmenu.is_left_aligned and
			self:PinBarNav(self.owner.HUD.controls.craftingmenu:InvNavToPin(self.active_slot, 1, 0)) then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		end
	end

	self.CursorUp = function (self, ...)
		if TheInput:GetActiveControlScheme(CONTROL_SCHEME_CAM_AND_INV) == 1 and TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
			return true
		end

		if ((IsOtherModEnabled("Gesture Wheel") and GetOtherModConfig("Gesture Wheel", "RIGHTSTICK")) or
			(IsOtherModEnabled("Gesture Wheel (Chinese)") and GetOtherModConfig("Gesture Wheel (Chinese)", "RIGHTSTICK"))) and
			TheInput:IsControlPressed(CONTROL_MENU_MISC_3) then
			return true
		end

		if self.pin_nav then
			if self:PinBarNav(self.active_slot:FindPinUp()) and self.active_slot:FindPinUp() ~= self.active_slot then
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			end
		else
			local active_item = self.owner.replica.inventory:GetActiveItem()
			if self:CursorNav(Vector3(0,1,0)) then
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			elseif not self.open and not active_item and (self.current_list == self.inv or self.current_list == self.equip) then
				-- go into the pin bar if there are no other open containers above the inventory bar
				local target_slot = self.owner.HUD.controls.craftingmenu:InvNavToPin(self.active_slot, 0, 1)
				while target_slot and target_slot.in_pinbar and target_slot:FindPinDown() and target_slot ~= target_slot:FindPinDown() do
					target_slot = target_slot:FindPinDown()
				end
				if self:PinBarNav(target_slot) then
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
				end
			end
		end
	end


	self.CursorDown = function (self, ...)
		if TheInput:GetActiveControlScheme(CONTROL_SCHEME_CAM_AND_INV) == 1 and TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
			return true
		end

		if ((IsOtherModEnabled("Gesture Wheel") and GetOtherModConfig("Gesture Wheel", "RIGHTSTICK")) or
			(IsOtherModEnabled("Gesture Wheel (Chinese)") and GetOtherModConfig("Gesture Wheel (Chinese)", "RIGHTSTICK"))) and
			TheInput:IsControlPressed(CONTROL_MENU_MISC_3) then
			return true
		end

		local pin_nav = self.pin_nav
		if pin_nav then
			local next_pin = self.active_slot:FindPinDown()
			if next_pin then
				if self:PinBarNav(next_pin) then
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
				end
			else
				self:SelectDefaultSlot()
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			end
		end
		
		if not pin_nav and self:CursorNav(Vector3(0,-1,0)) then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		end
	end

	self.GetClosestWidget = function (self, lists, pos, dir, ...)
		local closest = nil
		local closest_score = nil
		local closest_list = nil

		local x, y = pos.x, pos.y
		local dir_x, dir_y = dir.x, dir.y

		for kk, vv in pairs(lists) do
			for k,v in pairs(vv) do
				if v ~= self.active_slot then
					local vx, vy = v.inst.UITransform:GetWorldPosition()
					-- =========================================================================================== --
					-- local local_dir_x, local_dir_y = vx-x, vy-y
					local local_dir_x, local_dir_y = (2-1.5*math.abs(dir_x))*(vx-x), (2-1.5*math.abs(dir_y)) * (vy-y)
					-- local dot = VecUtil_Dot(local_dir_x, local_dir_y, dir_x, dir_y)
					local dot = VecUtil_Dot(local_dir_x, local_dir_y, dir_x, dir_y) / (VecUtil_Length(local_dir_x, local_dir_y) * VecUtil_Length(dir_x, dir_y))
					-- if dot > 0 then
					if dot > 0.2 then  -- 0.2 is a magic number
					-- =========================================================================================== --
						local score = local_dir_x * local_dir_x + local_dir_y * local_dir_y
						if not closest or score < closest_score then
							closest = v
							closest_score = score
							closest_list = vv
						end
					end
				end
			end
		end

		return closest, closest_list
	end

	local Rebuild_Old = self.Rebuild
	self.Rebuild = function(self, ...)
		TheInput_ControllerAttached_Old = TheInput.ControllerAttached
		TheInput.ControllerAttached = function (...) return false end
		Rebuild_Old(self, ...)
		TheInput.ControllerAttached = TheInput_ControllerAttached_Old
	end

	STRINGS.UI.HUD.TAKEHALF = STRINGS.UI.CONTROLSSCREEN.CONTROLS[36]
	STRINGS.UI.HUD.CHANGEBOX = STRINGS.UI.CONTROLSSCREEN.CONTROLS[37]
	STRINGS.UI.HUD.CHANGEBOXHALF = STRINGS.UI.CONTROLSSCREEN.CONTROLS[38]

	-- Not Changed
	local function GetDropActionString(doer, item)
		return BufferedAction(doer, nil, ACTIONS.DROP, item, doer:GetPosition()):GetActionString()
	end

	local SetActionStringSize = function(obj, size, hud)
		obj:SetSize(size * TheFrontEnd:GetHUDScale())
		obj.inst:ListenForEvent("continuefrompause", function() obj:SetSize(size * TheFrontEnd:GetHUDScale()) end, hud)
		obj.inst:ListenForEvent("refreshhudsize", function(hud, scale) obj:SetSize(size * scale) end, hud)
	end

	self.actionstringtitle_below = self.actionstring:AddChild(Text(TALKINGFONT, 24))
    self.actionstringtitle_below:SetColour(204/255, 180/255, 154/255, 1)
	self.actionstringbody_below = self.actionstring:AddChild(Text(TALKINGFONT, 18))
	self.actionstringbody_below:EnableWordWrap(true)

	if IsOtherModEnabled("Insight (Show Me+)") then
		if CHANGE_LANGUAGE_ENGLISH then
			self.actionstringtitle:SetSize(25)
			self.actionstringbody:SetSize(20)
			self.actionstringtitle_below = self.actionstring:AddChild(Text(TALKINGFONT, 25))
			self.actionstringbody_below = self.actionstring:AddChild(Text(TALKINGFONT, 20))
			self.fake_text = self.actionstring:AddChild(Text(TALKINGFONT, 20))
		else
			self.actionstringtitle:SetSize(31)
			self.actionstringbody:SetSize(23)
			self.actionstringtitle_below = self.actionstring:AddChild(Text(TALKINGFONT, 31))
			self.actionstringbody_below = self.actionstring:AddChild(Text(TALKINGFONT, 23))
			self.fake_text = self.actionstring:AddChild(Text(TALKINGFONT, 23))
		end
	else
		SetActionStringSize(self.actionstringtitle, 24, self.owner.HUD.inst)
		SetActionStringSize(self.actionstringbody, 18, self.owner.HUD.inst)
		SetActionStringSize(self.actionstringtitle_below, 24, self.owner.HUD.inst)
		SetActionStringSize(self.actionstringbody_below, 18, self.owner.HUD.inst)
	end

	SetTooltipColour_Old = self.SetTooltipColour
	self.SetTooltipColour = function (self, ...)
		SetTooltipColour_Old(self, ...)
		self.actionstringtitle_below:SetColour(...)
	end

	-- Numerous changes
	self.UpdateCursorText = function (self, ...)
		local Language_En = CHANGE_LANGUAGE_ENGLISH
		local inv_item = self:GetCursorItem()
		local slot_num, container = self:GetCursorSlot()
		local isreadonlycontainer = container and container.IsReadOnlyContainer and container:IsReadOnlyContainer()
		local active_item = self.cursortile ~= nil and self.cursortile.item or nil
		if inv_item ~= nil and inv_item.replica.inventoryitem == nil then
			inv_item = nil
		end
		if active_item ~= nil and active_item.replica.inventoryitem == nil then
			active_item = nil
		end
		if active_item ~= nil or inv_item ~= nil and CHANGE_HIDE_INVENTORY_BAR_HINT ~= "all" then
			local controller_id = TheInput:GetControllerID()

			if active_item ~= nil and inv_item ~= nil then
				local itemname = self:GetDescriptionString(active_item)
				self.actionstringtitle:SetString(itemname)
				if active_item:GetIsWet() then
					self:SetTooltipColour(unpack(WET_TEXT_COLOUR))
				else
					self:SetTooltipColour(unpack(RGB(204, 180, 154)))
				end
				itemname = self:GetDescriptionString(inv_item)
				self.actionstringtitle_below:SetString(itemname)
				if inv_item:GetIsWet() then
					self:SetTooltipColour(unpack(WET_TEXT_COLOUR))
				else
					self:SetTooltipColour(unpack(RGB(204, 180, 154)))
				end
			elseif active_item ~= nil then
				local itemname = self:GetDescriptionString(active_item)
				self.actionstringtitle:SetString(itemname)
				if active_item:GetIsWet() then
					self:SetTooltipColour(unpack(WET_TEXT_COLOUR))
				else
					self:SetTooltipColour(unpack(RGB(204, 180, 154)))
				end
				self.actionstringtitle_below:SetString("")
			elseif inv_item ~= nil then
				local itemname = self:GetDescriptionString(inv_item)
				self.actionstringtitle:SetString(itemname)
				if inv_item:GetIsWet() then
					self:SetTooltipColour(unpack(WET_TEXT_COLOUR))
				else
					self:SetTooltipColour(unpack(RGB(204, 180, 154)))
				end
				self.actionstringtitle_below:SetString("")
			else
				self.actionstringtitle:SetString("")
				self.actionstringtitle_below:SetString("")
			end

			local is_equip_slot = self.active_slot and self.active_slot.equipslot
			local str = {}
			local str_below = {}
			local icon = {}
			local icon_below = {}

			local left = TheInput:IsControlPressed(CHANGE_CONTROL_LEFT)
			local right = TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT)

			if active_item ~= nil and inv_item ~= nil then
				local help_string = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_EXAMINE) .. " " .. STRINGS.UI.HUD.INSPECT
				if not is_equip_slot then
					local can_take_active_item = active_item ~= nil and self.active_slot.container ~= nil and self.active_slot.container:CanTakeItemInSlot(active_item, self.active_slot.num)
					if active_item.replica.stackable ~= nil and inv_item.prefab == active_item.prefab and active_item.skinname == active_item.skinname then
						help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CHANGE_CONTROL_HOVER) .. " " .. STRINGS.ACTIONS.COMBINESTACK
						if left and active_item.replica.stackable:IsStack() then
							help_string = help_string .. (Language_En and " (One)" or " (一个)")
						end
					elseif can_take_active_item then
						help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CHANGE_CONTROL_HOVER) .. " " .. STRINGS.UI.HUD.SWAP
					end
				elseif active_item.replica.equippable ~= nil and active_item.replica.equippable:EquipSlot() == self.active_slot.equipslot and not active_item.replica.equippable:IsRestricted(self.owner) then
					help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CHANGE_CONTROL_HOVER) .. " " .. STRINGS.UI.HUD.EQUIP
				end
				table.insert(str, help_string)
				table.insert(icon, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_EXAMINE))
				table.insert(icon, TheInput:GetLocalizedControl(controller_id, CHANGE_CONTROL_HOVER))

				help_string = ""
				local always_show_inv = true
				local changebox_flag = false
				local drop_inv_flag = false
				local quick_use_flag = false
				if not is_equip_slot and right and not (left and inv_item.replica.container ~= nil) then
					changebox_flag = true
				end
				if right then
					drop_inv_flag = true
				end
				local quick_act = nil
				local quick_act_string = ""
				if not is_equip_slot and slot_num ~= nil and container ~= nil and container.inst == self.owner then
					quick_act = self.owner.components.playercontroller:GetItemSelfAction(inv_item)
					quick_act_string = GetQuickUseString(slot_num, quick_act)
				elseif is_equip_slot and is_equip_slot ~= EQUIPSLOTS.BEARD then
					quick_act = self.owner.components.playercontroller:GetItemSelfAction(inv_item)
					quick_act_string = GetQuickUseString(is_equip_slot, quick_act)
				end
				if quick_act ~= nil and quick_act.action.id ~= "TOGGLE_DEPLOY_MODE" and quick_act.action ~= ACTIONS.UNEQUIP and quick_act_string ~= "" then
					quick_use_flag = true
				end
				if not changebox_flag then
					local scene_action = self.owner.components.playercontroller:GetItemUseAction(active_item)
					if scene_action ~= nil then
						help_string = help_string .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE) .. " " .. scene_action:GetActionString()
						table.insert(icon, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE))
					end
					local use_action = self.owner.components.playercontroller:GetItemUseAction(active_item, inv_item)
					local self_action = self.owner.components.playercontroller:GetItemSelfAction(active_item)
					if left and inv_item.replica.container ~= nil and inv_item.replica.container:IsOpenedBy(self.owner) then
						help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. STRINGS.ACTIONS.STORE.GENERIC
						if active_item.replica.stackable ~= nil and active_item.replica.stackable:IsStack() then
							help_string = help_string .. (Language_En and " (One)" or " (一个)")
						end
						table.insert(icon, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF))
					elseif use_action ~= nil then
						help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. use_action:GetActionString()
						table.insert(icon, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF))
					elseif self_action ~= nil then
						help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. self_action:GetActionString()
						table.insert(icon, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF))
					end
				end
				if help_string ~= "" then
					table.insert(str, help_string)
				end
				if not drop_inv_flag then
					help_string = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP) .. " " .. GetDropActionString(self.owner, active_item)
					if left and active_item.replica.stackable and active_item.replica.stackable:IsStack() then
						help_string = help_string .. (Language_En and " (One)" or " (一个)")
					end
					table.insert(str, help_string)
					table.insert(icon, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP))
				end

				if always_show_inv or changebox_flag or drop_inv_flag or quick_use_flag then
					if changebox_flag then
						help_string = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE) .. " " .. STRINGS.UI.HUD.CHANGEBOX
						help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. STRINGS.UI.HUD.CHANGEBOX
						table.insert(str_below, help_string)
						table.insert(icon_below, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE))
						table.insert(icon_below, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF))
					end
					if drop_inv_flag then
						help_string = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP) .. " " .. GetDropActionString(self.owner, inv_item)
						if left and inv_item.replica.stackable and inv_item.replica.stackable:IsStack() then
							help_string = help_string .. (Language_En and " (One)" or " (一个)")
						end
						table.insert(str_below, help_string)
						table.insert(icon_below, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP))
					end
					if quick_use_flag then
						table.insert(str_below, quick_act_string)
						table.insert(icon_below, "\n" .. quick_act_string)
					end
				end

			elseif active_item ~= nil then
				local help_string = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_EXAMINE) .. " " .. STRINGS.UI.HUD.INSPECT
				if not is_equip_slot then
					help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CHANGE_CONTROL_HOVER) .. " " .. STRINGS.UI.HUD.PUT
					help_string = help_string .. (left and active_item.replica.stackable and active_item.replica.stackable:IsStack() and (Language_En and " (One)" or " (一个)") or "")
				elseif active_item.replica.equippable ~= nil and active_item.replica.equippable:EquipSlot() == self.active_slot.equipslot and not active_item.replica.equippable:IsRestricted(self.owner) then
					help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CHANGE_CONTROL_HOVER) .. " " .. STRINGS.UI.HUD.EQUIP
				end
				table.insert(str, help_string)
				table.insert(icon, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_EXAMINE))
				table.insert(icon, TheInput:GetLocalizedControl(controller_id, CHANGE_CONTROL_HOVER))

				help_string = ""
				local scene_action = self.owner.components.playercontroller:GetItemUseAction(active_item)
				if scene_action ~= nil then
					help_string = help_string .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE) .. " " .. scene_action:GetActionString()
					table.insert(icon,  TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE))
				end
				local self_action = self.owner.components.playercontroller:GetItemSelfAction(active_item)
				if self_action ~= nil then
					help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. self_action:GetActionString()
					table.insert(icon, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF))
				end
				if help_string ~= "" then
					table.insert(str, help_string)
				end

				help_string = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP) .. " " .. GetDropActionString(self.owner, active_item)
				table.insert(icon, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP))
				if left and active_item.replica.stackable and active_item.replica.stackable:IsStack() then
					help_string = help_string .. (Language_En and " (One)" or " (一个)")
				end
				table.insert(str, help_string)

			elseif inv_item ~= nil then
				local help_string = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_EXAMINE) .. " " .. STRINGS.UI.HUD.INSPECT
				help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CHANGE_CONTROL_HOVER) .. " " .. STRINGS.UI.HUD.SELECT
				help_string = help_string .. (left and inv_item.replica.stackable and inv_item.replica.stackable:IsStack() and (Language_En and " (Half)" or " (一半)") or "")
				table.insert(str, help_string)
				table.insert(icon, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_EXAMINE))
				table.insert(icon, TheInput:GetLocalizedControl(controller_id, CHANGE_CONTROL_HOVER))

				help_string = ""
				if not is_equip_slot then
					if right then
						help_string = help_string .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE) .. " " .. STRINGS.UI.HUD.CHANGEBOX
						help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. STRINGS.UI.HUD.CHANGEBOX
						table.insert(icon,  TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE))
						table.insert(icon,  TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF))
					else
						if not inv_item.replica.inventoryitem:IsGrandOwner(self.owner) then
							help_string = help_string .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE) .. " " .. STRINGS.UI.HUD.TAKE
							table.insert(icon,  TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE))
						else
							local scene_action = self.owner.components.playercontroller:GetItemUseAction(inv_item)
							if scene_action ~= nil then
								help_string = help_string .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE) .. " " .. scene_action:GetActionString()
								table.insert(icon,  TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE))
							end
						end
						local self_action = self.owner.components.playercontroller:GetItemSelfAction(inv_item)
						if self_action ~= nil then
							if help_string ~= nil then help_string = help_string .. "  " end
							help_string = help_string .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. self_action:GetActionString()
							table.insert(icon,  TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF))
						end
					end
				else
					local self_action = self.owner.components.playercontroller:GetItemSelfAction(inv_item)
					if self_action ~= nil and self_action.action ~= ACTIONS.UNEQUIP then
						help_string = help_string .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE) .. " " .. self_action:GetActionString()
						table.insert(icon,  TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE))
					end
					if #self.inv > 0 and not (inv_item:HasTag("heavy") or GetGameModeProperty("non_item_equips")) then
						help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. STRINGS.UI.HUD.UNEQUIP
						table.insert(icon,  TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF))
					end
				end
				if help_string ~= "" then
					table.insert(str, help_string)
				end
				
				help_string = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP) .. " " .. GetDropActionString(self.owner, inv_item)
				table.insert(icon, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP))
				if left and inv_item.replica.stackable and inv_item.replica.stackable:IsStack() then
					help_string = help_string .. (Language_En and " (One)" or " (一个)")
				end
				table.insert(str, help_string)

				local quick_act = nil
				local quick_act_string = ""
				if not is_equip_slot and slot_num ~= nil and container ~= nil and container.inst == self.owner then
					quick_act = self.owner.components.playercontroller:GetItemSelfAction(inv_item)
					quick_act_string = GetQuickUseString(slot_num, quick_act)
				elseif is_equip_slot and is_equip_slot ~= EQUIPSLOTS.BEARD then
					quick_act = self.owner.components.playercontroller:GetItemSelfAction(inv_item)
					quick_act_string = GetQuickUseString(is_equip_slot, quick_act)
				end
				if quick_act ~= nil and quick_act.action.id ~= "TOGGLE_DEPLOY_MODE" and quick_act.action ~= ACTIONS.UNEQUIP and quick_act_string ~= "" then
					table.insert(str, quick_act_string)
					table.insert(icon, "\n" .. quick_act_string)
				end
			end

			local hide_above = false
			local hide_blow = false
			if isreadonlycontainer then
				if active_item ~= nil then
					hide_blow = true
				else
					hide_above = true
				end
			end

			local was_shown = self.actionstring.shown
			local old = self.actionstringbody:GetString()
			local old_below = self.actionstringbody_below:GetString()
			if CHANGE_INVENTORY_BAR_HINT_REMOVE_ACTION_TEXT then
				local new_icon = hide_above and " " or table.concat(icon, " ")
				local new_icon_below = hide_blow and " " or table.concat(icon_below, " ")
				if old ~= new_icon or old_below ~= new_icon_below then
					self.actionstringbody:SetString(new_icon)
					self.actionstringbody_below:SetString(new_icon_below)
					self.actionstringtime = CURSOR_STRING_DELAY
					self.actionstring:Show()
				end
			else
				local new_string = hide_above and " " or table.concat(str, '\n')
				local new_string_below = hide_blow and " " or table.concat(str_below, '\n')
				if old ~= new_string or old_below ~= new_string_below then
					self.actionstringbody:SetString(new_string)
					self.actionstringbody_below:SetString(new_string_below)
					self.actionstringtime = CURSOR_STRING_DELAY
					self.actionstring:Show()
				end
			end

			local below_text_offset = 0
			if IsOtherModEnabled("Insight (Show Me+)") then
				local insight_description_lines = self.insightText and self.insightText.line_count or 0
				if insight_description_lines > 0 then
					local fake_str = {}
					for _ = 1, insight_description_lines do
						table.insert(fake_str, " ")
					end
					self.fake_text:SetString(table.concat(fake_str, '\n'))
					_, below_text_offset = self.fake_text:GetRegionSize()
					-- Fix crash while "Insight" and "45 inventory slot" both open 
					below_text_offset = below_text_offset or 0
				end
			end

			local w0, h0 = self.actionstringtitle:GetRegionSize()
			local w1, h1 = self.actionstringbody:GetRegionSize()
			local w2, h2 = self.actionstringtitle_below:GetRegionSize()
			local w3, h3 = self.actionstringbody_below:GetRegionSize()

			if self.actionstringtitle:GetString() == "" then w0 = 0; h0 = 0 end
			if self.actionstringbody:GetString() == "" then w1 = 0; h1 = 0 end
			if self.actionstringtitle_below:GetString() == "" then w2 = 0; h2 = 0 end
			if self.actionstringbody_below:GetString() == "" then w3 = 0; h3 = 0 end

			local wmax = math.max(w0, w1, w2, w3)

			local dest_pos = self.active_slot:GetWorldPosition()

			local xscale, yscale, zscale = self.root:GetScale():Get()

			if self.active_slot.container ~= nil and self.active_slot.container.issidewidget and not Profile:GetIntegratedBackpack() then
				-- backpack
				self.actionstringtitle:SetPosition(-wmax/2, h0/2)
				self.actionstringbody:SetPosition(-wmax/2, -h1/2)
				self.actionstringtitle_below:SetPosition(-wmax/2, -h2/2 - h1 + below_text_offset)
				self.actionstringbody_below:SetPosition(-wmax/2, -h3/2 - h2 - h1 + below_text_offset)
				dest_pos.x = dest_pos.x + ((-240) - self.active_slot.container.widget.slotpos[self.active_slot.num].x) * xscale

			elseif self.active_slot.container ~= nil and self.active_slot.container.type == "side_inv_behind" then
				-- beard
				self.actionstringtitle:SetPosition(-wmax/2, h0/2)
				self.actionstringbody:SetPosition(-wmax/2, -h1/2)
				self.actionstringtitle_below:SetPosition(-wmax/2, -h2/2 - h1 + below_text_offset)
				self.actionstringbody_below:SetPosition(-wmax/2, -h3/2 - h2 - h1 + below_text_offset)
				local degree_dist = (#self.active_slot.container.widget.slotpos - 1) * 20
				dest_pos.x = dest_pos.x + ((-100) - degree_dist - self.active_slot.container.widget.slotpos[self.active_slot.num].x) * xscale
			
			elseif self.active_slot.container ~= nil and self.active_slot.container.type == "hand_inv" then
				-- oceanfishrod, slingshot, etc.
				self.actionstringtitle:SetPosition(wmax/2, h0/2)
				self.actionstringbody:SetPosition(wmax/2, -h1/2)
				self.actionstringtitle_below:SetPosition(wmax/2, -h2/2 - h1 + below_text_offset)
				self.actionstringbody_below:SetPosition(wmax/2, -h3/2 - h2 - h1 + below_text_offset)
				dest_pos.x = dest_pos.x + 100 * xscale

			elseif self.active_slot.side_align_tip then
				-- in-game containers, chests, fridge
				self.actionstringtitle:SetPosition(wmax/2, h0/2)
				self.actionstringbody:SetPosition(wmax/2, -h1/2)
				self.actionstringtitle_below:SetPosition(wmax/2, -h2/2 - h1 + below_text_offset)
				self.actionstringbody_below:SetPosition(wmax/2, -h3/2 - h2 - h1 + below_text_offset)
				dest_pos.x = dest_pos.x + self.active_slot.side_align_tip * xscale

			elseif self.active_slot.top_align_tip then
				-- main inventory
				self.actionstringtitle:SetPosition(0, h0/2 + h1 + h2 + h3)
				self.actionstringbody:SetPosition(0, h1/2 + h2 + h3)
				self.actionstringtitle_below:SetPosition(0, h2/2 + h3 + below_text_offset)
				self.actionstringbody_below:SetPosition(0, h3/2 + below_text_offset)
				dest_pos.y = dest_pos.y + (self.active_slot.top_align_tip + TIP_YFUDGE) * yscale

			elseif self.active_slot.bottom_align_tip then
				self.actionstringtitle:SetPosition(0, -h0/2)
				self.actionstringbody:SetPosition(0, -(h1/2 + h0))
				self.actionstringtitle_below:SetPosition(0, -(h2/2 + h0 + h1) + below_text_offset)
				self.actionstringbody_below:SetPosition(0, -(h3/2 + h0 + h1 + h2) + below_text_offset)
				dest_pos.y = dest_pos.y + (self.active_slot.bottom_align_tip + TIP_YFUDGE) * yscale

			else
				-- old default as fallback ?
				self.actionstringtitle:SetPosition(0, h0/2 + h1 + h2 + h3)
				self.actionstringbody:SetPosition(0, h1/2 + h2 + h3)
				self.actionstringtitle_below:SetPosition(0, h2/2 + h3 + below_text_offset)
				self.actionstringbody_below:SetPosition(0, h3/2 + below_text_offset)
				dest_pos.y = dest_pos.y + (W/2 + TIP_YFUDGE) * yscale

			end

			-- print("self.active_slot:GetWorldPosition()", self.active_slot:GetWorldPosition())
			-- print("h0", h0)
			-- print("w0", w0)
			-- print("h1", h1)
			-- print("w1", h1)
			-- print("h2", h2)
			-- print("w2", w2)
			-- print("h3", h3)
			-- print("w3", h3)
			-- print("dest_pos", dest_pos)

			if dest_pos:DistSq(self.actionstring:GetPosition()) > 1 then
				self.actionstringtime = CURSOR_STRING_DELAY
				if was_shown then
					self.actionstring:MoveTo(self.actionstring:GetPosition(), dest_pos, .1)
				else
					self.actionstring:SetPosition(dest_pos)
					self.actionstring:Show()
				end
			end
		else
			self.actionstringbody:SetString("")
			self.actionstringbody_below:SetString("")
			self.actionstring:Hide()
		end
	end
end)
