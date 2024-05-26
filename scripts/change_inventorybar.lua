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

		if self:CursorNav(Vector3(-1,0,0), true) then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		elseif not self.open and not self.pin_nav and self.owner.HUD.controls.craftingmenu.is_left_aligned and self:PinBarNav(self.owner.HUD.controls.craftingmenu:InvNavToPin(self.active_slot, -1, 0)) then
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

		if self:CursorNav(Vector3(1,0,0), true) then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		elseif not self.open and not self.pin_nav and not self.owner.HUD.controls.craftingmenu.is_left_aligned and self:PinBarNav(self.owner.HUD.controls.craftingmenu:InvNavToPin(self.active_slot, 1, 0)) then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
		end
	end

	local CursorUp_Old = self.CursorUp
	self.CursorUp = function (self, ...)
		if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
			return true
		end
		CursorUp_Old(self, ...)
	end

	local CursorDown_Old = self.CursorDown
	self.CursorDown = function (self, ...)
		if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
			return true
		end
		CursorDown_Old(self, ...)
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
	self.Rebuild = function(self, ...)
		if CHNAGE_CHANGE_INVENTORY_BAR then
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
			self.integrated_backpack = controller_attached or Profile:GetIntegratedBackpack()

			local inventory = self.owner.replica.inventory

			local overflow = inventory:GetOverflowContainer()
			overflow = (overflow ~= nil and overflow:IsOpenedBy(self.owner)) and overflow or nil

			local do_integrated_backpack = overflow ~= nil and self.integrated_backpack
			local do_self_inspect = not (self.controller_build or GetGameModeProperty("no_avatar_popup"))

			-- Only Add This Two Line
			do_integrated_backpack = false
			do_self_inspect = true

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
		else
			Rebuild_Old(self, ...)
		end
	end
end)
