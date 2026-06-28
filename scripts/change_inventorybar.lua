require "class"
local InvSlot = require "widgets/invslot"
local TileBG = require "widgets/tilebg"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local EquipSlot = require "widgets/equipslot"
local ItemTile = require "widgets/itemtile"
local Text = require "widgets/text"

local HUD_ATLAS = "images/hud.xml"

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

	local CursorLeft_Old = self.CursorLeft
	self.CursorLeft = function (self, ...)
		if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
			return
		end
		CursorLeft_Old(self, ...)
	end

	local CursorRight_Old = self.CursorRight
	self.CursorRight = function (self, ...)
		if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
			return
		end
		CursorRight_Old(self, ...)
	end

	local CursorUp_Old = self.CursorUp
	self.CursorUp = function (self, ...)
		if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
			return
		end
		CursorUp_Old(self, ...)
	end

	local CursorDown_Old = self.CursorDown
	self.CursorDown = function (self, ...)
		if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
			return
		end
		CursorDown_Old(self, ...)
	end

	self.GetCursorSlot = function (self, ...)
		if self.active_slot ~= nil then
			return self.active_slot.num, self.active_slot.container
		end
	end

	self.GetClosestWidget1 = function (self, lists, pos, dir, ...)
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

	-- Not Changed
	local function BackpackGet(inst, data)
		local owner = ThePlayer
		if owner ~= nil and owner.HUD ~= nil and owner.components.inventory:IsHolding(inst) then
			local inv = owner.HUD.controls.inv
			if inv ~= nil then
				inv:OnItemGet(data.item, inv.backpackinv[data.slot], data.src_pos, data.ignore_stacksize_anim)
			end
		end
	end

	-- Not Changed
	local function BackpackLose(inst, data)
		local owner = ThePlayer
		if owner ~= nil and owner.HUD ~= nil and owner.components.inventory:IsHolding(inst) then
			local inv = owner.HUD.controls.inv
			if inv ~= nil then
				inv:OnItemLose(inv.backpackinv[data.slot])
			end
		end
	end

	local Rebuild_Old = self.Rebuild
	local Rebuild_New = function (self, ...)

		if self.cursor then
			self.cursor:Kill()
			self.cursor = nil
		end
		
		if self.toprow then
			self.toprow:Kill()
		end

		if self.bottomrow then
			self.bottomrow:Kill()
		end

		self.toprow = self.root:AddChild(Widget("toprow"))
		self.bottomrow = self.root:AddChild(Widget("toprow"))

		self.inv = {}
		self.equip = {}
		self.backpackinv = {}

		local y = self.owner.components.inventory.overflow and (W/2+YSEP/2) or 0
		local eslot_order = {}

		local num_slots = self.owner.components.inventory:GetNumSlots()
		local num_equip = #self.equipslotinfo
		local num_intersep = math.floor(num_slots / 5) + 1 
		local total_w = (num_slots + num_equip)*(W) + (num_slots + num_equip - 2 - num_intersep) *(SEP) + INTERSEP*num_intersep
		
		for k, v in ipairs(self.equipslotinfo) do
			local slot = EquipSlot(v.slot, v.atlas, v.image, self.owner)
			self.equip[v.slot] = self.toprow:AddChild(slot)
			local x = -total_w/2 + (num_slots)*(W)+num_intersep*(INTERSEP - SEP) + (num_slots-1)*SEP + INTERSEP + W*(k-1) + SEP*(k-1)
			slot:SetPosition(x,0,0)
			table.insert(eslot_order, slot)
			
			local item = self.owner.components.inventory:GetEquippedItem(v.slot)
			if item then
				slot:SetTile(ItemTile(item))
			end

		end    

		for k = 1,num_slots do
			local slot = InvSlot(k, HUD_ATLAS, "inv_slot.tex", self.owner, self.owner.components.inventory)
			self.inv[k] = self.toprow:AddChild(slot)
			local interseps = math.floor((k-1) / 5)
			local x = -total_w/2 + W/2 + interseps*(INTERSEP - SEP) + (k-1)*W + (k-1)*SEP
			slot:SetPosition(x,0,0)
			
			slot.top_align_tip = W*0.5 + YSEP

			local item = self.owner.components.inventory:GetItemInSlot(k)
			if item then
				slot:SetTile(ItemTile(item))
			end
			
		end


		local old_backpack = self.backpack
		if self.backpack then
			self.inst:RemoveEventCallback("itemget", BackpackGet, self.backpack)
			self.inst:ListenForEvent("itemlose", BackpackLose, self.backpack)
			self.backpack = nil
		end

		local controller_attached = TheInput:ControllerAttached()
		self.controller_build = controller_attached
		-- ============================================================================ --
		-- self.integrated_backpack = controller_attached or Profile:GetIntegratedBackpack()
		self.integrated_backpack = Profile:GetIntegratedBackpack()
		-- ============================================================================ --

		local overflow = self.owner.components.inventory.overflow and self.owner.components.inventory.overflow.components.container
		overflow = (overflow ~= nil and overflow:IsOpenedBy(self.owner)) and overflow or nil

		local do_integrated_backpack = overflow ~= nil and self.integrated_backpack

		local new_backpack = self.owner.components.inventory.overflow

		if do_integrated_backpack then
			local num = new_backpack.components.container.numslots

			local x = - (num * (W+SEP) / 2)
			--local offset = #self.inv >= num and 1 or 0 --math.ceil((#self.inv - num)/2)
			local offset = 1 + #self.inv - num

			for k = 1, num do
				local slot = InvSlot(k, HUD_ATLAS, "inv_slot.tex", self.owner, new_backpack.components.container)
				self.backpackinv[k] = self.bottomrow:AddChild(slot)

				slot.top_align_tip = W*1.5 + YSEP*2
				
				if offset > 0 then
					slot:SetPosition(self.inv[offset+k-1]:GetPosition().x,0,0)
				else
					slot:SetPosition(x,0,0)
					x = x + W + SEP
				end
				
				local item = new_backpack.components.container:GetItemInSlot(k)
				if item then
					slot:SetTile(ItemTile(item))
				end
				
			end
			
			self.backpack = self.owner.components.inventory.overflow
			self.inst:ListenForEvent("itemget", BackpackGet, self.backpack)
			self.inst:ListenForEvent("itemlose", BackpackLose, self.backpack)
		end



		if old_backpack	and not self.backpack then
			self:SelectSlot(self.inv[1])
			self.current_list = self.inv
		end

		--self.bg:Flow(total_w+60, 256, true)
		
		if do_integrated_backpack then
			self.bg:SetPosition(Vector3(0,-24,0))
			self.bgcover:SetPosition(Vector3(0, -135, 0))
			self.toprow:SetPosition(Vector3(0,W/2 + YSEP/2,0))
			self.bottomrow:SetPosition(Vector3(0,-W/2 - YSEP/2,0))

			if self.rebuild_snapping then
				self.root:SetPosition(self.in_pos)
			else
				self.root:MoveTo(self.out_pos, self.in_pos, .5)
			end
		else
			self.bg:SetPosition(Vector3(0, -64, 0))
			self.bgcover:SetPosition(Vector3(0, -100, 0))
			self.toprow:SetPosition(Vector3(0,0,0))
			self.bottomrow:SetPosition(0,0,0)
			
			if do_integrated_backpack and not self.rebuild_snapping then
				self.root:MoveTo(self.in_pos, self.out_pos, .2)
			else
				self.root:SetPosition(self.out_pos)
			end
		end
		
		self.actionstring:MoveToFront()
		
		self:SelectSlot(self.inv[1])
		self.current_list = self.inv
		self:UpdateCursor()
		
		if self.cursor then
			self.cursor:MoveToFront()
		end

		self.rebuild_pending = false
		self.rebuild_snapping = false
	end


	self.Rebuild = function(self, ...)
		if TheInput:ControllerAttached() then
			Rebuild_New(self, ...)
		else
			Rebuild_Old(self, ...)
		end
	end

	STRINGS.UI.HUD.TAKEHALF = STRINGS.UI.CONTROLSSCREEN.CONTROLS[36]
	STRINGS.UI.HUD.CHANGEBOX = STRINGS.UI.CONTROLSSCREEN.CONTROLS[37]
	STRINGS.UI.HUD.CHANGEBOXHALF = STRINGS.UI.CONTROLSSCREEN.CONTROLS[38]
	TITLE_TEXT_COLOUR = {204/255, 180/255, 154/255, 1}

	-- Not Changed
	local function GetDropActionString(doer, item)
		return BufferedAction(doer, nil, ACTIONS.DROP, item, doer:GetPosition()):GetActionString()
	end

	-- local SetActionStringSize = function(obj, size, hud)
	-- 	obj:SetSize(size * TheFrontEnd:GetHUDScale())
	-- 	obj.inst:ListenForEvent("continuefrompause", function() obj:SetSize(size * TheFrontEnd:GetHUDScale()) end, hud)
	-- 	obj.inst:ListenForEvent("refreshhudsize", function(hud, scale) obj:SetSize(size * scale) end, hud)
	-- end

	self.actionstringtitle_below = self.actionstring:AddChild(Text(TALKINGFONT, 35))
    self.actionstringtitle_below:SetColour(204/255, 180/255, 154/255, 1)
	self.actionstringbody_below = self.actionstring:AddChild(Text(TALKINGFONT, 25))
	self.actionstringbody_below:EnableWordWrap(true)

	-- SetActionStringSize(self.actionstringtitle, 24, self.owner.HUD.inst)
	-- SetActionStringSize(self.actionstringbody, 18, self.owner.HUD.inst)
	-- SetActionStringSize(self.actionstringtitle_below, 24, self.owner.HUD.inst)
	-- SetActionStringSize(self.actionstringbody_below, 18, self.owner.HUD.inst)

	local SetTooltipColour_Old = self.SetTooltipColour
	self.SetTooltipColour = function (self, ...)
		SetTooltipColour_Old(self, ...)
		self.actionstringtitle_below:SetColour(...)
	end

	-- Almost Rewrite
	self.UpdateCursorText = function (self, ...)
		local Language_En = CHANGE_LANGUAGE_ENGLISH
		local inv_item = self:GetCursorItem()
		local slot_num, container = self:GetCursorSlot()
		local active_item = self.cursortile ~= nil and self.cursortile.item or nil
		if inv_item ~= nil and inv_item.components.inventoryitem == nil then
			inv_item = nil
		end
		if active_item ~= nil and active_item.components.inventoryitem == nil then
			active_item = nil
		end
		if (active_item ~= nil or inv_item ~= nil) and CHANGE_HIDE_INVENTORY_BAR_HINT ~= "all" then
			local controller_id = TheInput:GetControllerID()

			if active_item ~= nil and inv_item ~= nil then
				local itemname = self:GetDescriptionString(active_item)
				self.actionstringtitle:SetString(itemname)
				if self:IsWet(active_item) then
					self:SetTooltipColour(WET_TEXT_COLOUR[1], WET_TEXT_COLOUR[2], WET_TEXT_COLOUR[3], WET_TEXT_COLOUR[4])
				else
					self:SetTooltipColour(TITLE_TEXT_COLOUR[1], TITLE_TEXT_COLOUR[2], TITLE_TEXT_COLOUR[3], TITLE_TEXT_COLOUR[4])
				end
				itemname = self:GetDescriptionString(inv_item)
				self.actionstringtitle_below:SetString(itemname)
				if self:IsWet(inv_item) then
					self:SetTooltipColour(WET_TEXT_COLOUR[1], WET_TEXT_COLOUR[2], WET_TEXT_COLOUR[3], WET_TEXT_COLOUR[4])
				else
					self:SetTooltipColour(TITLE_TEXT_COLOUR[1], TITLE_TEXT_COLOUR[2], TITLE_TEXT_COLOUR[3], TITLE_TEXT_COLOUR[4])
				end
			elseif active_item ~= nil then
				local itemname = self:GetDescriptionString(active_item)
				self.actionstringtitle:SetString(itemname)
				if self:IsWet(active_item) then
					self:SetTooltipColour(WET_TEXT_COLOUR[1], WET_TEXT_COLOUR[2], WET_TEXT_COLOUR[3], WET_TEXT_COLOUR[4])
				else
					self:SetTooltipColour(TITLE_TEXT_COLOUR[1], TITLE_TEXT_COLOUR[2], TITLE_TEXT_COLOUR[3], TITLE_TEXT_COLOUR[4])
				end
				self.actionstringtitle_below:SetString("")
			elseif inv_item ~= nil then
				local itemname = self:GetDescriptionString(inv_item)
				self.actionstringtitle:SetString(itemname)
				if self:IsWet(inv_item) then
					self:SetTooltipColour(WET_TEXT_COLOUR[1], WET_TEXT_COLOUR[2], WET_TEXT_COLOUR[3], WET_TEXT_COLOUR[4])
				else
					self:SetTooltipColour(TITLE_TEXT_COLOUR[1], TITLE_TEXT_COLOUR[2], TITLE_TEXT_COLOUR[3], TITLE_TEXT_COLOUR[4])
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
					if active_item.components.stackable ~= nil and inv_item.prefab == active_item.prefab and active_item.skinname == active_item.skinname then
						help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CHANGE_CONTROL_HOVER) .. " " .. STRINGS.ACTIONS.COMBINESTACK
						if left and active_item.components.stackable:IsStack() then
							help_string = help_string .. (Language_En and " (One)" or " (一个)")
						end
					elseif can_take_active_item then
						help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CHANGE_CONTROL_HOVER) .. " " .. STRINGS.UI.HUD.SWAP
					end
				elseif active_item.components.equippable ~= nil and active_item.components.equippable.equipslot == self.active_slot.equipslot then
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
				if not is_equip_slot and right and not (left and inv_item.components.container ~= nil) then
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
					if left and inv_item.components.container ~= nil and inv_item.components.container:IsOpenedBy(self.owner) then
						help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. STRINGS.ACTIONS.STORE.GENERIC
						if active_item.components.stackable ~= nil and active_item.components.stackable:IsStack() then
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
					if left and active_item.components.stackable and active_item.components.stackable:IsStack() then
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
						if left and inv_item.components.stackable and inv_item.components.stackable:IsStack() then
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
					help_string = help_string .. (left and active_item.components.stackable and active_item.components.stackable:IsStack() and (Language_En and " (One)" or " (一个)") or "")
				elseif active_item.components.equippable ~= nil and active_item.components.equippable.equipslot == self.active_slot.equipslot then
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
				if left and active_item.components.stackable and active_item.components.stackable:IsStack() then
					help_string = help_string .. (Language_En and " (One)" or " (一个)")
				end
				table.insert(str, help_string)

			elseif inv_item ~= nil then
				local help_string = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_EXAMINE) .. " " .. STRINGS.UI.HUD.INSPECT
				help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CHANGE_CONTROL_HOVER) .. " " .. STRINGS.UI.HUD.SELECT
				help_string = help_string .. (left and inv_item.components.stackable and inv_item.components.stackable:IsStack() and (Language_En and " (Half)" or " (一半)") or "")
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
						if not inv_item.components.inventoryitem:IsGrandOwner(self.owner) then
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
					if #self.inv > 0 then
						help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. STRINGS.UI.HUD.UNEQUIP
						table.insert(icon,  TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF))
					end
				end
				if help_string ~= "" then
					table.insert(str, help_string)
				end
				
				help_string = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP) .. " " .. GetDropActionString(self.owner, inv_item)
				table.insert(icon, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP))
				if left and inv_item.components.stackable and inv_item.components.stackable:IsStack() then
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

			local was_shown = self.actionstring.shown
			local old = self.actionstringbody:GetString()
			local old_below = self.actionstringbody_below:GetString()
			if CHANGE_INVENTORY_BAR_HINT_REMOVE_ACTION_TEXT then
				local new_icon = table.concat(icon, " ")
				local new_icon_below = table.concat(icon_below, " ")
				if old ~= new_icon or old_below ~= new_icon_below then
					self.actionstringbody:SetString(new_icon)
					self.actionstringbody_below:SetString(new_icon_below)
					self.actionstringtime = CURSOR_STRING_DELAY
					self.actionstring:Show()
				end
			else
				local new_string = table.concat(str, '\n')
				local new_string_below = table.concat(str_below, '\n')
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

			if self.active_slot.container ~= nil and self.active_slot.container.side_widget and not Profile:GetIntegratedBackpack() then
				-- backpack
				self.actionstringtitle:SetPosition(-wmax/2, h0/2)
				self.actionstringbody:SetPosition(-wmax/2, -h1/2)
				self.actionstringtitle_below:SetPosition(-wmax/2, -h2/2 - h1 + below_text_offset)
				self.actionstringbody_below:SetPosition(-wmax/2, -h3/2 - h2 - h1 + below_text_offset)
				dest_pos.x = dest_pos.x + ((-240) - self.active_slot.container.widgetslotpos[self.active_slot.num].x) * xscale

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
