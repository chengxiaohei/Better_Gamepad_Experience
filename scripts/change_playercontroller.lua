
AddComponentPostInit("playercontroller", function(self)
	-- New Added
	local QueryContainerType = function(self, inst) 
		local container = inst.components.container
		local type = nil
		if inst == self.inst then
			type = "inv"
		elseif container.type == "pack" or container.type == "backpack" then 
			type = "pack" 
		elseif container.type == "side_inv_behind" then 
			type = "beard"
		elseif container.type == "hand_inv" then 
			type = "hand"
		else
			type = container.type   -- [[ "cooker" or "chest" ]]
		end
		return type
	end

	-- New Added
	local GetContainerWithType = function (self, type)
		local opened_containers = self.inst.replica.inventory:GetOpenContainers()
		for c, _ in pairs(opened_containers) do 
			if type == QueryContainerType(self, c) then
				return c
			end
		end
	end
	
	-- New Added
	local GetAllTypeContainers = function (self)
		local opened_containers = self.inst.replica.inventory:GetOpenContainers()
		local h,p,b,l,r 
		for c, _ in pairs(opened_containers) do 
			if QueryContainerType(self, c) == "hand" then h = c
			elseif QueryContainerType(self, c) == "pack" then p = c
			elseif QueryContainerType(self, c) == "beard" then b = c
			elseif QueryContainerType(self, c) == "chest" then l = c
			elseif QueryContainerType(self, c) == "cooker" then r = c
			end
		end

		-- inv,hand,pack,beard,chest,cooker
		return self.inst, h, p, b, l, r
	end

	-- New Added
	local FilterContainer = function (targetitem, checklist)
		if targetitem ~= nil then
			for _, c in ipairs(checklist) do
				if c ~= nil and (
					(c.components.inventory ~= nil and c.components.inventory:CanAcceptCount(targetitem) ~= 0) or
					(c.components.container ~= nil and c.components.container:CanAcceptCount(targetitem) ~= 0)) then
					return c
				end
			end
		end
	end

	local PutActiveItemInContainer = function (self, active_item, container, single)
		local store_success = false
		if container ~= nil and active_item ~= nil and container.replica.container ~= nil then
			for islot = 1, container.components.container.numslots do
				local iitem = container.replica.container:GetItemInSlot(islot)
				--Add active item to slot stack
				if iitem ~= nil and container.replica.container:CanTakeItemInSlot(active_item, islot) and
					iitem.prefab == active_item.prefab and iitem.AnimState:GetSkinBuild() == active_item.AnimState:GetSkinBuild() and
					iitem.replica.stackable ~= nil and container.replica.container:AcceptsStacks() then
					if single and
						active_item.replica.stackable ~= nil and
						active_item.replica.stackable:IsStack() and
						not iitem.replica.stackable:IsFull() then
						--Add only one
						container.replica.container:AddOneOfActiveItemToSlot(islot)
					else -- must be right
						--Add entire stack
						container.replica.container:AddAllOfActiveItemToSlot(islot)
					end
					store_success = true
					break
				end
			end
			if not (store_success or container.replica.container:IsFull()) then
				for islot = 1, container.components.container.numslots do
					local iitem = container.replica.container:GetItemInSlot(islot)
					--Put active item into empty slot
					if iitem == nil and container.replica.container:CanTakeItemInSlot(active_item, islot) then
						if active_item.replica.stackable ~= nil and
							active_item.replica.stackable:IsStack() and
							(single or not container.replica.container:AcceptsStacks()) then
							--Put one only
							container.replica.container:PutOneOfActiveItemInSlot(islot)
						else
							--Put entire stack
							container.replica.container:PutAllOfActiveItemInSlot(islot)
						end
						store_success = true
						break
					end
				end
			end
			if store_success then
				TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
			else
				TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
			end
		end
		return store_success
	end

	-- New Added
	local ChangePlayerController = function (self, control, inv_item, active_item, slot, container, target, left, right)

		if control == CONTROL_INVENTORY_DROP then
			self:DoControllerDropItemFromInvTile(active_item or inv_item, right)
		elseif control == CONTROL_INVENTORY_EXAMINE then
			self:DoControllerInspectItemFromInvTile(active_item or inv_item)
		elseif control == CONTROL_INVENTORY_USEONSELF then
			if left and right then
				PutActiveItemInContainer(self, active_item, inv_item, true)
			elseif left then
				PutActiveItemInContainer(self, active_item, inv_item, false)
			elseif right then
				if container ~= nil and slot ~= nil then
					local cursor_container_type = QueryContainerType(self, container.inst)
					local iv,hc,pc,bc,lc,rc = GetAllTypeContainers(self)
					local container_list = {}
					if cursor_container_type == "inv" then
						--put into (rc or lc or bc or pc or hc or iv)
						table.insert(container_list, rc) table.insert(container_list, lc) table.insert(container_list, bc)
						table.insert(container_list, pc) table.insert(container_list, hc) table.insert(container_list, iv)
						container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
					elseif cursor_container_type == "hand" then
						-- put into (rc or lc or bc or pc or iv or hc)
						table.insert(container_list, rc) table.insert(container_list, lc) table.insert(container_list, bc)
						table.insert(container_list, pc) table.insert(container_list, iv) table.insert(container_list, hc)
						container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
					elseif cursor_container_type == "pack" then
						-- put into (rc or lc or bc or hc or iv or pc)
						table.insert(container_list, rc) table.insert(container_list, lc) table.insert(container_list, bc)
						table.insert(container_list, hc) table.insert(container_list, iv) table.insert(container_list, pc)
						container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
					elseif cursor_container_type == "beard" then
						-- put into (rc or lc or pc or hc or iv or bc)
						table.insert(container_list, rc) table.insert(container_list, lc) table.insert(container_list, pc)
						table.insert(container_list, hc) table.insert(container_list, iv) table.insert(container_list, bc)
						container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
					elseif cursor_container_type == "chest" then
						-- put into (rc or bc or pc or hc or iv or lc)
						table.insert(container_list, rc) table.insert(container_list, bc) table.insert(container_list, pc)
						table.insert(container_list, hc) table.insert(container_list, iv) table.insert(container_list, lc)
						container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
					elseif cursor_container_type == "cooker" then
						-- put into (bc or pc or hc or iv or lc or rc)
						table.insert(container_list, bc) table.insert(container_list, pc) table.insert(container_list, hc)
						table.insert(container_list, iv) table.insert(container_list, lc) table.insert(container_list, rc)
						container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
					end
				end
			else
				if inv_item ~= nil and active_item ~= nil then
					self.inst.replica.inventory:ControllerUseItemOnItemFromInvTile(inv_item, active_item)
				else
					self:DoControllerUseItemOnSelfFromInvTile(active_item or inv_item)
				end
			end

		elseif control == CONTROL_INVENTORY_USEONSCENE then
			if right then
				if container ~= nil and slot ~= nil then
					local cursor_container_type = QueryContainerType(self, container.inst)
					local iv,hc,pc,bc,lc,rc = GetAllTypeContainers(self)
					local container_list = {}
					if cursor_container_type == "inv" then
						--put into (lc or rc or bc or pc or hc or iv)
						table.insert(container_list, lc) table.insert(container_list, rc) table.insert(container_list, bc)
						table.insert(container_list, pc) table.insert(container_list, hc) table.insert(container_list, iv)
						container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
					elseif cursor_container_type == "hand" then
						-- put into (lc or rc or iv or bc or pc or hc)
						table.insert(container_list, lc) table.insert(container_list, rc) table.insert(container_list, iv)
						table.insert(container_list, bc) table.insert(container_list, pc) table.insert(container_list, hc)
						container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
					elseif cursor_container_type == "pack" then
						-- put into (lc or rc or iv or hc or bc or pc)
						table.insert(container_list, lc) table.insert(container_list, rc) table.insert(container_list, iv)
						table.insert(container_list, hc) table.insert(container_list, bc) table.insert(container_list, pc)
						container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
					elseif cursor_container_type == "beard" then
						-- put into (lc or rc or iv or hc or pc or bc)
						table.insert(container_list, lc) table.insert(container_list, rc) table.insert(container_list, iv)
						table.insert(container_list, hc) table.insert(container_list, pc) table.insert(container_list, bc)
						container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
					elseif cursor_container_type == "chest" then
						-- put into (iv or hc or bc or pc or rc or lc)
						table.insert(container_list, iv) table.insert(container_list, hc) table.insert(container_list, bc)
						table.insert(container_list, pc) table.insert(container_list, rc) table.insert(container_list, lc)
						container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
					elseif cursor_container_type == "cooker" then
						-- put into (lc or iv or hc or bc or pc or rc)
						table.insert(container_list, lc) table.insert(container_list, iv) table.insert(container_list, hc)
						table.insert(container_list, bc) table.insert(container_list, pc) table.insert(container_list, rc)
						container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
					end
				end
			elseif left then
				if inv_item ~= nil and container ~= nil and slot ~= nil then
					local cursor_container_type = QueryContainerType(self, container.inst)
					if cursor_container_type == "chest" or cursor_container_type == "cooker" then
						container:MoveItemFromHalfOfSlot(slot, GetContainerWithType(self, "beard") or self.inst)
					else
						container:MoveItemFromHalfOfSlot(slot, GetContainerWithType(self, "chest") or GetContainerWithType(self, "cooker"))
					end
				end
			else
				self:DoControllerUseItemOnSceneFromInvTile(active_item or inv_item)
			end
		elseif control == CONTROL_OPEN_INVENTORY then
			if inv_item ~= nil or active_item ~= nil then
				if self.inst.HUD.controls.inv.active_slot ~= nil then
					self.inst.HUD.controls.inv.active_slot:Click(left)
				end
			end
		end
	end

	local OnControl_Old = self.OnControl
	local OnControl_New = function (self, control, down, ...)
		-- do this first in order to not lose an up/down and get out of sync
		if control == CONTROL_TARGET_MODIFIER then
			self.controller_targeting_modifier_down = down
			if down then
				self.controller_targeting_lock_timer = 0.0
			else
				self.controller_targeting_lock_timer = nil
			end
		end

		if IsPaused() then
			return
		end

		local isenabled, ishudblocking = self:IsEnabled()
		if not isenabled and not ishudblocking then
			return
		end

		-- actions that can be done while the crafting menu is open go in here
		if isenabled or ishudblocking then
			if control == CONTROL_ACTION then
				self:DoActionButton()
			elseif control == CONTROL_ATTACK then
				if self.ismastersim then
					self.attack_buffer = CONTROL_ATTACK
				else
					self:DoAttackButton()
				end
			end
		end

		if not isenabled then
			return
		end

		if control == CONTROL_PRIMARY then
			self:OnLeftClick(down)
		elseif control == CONTROL_SECONDARY then
			self:OnRightClick(down)
		elseif not down then
			if not self.ismastersim then
				self:RemoteStopControl(control)
			end
		elseif control == CONTROL_CANCEL then
			self:CancelPlacement()
			self:ControllerTargetLock(false)
		elseif control == CONTROL_INSPECT then
			self:DoInspectButton()
		elseif control == CONTROL_CONTROLLER_ALTACTION then
			self:DoControllerAltActionButton()
		elseif control == CONTROL_CONTROLLER_ACTION then
			self:DoControllerActionButton()
		elseif control == CONTROL_CONTROLLER_ATTACK then
			if self.ismastersim then
				self.attack_buffer = CONTROL_CONTROLLER_ATTACK
			else
				self:DoControllerAttackButton()
			end
		elseif self.controller_targeting_modifier_down then
			if control == CONTROL_TARGET_CYCLE_BACK then
				self:CycleControllerAttackTargetBack()
			elseif control == CONTROL_TARGET_CYCLE_FORWARD then
				self:CycleControllerAttackTargetForward()
			end
		elseif self.inst.replica.inventory:IsVisible() then
			local inv_obj = self:GetCursorInventoryObject()
			local active_obj = self.inst.replica.inventory:GetActiveItem()
			local slot, container = self:GetCursorInventorySlotAndContainer() ---------------------------------------
			local target = self:GetControllerTarget()
			ChangePlayerController(self, control, inv_obj, active_obj, slot, container, target, Input:IsControlPressed(CHANGE_CONTROL_LEFT), Input:IsControlPressed(CHANGE_CONTROL_RIGHT))
		end
	end

	self.OnControl = function(self, control, down, ...)
		if TheInput:ControllerAttached() then
			return OnControl_New(self, control, down, ...)
		else
			return OnControl_Old(self, control, down, ...)
		end
	end

	-- Used for bind CHOP/MINE/NET operations to Button B ----------------------------------------------------
	local ToggleController_Old = self.ToggleController
	local CHOP_rmb_Old = ACTIONS.CHOP.rmb
	local CHOP_invalid_hold_action_Old = ACTIONS.CHOP.invalid_hold_action
	local MINE_rmb_Old = ACTIONS.MINE.rmb
	local MINE_invalid_hold_action_Old = ACTIONS.MINE.invalid_hold_action
	local NET_rmb_Old = ACTIONS.NET.rmb
	self.ToggleController = function(self, val, ...)
		if val and TheInput:ControllerAttached() then
			ACTIONS.CHOP.rmb = true; ACTIONS.CHOP.invalid_hold_action = false
			ACTIONS.MINE.rmb = true; ACTIONS.MINE.invalid_hold_action = false
			ACTIONS.NET.rmb = true
		else
			ACTIONS.CHOP.rmb = CHOP_rmb_Old; ACTIONS.CHOP.invalid_hold_action = CHOP_invalid_hold_action_Old
			ACTIONS.MINE.rmb = MINE_rmb_Old; ACTIONS.MINE.invalid_hold_action = MINE_invalid_hold_action_Old
			ACTIONS.NET.rmb = NET_rmb_Old
		end
		return ToggleController_Old(self, val, ...)
	end

	-- Used for change the way your camera control ----------------------------------------------------------------------
	local DoCameraControl_Old = self.DoCameraControl
	local CHANGE_ROT_REPEAT = .25
	local CHANGE_ZOOM_REPEAT = .1
	local DoCameraControl_New = function(self, ...)
		if not TheCamera:CanControl() then
			return
		end

		local isenabled, ishudblocking = self:IsEnabled()
		if not isenabled and not ishudblocking then
			return
		end

		local time = GetStaticTime()

		if self.lastrottime == nil or time - self.lastrottime > CHANGE_ROT_REPEAT then
			if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
				if TheInput:IsControlPressed(CONTROL_INVENTORY_RIGHT) then
					self:RotLeft()
					self.lastrottime = time
				elseif TheInput:IsControlPressed(CONTROL_INVENTORY_LEFT) then
					self:RotRight()
					self.lastrottime = time
				end
			end
		end

		if self.lastzoomtime == nil or time - self.lastzoomtime > CHANGE_ZOOM_REPEAT then
			if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
				if TheInput:IsControlPressed(CONTROL_INVENTORY_UP) then
					TheCamera:ZoomIn()
					self.lastzoomtime = time
				elseif TheInput:IsControlPressed(CONTROL_INVENTORY_DOWN) then
					TheCamera:ZoomOut()
					self.lastzoomtime = time
				end
			end
		end
	end
	self.DoCameraControl = function(self, ...)
		if TheInput:ControllerAttached() then
			return DoCameraControl_New(self, ...)
		else
			return DoCameraControl_Old(self, ...)
		end
	end

	local IsEnabled_Old = self.IsEnabled
	self.IsEnabled = function (self, ...)
		local isenabled, ishudblocking = IsEnabled_Old(self, ...)
		if not isenabled and ishudblocking ~= nil then
			local active_screen = TheFrontEnd:GetActiveScreen()
			if active_screen ~= nil and active_screen ~= self.inst.HUD then
				return false
			end
			if TheFrontEnd.textProcessorWidget ~= nil then
				return false
			end
			return true
		end
		return isenabled, ishudblocking
	end

end)