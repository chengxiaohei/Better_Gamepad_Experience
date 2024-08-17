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
		if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
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
		if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
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
		if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
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
		if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
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

	-- Not Changed
	local function BackpackGet(inst, data)
		local owner = ThePlayer
		if owner ~= nil and owner.HUD ~= nil and owner.replica.inventory:IsHolding(inst) then
			local inv = owner.HUD.controls.inv
			if inv ~= nil then
				inv:OnItemGet(data.item, inv.backpackinv[data.slot], data.src_pos, data.ignore_stacksize_anim)
			end
		end
	end

	-- Not Changed
	local function BackpackLose(inst, data)
		local owner = ThePlayer
		if owner ~= nil and owner.HUD ~= nil and owner.replica.inventory:IsHolding(inst) then
			local inv = owner.HUD.controls.inv
			if inv ~= nil then
				inv:OnItemLose(inv.backpackinv[data.slot])
			end
		end
	end

	-- Not Changed
	local function BackpackRefresh(inst)
		local owner = ThePlayer
		local inventory = owner and owner.HUD and owner.replica.inventory or nil
		local overflow = inventory and inventory:GetOverflowContainer() or nil
		if overflow and overflow.inst == inst then
			local inv = owner.HUD.controls.inv
			if inv then
				inv:RefreshIntegratedContainer()
			end
		end
	end

	-- Not Changed
	local function RebuildLayout_Quagmire(self, inventory, overflow, do_integrated_backpack, do_self_inspect)
		local inv_scale = 1
		local inv_w = 68 * inv_scale
		local inv_sep = 10 * inv_scale
		local inv_y = -77
		local inv_tip_y = inv_w + inv_sep + (30 * inv_scale)

		local num_slots = inventory:GetNumSlots()
		local x = -165
		for k = 1, num_slots do
			self.inv[k] = InvSlot(k, HUD_ATLAS, "inv_slot.tex", self.owner, self.owner.replica.inventory)
			local slot = self.toprow:AddChild(Widget("slot_scaler"..k))
			slot:AddChild(self.inv[k])
			slot:SetPosition(x, inv_y)
			slot:SetScale(inv_scale)
			slot.top_align_tip = inv_w + inv_sep + 30 -- tooltip text offset when using cursors

			local item = inventory:GetItemInSlot(k)
			if item ~= nil then
				self.inv[k]:SetTile(ItemTile(item))
			end

			x = x + 83
		end

		local equip_scale = 0.8
		local equip_y = -74

		local hand_slot = self.equipslotinfo[1]
		local slot = EquipSlot(hand_slot.slot, hand_slot.atlas, hand_slot.image, self.owner)
		slot:SetPosition(x, equip_y)
		slot.highlight_scale = 1
		slot.base_scale = equip_scale
		slot:SetScale(equip_scale)


		self.equip[hand_slot.slot] = self.toprow:AddChild(slot)

		local item = inventory:GetEquippedItem(hand_slot.slot)
		if item ~= nil then
			slot:SetTile(ItemTile(item))
		end


		self.toprow:SetPosition(0, 75)
		self.bg:SetPosition(0, 15)

		self.root:SetPosition(self.in_pos)
		self:UpdatePosition()
	end

	-- Not Changed
	local function RebuildLayout(self, inventory, overflow, do_integrated_backpack, do_self_inspect)
		local y = overflow ~= nil and ((W + YSEP) / 2) or 0
		local eslot_order = {}

		local num_slots = inventory:GetNumSlots()
		local num_equip = #self.equipslotinfo
		local num_buttons = do_self_inspect and 1 or 0
		local num_slotintersep = math.ceil(num_slots / 5)
		local num_equipintersep = num_buttons > 0 and 1 or 0
		local total_w = (num_slots + num_equip + num_buttons) * W + (num_slots + num_equip + num_buttons - num_slotintersep - num_equipintersep - 1) * SEP + (num_slotintersep + num_equipintersep) * INTERSEP

		local x = (W - total_w) * .5 + num_slots * W + (num_slots - num_slotintersep) * SEP + num_slotintersep * INTERSEP
		for k, v in ipairs(self.equipslotinfo) do
			local slot = EquipSlot(v.slot, v.atlas, v.image, self.owner)
			self.equip[v.slot] = self.toprow:AddChild(slot)
			slot:SetPosition(x, 0, 0)
			table.insert(eslot_order, slot)

			local item = inventory:GetEquippedItem(v.slot)
			if item ~= nil then
				slot:SetTile(ItemTile(item))
			end

			if v.slot == EQUIPSLOTS.HANDS then
				self.hudcompass:SetPosition(x, do_integrated_backpack and 80 or 40, 0)
				self.hand_inv:SetPosition(x, do_integrated_backpack and 80 or 40, 0)
			end

			x = x + W + SEP
		end

		x = (W - total_w) * .5
		for k = 1, num_slots do
			local slot = InvSlot(k, HUD_ATLAS, "inv_slot.tex", self.owner, self.owner.replica.inventory)
			self.inv[k] = self.toprow:AddChild(slot)
			slot:SetPosition(x, 0, 0)
			slot.top_align_tip = W * .5 + YSEP

			local item = inventory:GetItemInSlot(k)
			if item ~= nil then
				slot:SetTile(ItemTile(item))
			end

			x = x + W + (k % 5 == 0 and INTERSEP or SEP)
		end

		local owner_prefab = self.owner.prefab
		local image_name = "self_inspect_".. owner_prefab ..".tex"
		local atlas_name = "images/avatars/self_inspect_".. owner_prefab.. ".xml"
		if softresolvefilepath(atlas_name) == nil then
			atlas_name = HUD_CHARACTERS[owner_prefab] or HUD_ATLAS
		end

		if do_self_inspect then
			self.bg:SetScale(1.22, 1, 1)
			self.bgcover:SetScale(1.22, 1, 1)

			self.inspectcontrol = self.toprow:AddChild(TEMPLATES.IconButton(atlas_name, image_name, STRINGS.UI.HUD.INSPECT_SELF, false, false, function() self.owner.HUD:InspectSelf() end, nil, "self_inspect_mod.tex"))
			self.inspectcontrol.icon:SetScale(.7)
			self.inspectcontrol.icon:SetPosition(-4, 6)
			self.inspectcontrol:SetScale(1.25)
			self.inspectcontrol:SetPosition((total_w - W) * .5 + 3, -7, 0)
		else
			self.bg:SetScale(1.15, 1, 1)
			self.bgcover:SetScale(1.15, 1, 1)

			if self.inspectcontrol ~= nil then
				self.inspectcontrol:Kill()
				self.inspectcontrol = nil
			end
		end

		local hadbackpack = self.backpack ~= nil
		if hadbackpack then
			self.inst:RemoveEventCallback("itemget", BackpackGet, self.backpack)
			self.inst:RemoveEventCallback("itemlose", BackpackLose, self.backpack)
			self.inst:RemoveEventCallback("refresh", BackpackRefresh, self.backpack)
			self.backpack = nil
		end

		if do_integrated_backpack then
			local num = overflow:GetNumSlots()

			local x = - (num * (W+SEP) / 2)
			--local offset = #self.inv >= num and 1 or 0 --math.ceil((#self.inv - num)/2)
			local offset = 1 + #self.inv - num

			self.integrated_arrow = self.bottomrow:AddChild(Image(HUD_ATLAS, "inventory_bg_arrow.tex"))
			self.integrated_arrow:SetPosition(self.inv[#self.inv]:GetPosition().x + W * 0.5 + INTERSEP + 61, 8)

			for k = 1, num do
				local slot = InvSlot(k, HUD_ATLAS, "inv_slot.tex", self.owner, overflow)
				self.backpackinv[k] = self.bottomrow:AddChild(slot)

				slot.top_align_tip = W*1.5 + YSEP*2

				if offset > 0 then
					slot:SetPosition(self.inv[offset+k-1]:GetPosition().x,0,0)
				else
					slot:SetPosition(x,0,0)
					x = x + W + SEP
				end

				local item = overflow:GetItemInSlot(k)
				if item ~= nil then
					slot:SetTile(ItemTile(item))
				end
			end

			self.backpack = overflow.inst
			self.inst:ListenForEvent("itemget", BackpackGet, self.backpack)
			self.inst:ListenForEvent("itemlose", BackpackLose, self.backpack)
			self.inst:ListenForEvent("refresh", BackpackRefresh, self.backpack)
		end

		if hadbackpack and self.backpack == nil then
			self:SelectDefaultSlot()
		end

		if self.bg.Flow ~= nil then
			-- note: Flow is a 3-slice function
			self.bg:Flow(total_w + 60, 256, true)
		end

		if TheNet:GetServerGameMode() == "lavaarena" then
			self.bg:SetPosition(15, 0)
			self.bg:SetScale(1)
			self.toprow:SetPosition(0, 3)
			self.root:SetPosition(self.in_pos)
		elseif do_integrated_backpack then
			self.bg:SetPosition(0, -24)
			self.bgcover:SetPosition(0, -135)
			self.toprow:SetPosition(0, .5 * (W + YSEP))
			self.bottomrow:SetPosition(0, -.5 * (W + YSEP))

			if self.rebuild_snapping then
				self.root:CancelMoveTo()
				self.root:SetPosition(self.in_pos)
				self:UpdatePosition()
			else
				self.root:MoveTo(self.out_pos, self.in_pos, .5)
			end
		else
			self.bg:SetPosition(0, -64)
			self.bgcover:SetPosition(0, -100)
			self.toprow:SetPosition(0, 0)
			self.bottomrow:SetPosition(0, 0)

			if do_integrated_backpack and not self.rebuild_snapping then
				self.root:MoveTo(self.in_pos, self.out_pos, .2)
			else
				self.root:CancelMoveTo()
				self.root:SetPosition(self.out_pos)
				self:UpdatePosition()
			end
		end
	end

	local Rebuild_Old = self.Rebuild
	local Rebuild_New = function (self, ...)
		if self.cursor ~= nil then
			self.cursor:Kill()
			self.cursor = nil
		end

		if self.toprow ~= nil then
			self.toprow:Kill()
			self.inspectcontrol = nil
		end

		if self.bottomrow ~= nil then
			self.bottomrow:Kill()
		end

		self.toprow = self.root:AddChild(Widget("toprow"))
		self.bottomrow = self.root:AddChild(Widget("toprow"))

		self.inv = {}
		self.equip = {}
		self.backpackinv = {}

		local controller_attached = TheInput:ControllerAttached()
		self.controller_build = controller_attached
		-- =============================================================================== --
		-- self.integrated_backpack = controller_attached or Profile:GetIntegratedBackpack()
		self.integrated_backpack = Profile:GetIntegratedBackpack()
		-- =============================================================================== --

		local inventory = self.owner.replica.inventory

		local overflow = inventory:GetOverflowContainer()
		overflow = (overflow ~= nil and overflow:IsOpenedBy(self.owner)) and overflow or nil

		local do_integrated_backpack = overflow ~= nil and self.integrated_backpack
		-- =============================================================================== --
		-- local do_self_inspect = not (self.controller_build or GetGameModeProperty("no_avatar_popup"))
		local do_self_inspect = CHANGE_SHOW_SELF_INSPECT_BUTTON and not (GetGameModeProperty("no_avatar_popup"))
		-- =============================================================================== --

		if TheNet:GetServerGameMode() == "quagmire" then
			RebuildLayout_Quagmire(self, inventory, overflow, do_integrated_backpack, do_self_inspect)
		else
			RebuildLayout(self, inventory, overflow, do_integrated_backpack, do_self_inspect)
		end

		self.actionstring:MoveToFront()

		self:SelectDefaultSlot()
		self:UpdateCursor()

		if self.cursor ~= nil then
			self.cursor:MoveToFront()
		end

		self.rebuild_pending = nil
		self.rebuild_snapping = nil
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

	-- Not Changed
	local function GetDropActionString(doer, item)
		return BufferedAction(doer, nil, ACTIONS.DROP, item, doer:GetPosition()):GetActionString()
	end

	-- Numerous changes
	self.UpdateCursorText = function (self, ...)
		local Language_En = CHANGE_LANGUAGE_ENGLISH
		local inv_item = self:GetCursorItem()
		local slot_num, container = self:GetCursorSlot()
		local active_item = self.cursortile ~= nil and self.cursortile.item or nil
		if inv_item ~= nil and inv_item.replica.inventoryitem == nil then
			inv_item = nil
		end
		if active_item ~= nil and active_item.replica.inventoryitem == nil then
			active_item = nil
		end
		if active_item ~= nil or inv_item ~= nil and not CHANGE_HIDE_INVENTORY_BAR_HINT then
			local controller_id = TheInput:GetControllerID()

			if active_item ~= nil then
				local itemname = self:GetDescriptionString(active_item)
				self.actionstringtitle:SetString(itemname)
				if active_item:GetIsWet() then
					self:SetTooltipColour(unpack(WET_TEXT_COLOUR))
				else
					self:SetTooltipColour(unpack(NORMAL_TEXT_COLOUR))
				end
			elseif inv_item ~= nil then
				local itemname = self:GetDescriptionString(inv_item)
				self.actionstringtitle:SetString(itemname)
				if inv_item:GetIsWet() then
					self:SetTooltipColour(unpack(WET_TEXT_COLOUR))
				else
					self:SetTooltipColour(unpack(NORMAL_TEXT_COLOUR))
				end
			end

			local is_equip_slot = self.active_slot and self.active_slot.equipslot
			local str = {}

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

				help_string = ""
				local always_show_inv = true
				local changebox_flag = false
				local drop_inv_flag = false
				local quick_use_flag = false
				local _, h, p, b, l, r = self.owner.components.playercontroller:GetAllTypeContainers()
				if not is_equip_slot and right and (h ~= nil or p ~= nil or b ~= nil or l ~= nil or r ~= nil) and
					not (left and inv_item.replica.container ~= nil) then
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
					end
					local use_action = self.owner.components.playercontroller:GetItemUseAction(active_item, inv_item)
					local self_action = self.owner.components.playercontroller:GetItemSelfAction(active_item)
					if left and inv_item.replica.container ~= nil and inv_item.replica.container:IsOpenedBy(self.owner) then
						help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. STRINGS.ACTIONS.STORE.GENERIC
						if right and active_item.replica.stackable ~= nil and active_item.replica.stackable:IsStack() then 
							help_string = help_string .. (Language_En and " (One)" or " (一个)")
						end
					elseif use_action ~= nil then
						help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. use_action:GetActionString()
					elseif self_action ~= nil then
						help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. self_action:GetActionString()
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
				end

				if always_show_inv or changebox_flag or drop_inv_flag or quick_use_flag then
					help_string = self:GetDescriptionString(inv_item)
					table.insert(str, help_string)
					if changebox_flag then
						help_string = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE) .. " " .. STRINGS.UI.HUD.CHANGEBOX
						help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. STRINGS.UI.HUD.CHANGEBOX
						table.insert(str, help_string)
					end
					if drop_inv_flag then
						help_string = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP) .. " " .. GetDropActionString(self.owner, inv_item)
						if left and inv_item.replica.stackable and inv_item.replica.stackable:IsStack() then
							help_string = help_string .. (Language_En and " (One)" or " (一个)")
						end
						table.insert(str, help_string)
					end
					if quick_use_flag then
						table.insert(str, quick_act_string)
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

				help_string = ""
				local scene_action = self.owner.components.playercontroller:GetItemUseAction(active_item)
				if scene_action ~= nil then
					help_string = help_string .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE) .. " " .. scene_action:GetActionString()
				end
				local self_action = self.owner.components.playercontroller:GetItemSelfAction(active_item)
				if self_action ~= nil then
					help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. self_action:GetActionString()
				end
				if help_string ~= "" then
					table.insert(str, help_string)
				end

				help_string = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP) .. " " .. GetDropActionString(self.owner, active_item)
				if left and active_item.replica.stackable and active_item.replica.stackable:IsStack() then
					help_string = help_string .. (Language_En and " (One)" or " (一个)")
				end
				table.insert(str, help_string)

			elseif inv_item ~= nil then
				local help_string = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_EXAMINE) .. " " .. STRINGS.UI.HUD.INSPECT
				help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CHANGE_CONTROL_HOVER) .. " " .. STRINGS.UI.HUD.SELECT
				help_string = help_string .. (left and inv_item.replica.stackable and inv_item.replica.stackable:IsStack() and (Language_En and " (Half)" or " (一半)") or "")
				table.insert(str, help_string)

				help_string = ""
				if not is_equip_slot then
					local _, h, p, b, l, r = self.owner.components.playercontroller:GetAllTypeContainers()
					if right and (h ~= nil or p ~= nil or b ~= nil or l ~= nil or r ~= nil) then
						help_string = help_string .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE) .. " " .. STRINGS.UI.HUD.CHANGEBOX
						help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. STRINGS.UI.HUD.CHANGEBOX
					else
						if not inv_item.replica.inventoryitem:IsGrandOwner(self.owner) then
							help_string = help_string .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE) .. " " .. STRINGS.UI.HUD.TAKE
						else
							local scene_action = self.owner.components.playercontroller:GetItemUseAction(inv_item)
							if scene_action ~= nil then
								help_string = help_string .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE) .. " " .. scene_action:GetActionString()
							end
						end
						local self_action = self.owner.components.playercontroller:GetItemSelfAction(inv_item)
						if self_action ~= nil then
							if help_string ~= nil then help_string = help_string .. "  " end
							help_string = help_string .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. self_action:GetActionString()
						end
					end
				else
					local self_action = self.owner.components.playercontroller:GetItemSelfAction(inv_item)
					if self_action ~= nil and self_action.action ~= ACTIONS.UNEQUIP then
						help_string = help_string .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE) .. " " .. self_action:GetActionString()
					end
					if #self.inv > 0 and not (inv_item:HasTag("heavy") or GetGameModeProperty("non_item_equips")) then
						help_string = help_string .. "  " .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF) .. " " .. STRINGS.UI.HUD.UNEQUIP
					end
				end
				if help_string ~= "" then
					table.insert(str, help_string)
				end
				
				help_string = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP) .. " " .. GetDropActionString(self.owner, inv_item)
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
				end
			end

			local was_shown = self.actionstring.shown
			local old_string = self.actionstringbody:GetString()
			local new_string = table.concat(str, '\n')
			if old_string ~= new_string then
				self.actionstringbody:SetString(new_string)
				self.actionstringtime = CURSOR_STRING_DELAY
				self.actionstring:Show()
			end

			local w0, h0 = self.actionstringtitle:GetRegionSize()
			local w1, h1 = self.actionstringbody:GetRegionSize()

			local wmax = math.max(w0, w1)

			local dest_pos = self.active_slot:GetWorldPosition()

			local xscale, yscale, zscale = self.root:GetScale():Get()

			if self.active_slot.container ~= nil and self.active_slot.container.issidewidget and not Profile:GetIntegratedBackpack() then
				-- backpack
				self.actionstringtitle:SetPosition(-wmax/2, h0/2)
				self.actionstringbody:SetPosition(-wmax/2, -h1/2)

				dest_pos.x = dest_pos.x + ((-240) - self.active_slot.container.widget.slotpos[self.active_slot.num].x) * xscale
			elseif self.active_slot.container ~= nil and self.active_slot.container.type == "side_inv_behind" and not Profile:GetIntegratedBackpack() then
				-- beard
				self.actionstringtitle:SetPosition(-wmax/2, h0/2)
				self.actionstringbody:SetPosition(-wmax/2, -h1/2)

				local degree_dist = (#self.active_slot.container.widget.slotpos - 1) * 20
				dest_pos.x = dest_pos.x + ((-100) - degree_dist - self.active_slot.container.widget.slotpos[self.active_slot.num].x) * xscale
			elseif self.active_slot.side_align_tip then
				-- in-game containers, chests, fridge
				self.actionstringtitle:SetPosition(wmax/2, h0/2)
				self.actionstringbody:SetPosition(wmax/2, -h1/2)

				dest_pos.x = dest_pos.x + self.active_slot.side_align_tip * xscale
			elseif self.active_slot.top_align_tip then
				-- main inventory
				self.actionstringtitle:SetPosition(0, h0/2 + h1)
				self.actionstringbody:SetPosition(0, h1/2)

				dest_pos.y = dest_pos.y + (self.active_slot.top_align_tip + TIP_YFUDGE) * yscale
			elseif self.active_slot.bottom_align_tip then
				
				self.actionstringtitle:SetPosition(0, -h0/2)
				self.actionstringbody:SetPosition(0, -(h1/2 + h0))

				dest_pos.y = dest_pos.y + (self.active_slot.bottom_align_tip + TIP_YFUDGE) * yscale
			else
				-- old default as fallback ?
				self.actionstringtitle:SetPosition(0, h0/2 + h1)
				self.actionstringbody:SetPosition(0, h1/2)

				dest_pos.y = dest_pos.y + (W/2 + TIP_YFUDGE) * yscale
			end

			-- print("self.active_slot:GetWorldPosition()", self.active_slot:GetWorldPosition())
			-- print("h0", h0)
			-- print("w0", w0)
			-- print("h1", h1)
			-- print("w1", h1)
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
			self.actionstring:Hide()
		end
	end
end)
