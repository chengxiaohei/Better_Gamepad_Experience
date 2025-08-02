
AddComponentPostInit("playercontroller", function(self)
	-- New Added
	local QueryContainerType = function(self, inst) 
		local container = inst.replica.container
		local type = nil
		if inst == self.inst then
			type = "inv"
		elseif container ~= nil then
			if  container.type == "pack" or container.type == "backpack" then 
				type = "pack"
			elseif container.type == "side_inv_behind" then 
				type = "beard"
			elseif container.type == "hand_inv" then 
				type = "hand"
			else
				type = container.type   -- [[ "cooker" or "chest" ]]
			end
		end
		-- print("****** type:", type)
		return type
	end
	
	-- New Added
	self.GetAllTypeContainers = function (self)
		local opened_containers = self.inst.replica.inventory:GetOpenContainers()
		local h,p,b,l,r
		for c, _ in pairs(opened_containers) do
			local type = QueryContainerType(self, c)
			if type == "hand" then h = c
			elseif type == "pack" then p = c
			elseif type == "beard" then b = c
			elseif type == "chest" then l = c
			elseif type == "cooker" then r = c
			end
		end

		-- print("******".."self.inst:", self.inst, "hand:", h, "pack:", p, "beard:", b, "chest:", l, "cooker:", r)
		-- inv,hand,pack,beard,chest,cooker
		return self.inst, h, p, b, l, r
	end

	-- New Added
	local FilterContainer = function (targetitem, checklist)
		local find = false
		local filtered_container = nil
		if targetitem ~= nil then
			for _, container in ipairs(checklist) do
				if container ~= nil and container.replica.container ~= nil then
					for islot = 1, container.replica.container:GetNumSlots() do
						local iitem = container.replica.container:GetItemInSlot(islot)
						if iitem ~= nil and container.replica.container:CanTakeItemInSlot(targetitem, islot) and
							iitem.prefab == targetitem.prefab and iitem.AnimState:GetSkinBuild() == targetitem.AnimState:GetSkinBuild() and
							iitem.replica.stackable ~= nil and not iitem.replica.stackable:IsFull() and container.replica.container:AcceptsStacks() then
							find = true
							filtered_container = container
							break
						end
					end
					if not (find or container.replica.container:IsFull()) then
						for islot = 1, container.replica.container:GetNumSlots() do
							local iitem = container.replica.container:GetItemInSlot(islot)
							if iitem == nil and container.replica.container:CanTakeItemInSlot(targetitem, islot) then
								find = true
								filtered_container = container
								break
							end
						end
					end
				end

				if not find and container ~= nil and container.replica.inventory ~= nil then
					for islot = 1, container.replica.inventory:GetNumSlots() do
						local iitem = container.replica.inventory:GetItemInSlot(islot)
						if iitem ~= nil and container.replica.inventory:CanTakeItemInSlot(targetitem, islot) and
							iitem.prefab == targetitem.prefab and iitem.AnimState:GetSkinBuild() == targetitem.AnimState:GetSkinBuild() and
							iitem.replica.stackable ~= nil and not iitem.replica.stackable:IsFull() and container.replica.inventory:AcceptsStacks() then
							find = true
							filtered_container = container
							break
						end
					end
					if not (find or container.replica.inventory:IsFull()) then
						for islot = 1, container.replica.inventory:GetNumSlots() do
							local iitem = container.replica.inventory:GetItemInSlot(islot)
							if iitem == nil and container.replica.inventory:CanTakeItemInSlot(targetitem, islot) then
								find = true
								filtered_container = container
								break
							end
						end
					end
				end
				if find then break end
			end
			if find then
				TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
			else
				TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
			end
		end
		return filtered_container
	end

	local PutActiveItemInContainer = function (self, active_item, container, single)
		local store_success = false
		if container ~= nil and active_item ~= nil and container.replica.container ~= nil then
			for islot = 1, container.replica.container:GetNumSlots() do
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
					else
						--Add entire stack
						container.replica.container:AddAllOfActiveItemToSlot(islot)
					end
					store_success = true
					break
				end
			end
			if not (store_success or container.replica.container:IsFull()) then
				for islot = 1, container.replica.container:GetNumSlots() do
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

	self.DoControllerOneStepForwardAndDropActiveItem = function (self, item, single)
		local act = self.inst.components.playeractionpicker:GetLeftClickActions(self.Change_drop_position)[1]

		if item ~= nil and act ~= nil and act.action == ACTIONS.DROP then
			local spellbook, spell_id
			if self:IsAOETargeting() then
				spellbook = self:GetActiveSpellBook()
				if spellbook ~= nil then
					spell_id = spellbook.components.spellbook:GetSelectedSpell()
				end
			end
			local platform, pos_x, pos_z = self:GetPlatformRelativePosition(self.Change_drop_position.x, self.Change_drop_position.z)
			if self.locomotor == nil then
				-- NOTES(JBK): Does not call locomotor component functions needed for pre_action_cb, manual call here.
				if act.action.pre_action_cb ~= nil then
					act.action.pre_action_cb(act)
				end
				SendRPCToServer(RPC.LeftClick, act.action.code, pos_x, pos_z, nil, true, single and 8 or nil, act.action.canforce, act.action.mod_name, platform, platform ~= nil, spellbook, spell_id)
			elseif self:CanLocomote() then
				act.preview_cb = function()
					SendRPCToServer(RPC.LeftClick, act.action.code, pos_x, pos_z, nil, true, single and 8 or nil, nil, act.action.mod_name, platform, platform ~= nil, spellbook, spell_id)
				end
			end
			act.options.wholestack = not single
			self:DoAction(act, spellbook)
		end
	end

	local Double_Click_Gap_Time = GetTime()
	local Status_Announce_Time = GetTime()
	-- New Added
	local ChangePlayerController = function (self, control, inv_item, active_item, slot, container, target, left, right)
		self:ClearActionHold()
		if control == CONTROL_INVENTORY_DROP then
			if right and active_item ~= nil and inv_item ~= nil then
				self:DoControllerDropItemFromInvTile(inv_item, left)
			else
				if active_item ~= nil and active_item.replica.inventoryitem then
					self:DoControllerDropItemFromInvTile(active_item, left)
				elseif inv_item ~= nil and inv_item.replica.inventoryitem then
					self:DoControllerDropItemFromInvTile(inv_item, left)
				end
			end
		elseif control == CONTROL_INVENTORY_EXAMINE then
			if not TryTriggerMappingKey(self.inst, CHANGE_MAPPING_LB_UP, CHANGE_MAPPING_RB_UP, CHANGE_MAPPING_LB_RB_UP, false) and
				not TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_UP, CHANGE_MAPPING_RB_UP, CHANGE_MAPPING_LB_RB_UP, true, false) and
				not TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_UP, CHANGE_MAPPING_RB_UP, CHANGE_MAPPING_LB_RB_UP, false, false) then
				if active_item ~= nil and active_item.replica.inventoryitem then
					self:DoControllerInspectItemFromInvTile(active_item)
				elseif inv_item ~= nil and inv_item.replica.inventoryitem then
					self:DoControllerInspectItemFromInvTile(inv_item)
				end
				local DeltaTime = GetTime() - Double_Click_Gap_Time
				local Should_Announce = DeltaTime > 0 and DeltaTime < 0.3 and GetTime() - Status_Announce_Time > 1
				if Should_Announce and inv_item then
					local exist, StatusAnnouncerModule = pcall(require, "statusannouncer")
					if exist then
						local StatusAnnouncer = StatusAnnouncerModule and StatusAnnouncerModule()
						StatusAnnouncer:AnnounceItem(self.inst.HUD.controls.inv.active_slot)
						Status_Announce_Time = GetTime()
					end
				end
				Double_Click_Gap_Time = GetTime()
			end
		elseif control == CONTROL_INVENTORY_USEONSELF then
			if left and active_item ~= nil and inv_item ~= nil and inv_item.replica.container ~= nil and inv_item.replica.container:IsOpenedBy(self.inst) then
				PutActiveItemInContainer(self, active_item, inv_item, true)
			elseif right and container ~= nil and slot ~= nil and inv_item ~= nil then
				local cursor_container_type = QueryContainerType(self, container.inst)
				local iv,hc,pc,bc,lc,rc = self:GetAllTypeContainers()
				local container_list = {}
				local filtered_container
				if cursor_container_type == "inv" then
					--put into (rc or lc or bc or pc or hc or iv)
					table.insert(container_list, rc) table.insert(container_list, lc) table.insert(container_list, bc)
					table.insert(container_list, pc) table.insert(container_list, hc) --[[ table.insert(container_list, iv) ]]
					filtered_container = FilterContainer(inv_item, container_list)
					if filtered_container then container:MoveItemFromAllOfSlot(slot, filtered_container) end
				elseif cursor_container_type == "hand" then
					-- put into (rc or lc or bc or pc or iv or hc)
					table.insert(container_list, rc) table.insert(container_list, lc) table.insert(container_list, bc)
					table.insert(container_list, pc) table.insert(container_list, iv) --[[ table.insert(container_list, hc) ]]
					filtered_container = FilterContainer(inv_item, container_list)
					if filtered_container then container:MoveItemFromAllOfSlot(slot, filtered_container) end
				elseif cursor_container_type == "pack" then
					-- put into (rc or lc or bc or hc or iv or pc)
					table.insert(container_list, rc) table.insert(container_list, lc) table.insert(container_list, bc)
					table.insert(container_list, hc) table.insert(container_list, iv) --[[ table.insert(container_list, pc) ]]
					filtered_container = FilterContainer(inv_item, container_list)
					if filtered_container then container:MoveItemFromAllOfSlot(slot, filtered_container) end
				elseif cursor_container_type == "beard" then
					-- put into (rc or lc or pc or hc or iv or bc)
					table.insert(container_list, rc) table.insert(container_list, lc) table.insert(container_list, pc)
					table.insert(container_list, hc) table.insert(container_list, iv) --[[ table.insert(container_list, bc) ]]
					filtered_container = FilterContainer(inv_item, container_list)
					if filtered_container then container:MoveItemFromAllOfSlot(slot, filtered_container) end
				elseif cursor_container_type == "chest" then
					-- put into (rc or bc or pc or hc or iv or lc)
					table.insert(container_list, rc) table.insert(container_list, bc) table.insert(container_list, pc)
					table.insert(container_list, hc) table.insert(container_list, iv) --[[ table.insert(container_list, lc) ]]
					filtered_container = FilterContainer(inv_item, container_list)
					if filtered_container then container:MoveItemFromAllOfSlot(slot, filtered_container) end
				elseif cursor_container_type == "cooker" then
					-- put into (bc or pc or hc or iv or lc or rc)
					table.insert(container_list, bc) table.insert(container_list, pc) table.insert(container_list, hc)
					table.insert(container_list, iv) table.insert(container_list, lc) --[[ table.insert(container_list, rc) ]]
					filtered_container = FilterContainer(inv_item, container_list)
					if filtered_container then container:MoveItemFromAllOfSlot(slot, filtered_container) end
				end
			else
				if inv_item ~= nil and active_item ~= nil and active_item.replica.inventoryitem and self:GetItemUseAction(active_item, inv_item) ~= nil then
					self.inst.replica.inventory:ControllerUseItemOnItemFromInvTile(inv_item, active_item)
				else
					if active_item ~= nil and active_item.replica.inventoryitem then
						self:DoControllerUseItemOnSelfFromInvTile(active_item)
					elseif inv_item ~= nil and inv_item.replica.inventoryitem then
						self:DoControllerUseItemOnSelfFromInvTile(inv_item)
					end
				end
			end

		elseif control == CONTROL_INVENTORY_USEONSCENE then
			if right and container ~= nil and slot ~= nil and inv_item ~= nil then
				local cursor_container_type = QueryContainerType(self, container.inst)
				local iv,hc,pc,bc,lc,rc = self:GetAllTypeContainers()
				local container_list = {}
				local filtered_container
				if cursor_container_type == "inv" then
					--put into (lc or rc or bc or pc or hc or iv)
					table.insert(container_list, lc) table.insert(container_list, rc) table.insert(container_list, bc)
					table.insert(container_list, pc) table.insert(container_list, hc) --[[ table.insert(container_list, iv) ]]
					filtered_container = FilterContainer(inv_item, container_list)
					if filtered_container then container:MoveItemFromAllOfSlot(slot, filtered_container) end
				elseif cursor_container_type == "hand" then
					-- put into (lc or rc or iv or bc or pc or hc)
					table.insert(container_list, lc) table.insert(container_list, rc) table.insert(container_list, iv)
					table.insert(container_list, bc) table.insert(container_list, pc) --[[ table.insert(container_list, hc) ]]
					filtered_container = FilterContainer(inv_item, container_list)
					if filtered_container then container:MoveItemFromAllOfSlot(slot, filtered_container) end
				elseif cursor_container_type == "pack" then
					-- put into (lc or rc or iv or hc or bc or pc)
					table.insert(container_list, lc) table.insert(container_list, rc) table.insert(container_list, iv)
					table.insert(container_list, hc) table.insert(container_list, bc) --[[ table.insert(container_list, pc) ]]
					filtered_container = FilterContainer(inv_item, container_list)
					if filtered_container then container:MoveItemFromAllOfSlot(slot, filtered_container) end
				elseif cursor_container_type == "beard" then
					-- put into (lc or rc or iv or hc or pc or bc)
					table.insert(container_list, lc) table.insert(container_list, rc) table.insert(container_list, iv)
					table.insert(container_list, hc) table.insert(container_list, pc) --[[ table.insert(container_list, bc) ]]
					filtered_container = FilterContainer(inv_item, container_list)
					if filtered_container then container:MoveItemFromAllOfSlot(slot, filtered_container) end
				elseif cursor_container_type == "chest" then
					-- put into (iv or hc or bc or pc or rc or lc)
					table.insert(container_list, iv) table.insert(container_list, hc) table.insert(container_list, bc)
					table.insert(container_list, pc) table.insert(container_list, rc) --[[ table.insert(container_list, lc) ]]
					filtered_container = FilterContainer(inv_item, container_list)
					if filtered_container then container:MoveItemFromAllOfSlot(slot, filtered_container) end
				elseif cursor_container_type == "cooker" then
					-- put into (lc or iv or hc or bc or pc or rc)
					table.insert(container_list, lc) table.insert(container_list, iv) table.insert(container_list, hc)
					table.insert(container_list, bc) table.insert(container_list, pc) --[[ table.insert(container_list, rc) ]]
					filtered_container = FilterContainer(inv_item, container_list)
					if filtered_container then container:MoveItemFromAllOfSlot(slot, filtered_container) end
				end
			else
				if active_item ~= nil and active_item.replica.inventoryitem then
					self:DoControllerUseItemOnSceneFromInvTile(active_item)
				elseif inv_item ~= nil and inv_item.replica.inventoryitem then
					self:DoControllerUseItemOnSceneFromInvTile(inv_item)
				end
			end
		elseif control == CONTROL_OPEN_INVENTORY then
			if not TryTriggerMappingKey(self.inst, false, CHANGE_MAPPING_RB_RT, CHANGE_MAPPING_LB_RB_RT, false) and
				not TryTriggerKeyboardMappingKey(false, CHANGE_MAPPING_RB_RT, CHANGE_MAPPING_LB_RB_RT, true, false) and
				not TryTriggerKeyboardMappingKey(false, CHANGE_MAPPING_RB_RT, CHANGE_MAPPING_LB_RB_RT, false, false) then
				if inv_item ~= nil or active_item ~= nil then
					if self.inst.HUD.controls.inv.active_slot ~= nil then
						self.inst.HUD.controls.inv.active_slot:Click(left)
					end
				end
			end
		end
	end

	local ControllerTargetLock_Old = self.ControllerTargetLock
	self.ControllerTargetLock = function (self, ...)
		if self:IsControllerTargetLockEnabled() then
			ControllerTargetLock_Old(self, false)
		else
			ControllerTargetLock_Old(self, true)
		end
	end

	self.GetInspectButtonAction = function (self, target, ...)
		target = target or self:GetControllerAltTarget() or self:GetControllerAttackTarget()
		return target ~= nil and
			target:HasTag("inspectable") and
			(self.inst.CanExamine == nil or self.inst:CanExamine()) and
			(self.inst.sg == nil or self.inst.sg:HasStateTag("moving") or self.inst.sg:HasStateTag("idle")
				or self.inst.sg:HasStateTag("attack") or self.inst.sg:HasStateTag("doing") or self.inst.sg:HasStateTag("working") or self.inst.sg:HasStateTag("channeling")) and
			(self.inst:HasTag("moving") or self.inst:HasTag("idle")
				or self.inst:HasTag("attack") or self.inst:HasTag("doing") or self.inst:HasTag("working") or self.inst:HasTag("channeling")) and
			BufferedAction(self.inst, target, ACTIONS.LOOKAT) or
			nil
	end

	self.IsTargetCanBeLock = function (self, target)
		for _, v in ipairs(self.controller_targeting_targets) do
			if target == v then
				return not CHANGE_FORCE_BUTTON or not CHANGE_IS_FORCE_ATTACK or not self:IsNeedForceAttack(target) or TheInput:IsControlPressed(CHANGE_FORCE_BUTTON)
			end
		end
		return false
	end

	local origin_TUNING_CONTROLLER_RETICULE_RSTICK_SPEED = TUNING.CONTROLLER_RETICULE_RSTICK_SPEED
	local right_bumper_double_click_gap_time = GetTime()
	local right_bumper_click_count = 1

	local left_bumper_double_click_gap_time = GetTime()
	local left_bumper_click_count = 1

	self.Click_Right_Bumper_While_Holding_Left_Bumper = false
	self.Click_Left_Bumper_While_Holding_Right_Bumper = false

	local OnControl_Old = self.OnControl
	local OnControl_New = function (self, control, down, ...)

		if IsPaused() then
			return
		end

		local isenabled, ishudblocking = self:IsEnabled()
		if not isenabled and not ishudblocking then
			return
		end

		if down and self._hack_ignore_held_controls then
			self._hack_ignore_ups_for[control] = true
			return true
		end
		if not down and self._hack_ignore_ups_for and self._hack_ignore_ups_for[control] then
			self._hack_ignore_ups_for[control] = nil
			return true
		end

		-- Use Double/Triple/Quadruple/... Click Right Bumper to slow down reticule move speed
		if control == CHANGE_CONTROL_RIGHT then
			if down then
				local DeltaTime = GetTime() - right_bumper_double_click_gap_time
				if DeltaTime > 0 and DeltaTime < 0.3 then
					right_bumper_click_count = right_bumper_click_count + 1
					TUNING.CONTROLLER_RETICULE_RSTICK_SPEED = origin_TUNING_CONTROLLER_RETICULE_RSTICK_SPEED / right_bumper_click_count
					if right_bumper_click_count == 2 then
						self.Double_Click_Right_Bumper_And_Holding = true
					end
				end
				right_bumper_double_click_gap_time = GetTime()
			else
				local DeltaTime = GetTime() - right_bumper_double_click_gap_time
				if DeltaTime > 0.3 then
					right_bumper_click_count = 1
					TUNING.CONTROLLER_RETICULE_RSTICK_SPEED = origin_TUNING_CONTROLLER_RETICULE_RSTICK_SPEED
					self.Double_Click_Right_Bumper_And_Holding = false
				end
			end
		end

		if control == CHANGE_CONTROL_LEFT then
			if down then
				local DeltaTime = GetTime() - left_bumper_double_click_gap_time
				if DeltaTime > 0 and DeltaTime < 0.3 then
					left_bumper_click_count = left_bumper_click_count + 1
					if left_bumper_click_count == 2 then
						self.Double_Click_Left_Bumper_And_Holding = true
					end
				end
				left_bumper_double_click_gap_time = GetTime()
			else
				local DeltaTime = GetTime() - left_bumper_double_click_gap_time
				if DeltaTime > 0.3 then
					left_bumper_click_count = 1
					self.Double_Click_Left_Bumper_And_Holding = false
				end
			end
		end

		-- Indicate Left Bumper State and Right Bumper State
		if control == CHANGE_CONTROL_RIGHT then
			if down then
				if TheInput:IsControlPressed(CHANGE_CONTROL_LEFT) then
					self.Click_Right_Bumper_While_Holding_Left_Bumper = true
				end
			else
				self.Click_Right_Bumper_While_Holding_Left_Bumper = false
			end
		end

		if control == CHANGE_CONTROL_LEFT then
			if down then
				if TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
					self.Click_Left_Bumper_While_Holding_Right_Bumper = true
				end
			else
				self.Click_Left_Bumper_While_Holding_Right_Bumper = false
			end
		end

		if control == CONTROL_MENU_MISC_3 then
			if down then
				if TheInput:IsControlPressed(CHANGE_CONTROL_LEFT) and TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
					self.Click_Left_Stick_While_Holding_Left_Right_Bumper = true
				else
					if TheInput:IsControlPressed(CHANGE_CONTROL_LEFT) then
						self.Click_Left_Stick_While_Holding_Left_Bumper = true
					end
					if TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
						self.Click_Left_Stick_While_Holding_Right_Bumper = true
					end
				end
			else
				self.Click_Left_Stick_While_Holding_Left_Right_Bumper = false
				self.Click_Left_Stick_While_Holding_Left_Bumper = false
				self.Click_Left_Stick_While_Holding_Right_Bumper = false
			end
		end

		if control == CONTROL_MENU_MISC_4 then
			if down then
				if TheInput:IsControlPressed(CHANGE_CONTROL_LEFT) and TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
					self.Click_Right_Stick_While_Holding_Left_Right_Bumper = true
				else
					if TheInput:IsControlPressed(CHANGE_CONTROL_LEFT) then
						self.Click_Right_Stick_While_Holding_Left_Bumper = true
					end
					if TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
						self.Click_Right_Stick_While_Holding_Right_Bumper = true
					end
				end
			else
				self.Click_Right_Stick_While_Holding_Left_Right_Bumper = false
				self.Click_Right_Stick_While_Holding_Left_Bumper = false
				self.Click_Right_Stick_While_Holding_Right_Bumper = false
			end
		end

		--V2C: control up happens here now
		if not down and control ~= CONTROL_PRIMARY and control ~= CONTROL_SECONDARY then
			if not self.ismastersim then
				self:RemoteStopControl(control)
			end
			return
		end

		-- actions that can be done while the crafting menu is open go in here
		if isenabled or ishudblocking then
			if control == CONTROL_ACTION then
				self:DoActionButton()
				return
			elseif control == CONTROL_ATTACK then
				if self.ismastersim then
					self.attack_buffer = CONTROL_ATTACK
				else
					self:DoAttackButton()
				end
				return
			elseif control == CONTROL_MENU_MISC_4 then
				if TheInput:IsControlPressed(CHANGE_CONTROL_LEFT) then
					self:DoCharacterCommandWheelButton()
				end
				return
			elseif down and control == CONTROL_TARGET_LOCK then
				if self:IsControllerTargetLockEnabled() then
					if self:IsTargetCanBeLock(self.controller_target) and self.controller_target ~= self.controller_attack_target then
						self.controller_attack_target = self.controller_target
					elseif self:IsTargetCanBeLock(self.controller_alt_target) and self.controller_target ~= self.controller_attack_target then
						self.controller_attack_target = self.controller_alt_target
					else
						self:ControllerTargetLock(false)
					end
				else
					self:ControllerTargetLock(true)
				end
				return
			end
		end

		if not isenabled then
			return
		end

		if control == CONTROL_PRIMARY then
			self:OnLeftClick(down)
		elseif control == CONTROL_SECONDARY then
			self:OnRightClick(down)
			--V2C: see above for control up handling
			--elseif not down then
			--    if not self.ismastersim then
			--        self:RemoteStopControl(control)
			--    end
		elseif control == CONTROL_CANCEL then
			self:CancelPlacement()
		elseif control == CONTROL_AXISALIGNEDPLACEMENT_CYCLEGRID and self:IsAxisAlignedPlacement() then
			CycleAxisAlignmentValues()
		elseif control == CONTROL_INSPECT then
			if not TryTriggerMappingKey(self.inst, CHANGE_MAPPING_LB_Y, CHANGE_MAPPING_RB_Y, CHANGE_MAPPING_LB_RB_Y, false) and
				not TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_Y, CHANGE_MAPPING_RB_Y, CHANGE_MAPPING_LB_RB_Y, true, false) and
				not TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_Y, CHANGE_MAPPING_RB_Y, CHANGE_MAPPING_LB_RB_Y, false, false) then
				self:DoInspectButton()
			end
		elseif control == CONTROL_CONTROLLER_ALTACTION then
			self:DoControllerAltActionButton()
		elseif control == CONTROL_CONTROLLER_ACTION or (control == CONTROL_OPEN_INVENTORY and self:IsAOETargeting()) then
			self:DoControllerActionButton()
		elseif control == CONTROL_CONTROLLER_ATTACK then
			local equiped_item = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			local attack_target = self:GetControllerAttackTarget()
			local _, attack_target_alt_action = self:GetSceneItemControllerAction(attack_target)
			if equiped_item and equiped_item.controller_should_use_attack_target and attack_target and attack_target_alt_action
				and TheInput:IsControlPressed(CHANGE_CONTROL_OPTION) and not IsOtherModEnabled("Snapping tills") then
				self:DoControllerAltActionButton(attack_target)
			else
				if self.ismastersim then
					self.attack_buffer = CONTROL_CONTROLLER_ATTACK
				else
					self:DoControllerAttackButton()
				end
			end
		elseif self.inst.replica.inventory:IsVisible() then
			local inv_obj = self:GetCursorInventoryObject()
			local active_obj = self.inst.replica.inventory:GetActiveItem()
			local slot, container = self:GetCursorInventorySlotAndContainer() ---------------------------------------
			local target = self:GetControllerTarget()
			ChangePlayerController(self, control, inv_obj, active_obj, slot, container, target, TheInput:IsControlPressed(CHANGE_CONTROL_LEFT), TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT))
		end
	end

	self.OnControl = function(self, control, down, ...)
		if TheInput:ControllerAttached() then
			return OnControl_New(self, control, down, ...)
		else
			return OnControl_Old(self, control, down, ...)
		end
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

		if TheInput:SupportsControllerFreeCamera() then
			local xdir = TheInput:GetAnalogControlValue(VIRTUAL_CONTROL_CAMERA_ROTATE_RIGHT) - TheInput:GetAnalogControlValue(VIRTUAL_CONTROL_CAMERA_ROTATE_LEFT)
			local ydir = TheInput:GetAnalogControlValue(VIRTUAL_CONTROL_CAMERA_ZOOM_IN) - TheInput:GetAnalogControlValue(VIRTUAL_CONTROL_CAMERA_ZOOM_OUT)
			local absxdir = math.abs(xdir)
			local absydir = math.abs(ydir)
			local deadzone = TUNING.CONTROLLER_DEADZONE_RADIUS
			if absxdir >= deadzone and absxdir > absydir * 1.3 then --favour zoom a bit more at diagonals
				local right = xdir > 0
				if not CHANGE_IS_REVERSE_CAMERA_ROTATION_HUD then
					right = not right
				end
				local speed = Remap(math.min(1, absxdir), deadzone, 1, 2, 3)
				if right then
					self:RotRight(speed)
				else
					self:RotLeft(speed)
				end
				self.lastrottime = time
			elseif absydir > deadzone then
				local delta = Remap(math.min(1, absydir), deadzone, 1, 0, 0.65)
				TheCamera:ContinuousZoomDelta(ydir > 0 and -delta or delta)
				self.lastzoomtime = time
			end
			return
		end

		if self.lastrottime == nil or time - self.lastrottime > CHANGE_ROT_REPEAT then
			if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) and (self.reticule == nil or not TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT)) then
				if TheInput:IsControlPressed(CHANGE_IS_REVERSE_CAMERA_ROTATION_HUD and CONTROL_INVENTORY_LEFT or CONTROL_INVENTORY_RIGHT) then
					self:RotLeft()
					self.lastrottime = time
				elseif TheInput:IsControlPressed(CHANGE_IS_REVERSE_CAMERA_ROTATION_HUD and CONTROL_INVENTORY_RIGHT or CONTROL_INVENTORY_LEFT) then
					self:RotRight()
					self.lastrottime = time
				end
			end
		end

		if self.lastzoomtime == nil or time - self.lastzoomtime > CHANGE_ZOOM_REPEAT then
			if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) and (self.reticule == nil or not TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT)) then
				if TheInput:IsControlPressed(CHANGE_IS_REVERSE_CAMERA_ZOOM and CONTROL_INVENTORY_DOWN or CONTROL_INVENTORY_UP) then
					TheCamera:ZoomIn()
					self.lastzoomtime = time
				elseif TheInput:IsControlPressed(CHANGE_IS_REVERSE_CAMERA_ZOOM and CONTROL_INVENTORY_UP or CONTROL_INVENTORY_DOWN) then
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
			if not CHANGE_IS_USE_DPAD_SELECT_CRAFTING_MENU and self.inst.HUD:IsCraftingOpen() then
				return isenabled, ishudblocking
			end
			return true
		end
		return isenabled, ishudblocking
	end

	self.controller_alt_target = nil
    self.controller_alt_target_age = math.huge

	local TARGET_EXCLUDE_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "stealth"}
	local REGISTERED_CONTROLLER_ATTACK_TARGET_TAGS = TheSim:RegisterFindTags({ "_combat" }, TARGET_EXCLUDE_TAGS)

	local function UpdateControllerInteractionTarget(self, dt, x, y, z, dirx, dirz, heading_angle)
		if self.placer ~= nil or (self.deployplacer ~= nil and self.deploy_mode) or self.inst:HasTag("usingmagiciantool") then
			self.controller_target = nil
			self.controller_target_action = nil
			self.controller_target_age = 0
			return
		end

		if self.controller_target ~= nil
			and (not self.controller_target:IsValid() or
				self.controller_target:HasTag("INLIMBO") or
				self.controller_target:HasTag("NOCLICK") or
				not CanEntitySeeTarget(self.inst, self.controller_target)) then
			--"FX" and "DECOR" tag should never change, should be safe to skip that check
			self.controller_target = nil
			--it went invalid, but we're not resetting the age yet
		end

		self.controller_target_age = self.controller_target_age + dt
		if self.controller_target_age < .2 then
			--prevent target flickering
			return
		end

		local equiped_item = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

		--Fishing targets may have large radius, making it hard to target with normal priority
		local fishing = equiped_item ~= nil and equiped_item:HasTag("fishingrod")

		-- we want to never target our fishing hook, but others can
		local ocean_fishing_target = (equiped_item ~= nil and equiped_item.replica.oceanfishingrod ~= nil) and equiped_item.replica.oceanfishingrod:GetTarget() or nil

		local min_rad = 1.5
		local max_rad = CHANGE_INTERACTION_TARGET_DETECT_RADIUS  -- default: 6
		local min_rad_sq = min_rad * min_rad
		local max_rad_sq = max_rad * max_rad

		local target_rad =
				self.controller_target ~= nil and self.controller_target_action ~= nil and
				math.max(min_rad, math.min(max_rad, math.sqrt(self.inst:GetDistanceSqToInst(self.controller_target)))) or
				max_rad
		local target_rad_sq = target_rad * target_rad + .1 --allow small error

		local nearby_ents = TheSim:FindEntities(x, y, z, fishing and max_rad or target_rad, nil, TARGET_EXCLUDE_TAGS)
		if self.controller_target ~= nil then
			--Note: it may already contain controller_target,
			--      so make sure to handle it only once later
			table.insert(nearby_ents, 1, self.controller_target)
		end

		local target = nil
		local target_action = nil
		local target_score = 0
		local canexamine = (self.inst.CanExamine == nil or self.inst:CanExamine())
					and (not self.inst.HUD:IsPlayerAvatarPopUpOpen())
					and (self.inst.sg == nil or self.inst.sg:HasStateTag("moving") or self.inst.sg:HasStateTag("idle") or
						self.inst.sg:HasStateTag("attack") or self.inst.sg:HasStateTag("doing") or self.inst.sg:HasStateTag("working") or self.inst.sg:HasStateTag("channeling"))
					and (self.inst:HasTag("moving") or self.inst:HasTag("idle") or
						self.inst:HasTag("attack") or self.inst:HasTag("doing") or self.inst:HasTag("working") or self.inst:HasTag("channeling"))

		local onboat = self.inst:GetCurrentPlatform() ~= nil
		local anglemax = onboat and TUNING.CONTROLLER_BOATINTERACT_ANGLE or TUNING.CONTROLLER_INTERACT_ANGLE
		for i, v in ipairs(nearby_ents) do
			v = v.client_forward_target or v
			if v ~= ocean_fishing_target then

				--Only handle controller_target if it's the one we added at the front
				if v ~= self.inst and (v ~= self.controller_target or i == 1) and v.entity:IsVisible() then
					if v.entity:GetParent() == self.inst and v:HasTag("bundle") then
						--bundling or constructing
						target = v
						target_action = nil
						break
					end

					-- Calculate the dsq to filter out objects, ignoring the y component for now.
					local x1, y1, z1 = v.Transform:GetWorldPosition()
					local dx, dy, dz = x1 - x, y1 - y, z1 - z
					local dsq = dx * dx + dz * dz

					if fishing and v:HasTag("fishable") then
						local r = v:GetPhysicsRadius(0)
						if dsq <= r * r then
							dsq = 0
						end
					end

					if (dsq < min_rad_sq
						or (dsq <= target_rad_sq
							and (v == self.controller_target or
								v == self.controller_attack_target or
								CHANGE_IS_INTERACT_ALL_DIRECTION or
								dx * dirx + dz * dirz > 0))) and
						CanEntitySeePoint(self.inst, x1, y1, z1) then
						local shouldcheck = dsq < 1 -- Do not skip really close entities.
						if not shouldcheck then
							local epos = v:GetPosition()
							local angletoepos = self.inst:GetAngleToPoint(epos)
							local angleto = math.abs(anglediff(-heading_angle, angletoepos))
							shouldcheck = angleto < anglemax or CHANGE_IS_INTERACT_ALL_DIRECTION
						end
						if shouldcheck then
							-- Get Action Status
							local lmb, _ = self:GetSceneItemControllerAction(v)
							local inv_obj = self:GetCursorInventoryObject()
							local inv_act = inv_obj ~= nil and inv_obj.replica.inventoryitem and self:GetItemUseAction(inv_obj, v) or nil

							-- Incorporate the y component after we've performed the inclusion radius test.
							-- We wait until now because we might disqualify our controller_target if its transform has a y component,
							-- but we still want to use the y component as a tiebreaker for objects at the same x,z position.
							dsq = dsq + (dy * dy)

							local dist = dsq > 0 and math.sqrt(dsq) or 0
							local dot = dist > 0 and dx / dist * dirx + dz / dist * dirz or 0


							--keep the angle component between [0..1]
							local angle_component = CHANGE_IS_INTERACT_ALL_DIRECTION and 1 or (dot + 1) / 2

							--distance doesn't matter when you're really close, and then attenuates down from 1 as you get farther away
							local dist_component = dsq < min_rad_sq and 1 or min_rad_sq / dsq

							--for stuff that's *really* close - ie, just dropped
							local add = dsq < .0625 --[[.25 * .25]] and 1 or 0

							--just a little hysteresis
							local mult = v == self.controller_target and self.controller_target_action ~= nil and
								not v:HasTag("wall") and 1.5 or 1

							--select the item that can do action on it.
							if (lmb ~= nil or (inv_obj and inv_obj.replica.inventoryitem and inv_obj.replica.inventoryitem:IsGrandOwner(self.inst) and inv_act ~= nil) or self:IsTargetCanBeLock(v)) and
								not TheInput:IsControlPressed(CHANGE_CONTROL_OPTION) then
								mult = mult * 10
							end

							local score = angle_component * dist_component * mult + add

							--make it easier to target stuff dropped inside the portal when alive
							--make it easier to haunt the portal for resurrection in endless mode
							if v:HasTag("portal") then
								score = score * (self.inst:HasTag("playerghost") and GetPortalRez() and 1.1 or .9)
							end

							if v:HasTag("hasfurnituredecoritem") then
								score = score * 0.5
							end
							
							local skip_target = false
							if not skip_target and (v.prefab == "trap_teeth" or v.prefab == "trap_teeth_maxwell" or v.prefab == "trap_bramble") and
								(v:HasTag("minesprung") or v:HasTag("mineactive")) then
								skip_target = not TheInput:IsControlPressed(CHANGE_CONTROL_OPTION)
							end

							if not skip_target and (v:HasTag("walkingplank") or v:HasTag("boatbumper") or v:HasTag("boat")) then
								skip_target = not TheInput:IsControlPressed(CHANGE_CONTROL_OPTION)
								if inv_obj ~= nil and inv_obj.replica.inventoryitem and inv_obj.replica.inventoryitem:IsGrandOwner(self.inst) and inv_act ~= nil and
									self.inst.replica.inventory:GetActiveItem() == nil then
									skip_target = false
								end
								if lmb ~= nil and lmb.action == ACTIONS.DROP and
									self.inst.replica.inventory:GetActiveItem() ~= nil then
									skip_target = true
								end
							end

							if not skip_target and CHANGE_WOBY_ACTION_MUST_PRESS_RB and
								(v.prefab == "wobysmall" or v.prefab =="wobybig") and
								v.replica.follower and v.replica.follower:GetLeader() == self.inst then
								skip_target = not TheInput:IsControlPressed(CHANGE_CONTROL_OPTION)
								if lmb ~= nil and self.inst.replica.inventory:GetActiveItem() ~= nil then
									skip_target = false
								end
								if self.inst.HUD:IsSpellWheelOpen() or v.replica.container:IsOpenedBy(self.inst) then
									skip_target = false
								end
							end

							if not skip_target and ((v:HasTag("critter") and v.prefab ~= "wobysmall") or v:HasTag("kitcoon") or v:HasTag("ticoon")) and
								v.replica.follower and v.replica.follower:GetLeader() == self.inst then
								skip_target = not TheInput:IsControlPressed(CHANGE_CONTROL_OPTION)
								if lmb ~= nil and self.inst.replica.inventory:GetActiveItem() ~= nil then
									skip_target = false
								end
							end

							-- print(v, angle_component, dist_component, mult, add, score)

							if (CHANGE_IS_USE_DPAD_SELECT_SPELLWHEEL_ITEM or not self.inst.HUD:IsSpellWheelOpen()) and not skip_target then
								if score < target_score or
									(   score == target_score and
										(   (target ~= nil and not (target.CanMouseThrough ~= nil and target:CanMouseThrough())) or
											(v.CanMouseThrough ~= nil and v:CanMouseThrough())
										)
									) then
									--skip
								elseif lmb ~= nil then
									target = v
									target_score = score
									target_action = lmb
								else
									if inv_act ~= nil and inv_act.target == v then
										target = v
										target_score = score
										target_action = inv_act
									elseif canexamine and v:HasTag("inspectable") then
										target = v
										target_score = score
										target_action = nil
									end
								end
							end
						end
					end
				end
			end
		end

		if target ~= self.controller_target or
		(target_action == nil and self.controller_target_action ~= nil) or
		(target_action ~= nil and self.controller_target_action == nil) or
		(target_action ~= nil and self.controller_target_action ~= nil and self.controller_target_action:__tostring() ~= target_action:__tostring()) then
			self.controller_target = target
			self.controller_target_action = target_action
			self.controller_target_age = 0
			-- print("****** change target to: ", target)
		end
	end

	local function UpdateControllerInteractionAltTarget(self, dt, x, y, z, dirx, dirz, heading_angle)
		if self.placer ~= nil or (self.deployplacer ~= nil and self.deploy_mode) or self.inst:HasTag("usingmagiciantool") then
			self.controller_alt_target = nil
			self.controller_alt_target_age = 0
			return
		end

		if self.controller_alt_target ~= nil
			and (not self.controller_alt_target:IsValid() or
				self.controller_alt_target:HasTag("INLIMBO") or
				self.controller_alt_target:HasTag("NOCLICK") or
				not CanEntitySeeTarget(self.inst, self.controller_alt_target)) then
			--"FX" and "DECOR" tag should never change, should be safe to skip that check
			self.controller_alt_target = nil
			--it went invalid, but we're not resetting the age yet
		end

		self.controller_alt_target_age = self.controller_alt_target_age + dt
		if self.controller_alt_target_age < .2 then
			--prevent target flickering
			return
		end

		local equiped_item = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

		--Fishing targets may have large radius, making it hard to target with normal priority
		local fishing = equiped_item ~= nil and equiped_item:HasTag("fishingrod")

		-- we want to never target our fishing hook, but others can
		local ocean_fishing_target = (equiped_item ~= nil and equiped_item.replica.oceanfishingrod ~= nil) and equiped_item.replica.oceanfishingrod:GetTarget() or nil

		local min_rad = 1.5
		local max_rad = CHANGE_INTERACTION_TARGET_DETECT_RADIUS  -- default: 6
		local min_rad_sq = min_rad * min_rad
		local max_rad_sq = max_rad * max_rad

		local alt_target_rad =
				self.controller_alt_target ~= nil and
				math.max(min_rad, math.min(max_rad, math.sqrt(self.inst:GetDistanceSqToInst(self.controller_alt_target)))) or
				max_rad
		local alt_target_rad_sq = alt_target_rad * alt_target_rad + .1 --allow small error

		local nearby_ents = TheSim:FindEntities(x, y, z, fishing and max_rad or alt_target_rad, nil, TARGET_EXCLUDE_TAGS)

		if self.controller_alt_target ~= nil then
			--Note: it may already contain controller_target,
			--      so make sure to handle it only once later
			table.insert(nearby_ents, 1, self.controller_alt_target)
		end

		local alt_target = nil
		local alt_target_score = 0
		local onboat = self.inst:GetCurrentPlatform() ~= nil
		local anglemax = onboat and TUNING.CONTROLLER_BOATINTERACT_ANGLE or TUNING.CONTROLLER_INTERACT_ANGLE
		for i, v in ipairs(nearby_ents) do
			v = v.client_forward_target or v
			if v ~= ocean_fishing_target then

				--Only handle controller_target if it's the one we added at the front
				if v ~= self.inst and (v ~= self.controller_alt_target or i == 1) and v.entity:IsVisible() then
					if v.entity:GetParent() == self.inst and v:HasTag("bundle") then
						--bundling or constructing
						alt_target = v
						break
					end

					-- Calculate the dsq to filter out objects, ignoring the y component for now.
					local x1, y1, z1 = v.Transform:GetWorldPosition()
					local dx, dy, dz = x1 - x, y1 - y, z1 - z
					local dsq = dx * dx + dz * dz

					if fishing and v:HasTag("fishable") then
						local r = v:GetPhysicsRadius(0)
						if dsq <= r * r then
							dsq = 0
						end
					end

					if (dsq < min_rad_sq
						or (dsq <= alt_target_rad_sq
							and (v == self.controller_alt_target or
								v == self.controller_attack_target or
								CHANGE_IS_INTERACT_ALL_DIRECTION or
								dx * dirx + dz * dirz > 0))) and
						CanEntitySeePoint(self.inst, x1, y1, z1) then
						local shouldcheck = dsq < 1 -- Do not skip really close entities.
						if not shouldcheck then
							local epos = v:GetPosition()
							local angletoepos = self.inst:GetAngleToPoint(epos)
							local angleto = math.abs(anglediff(-heading_angle, angletoepos))
							shouldcheck = angleto < anglemax or CHANGE_IS_INTERACT_ALL_DIRECTION
						end
						if shouldcheck then
							-- Get Action Status
							local _, rmb = self:GetSceneItemControllerAction(v)

							-- Incorporate the y component after we've performed the inclusion radius test.
							-- We wait until now because we might disqualify our controller_target if its transform has a y component,
							-- but we still want to use the y component as a tiebreaker for objects at the same x,z position.
							dsq = dsq + (dy * dy)

							local dist = dsq > 0 and math.sqrt(dsq) or 0
							local dot = dist > 0 and dx / dist * dirx + dz / dist * dirz or 0

							--keep the angle component between [0..1]
							local angle_component = CHANGE_IS_INTERACT_ALL_DIRECTION and 1 or (dot + 1) / 2

							--distance doesn't matter when you're really close, and then attenuates down from 1 as you get farther away
							local dist_component = dsq < min_rad_sq and 1 or min_rad_sq / dsq

							--for stuff that's *really* close - ie, just dropped
							local add = dsq < .0625 --[[.25 * .25]] and 1 or 0

							--just a little hysteresis
							local alt_mult = v == self.controller_alt_target and not v:HasTag("wall") and 1.5 or 1

							--select the item that can do action on it.
							if (rmb ~= nil or self:IsTargetCanBeLock(v)) and not TheInput:IsControlPressed(CHANGE_CONTROL_OPTION) then
								alt_mult = alt_mult * 10
							end

							local score = angle_component * dist_component * alt_mult + add

							--make it easier to target stuff dropped inside the portal when alive
							--make it easier to haunt the portal for resurrection in endless mode
							if v:HasTag("portal") then
								score = score * (self.inst:HasTag("playerghost") and GetPortalRez() and 1.1 or .9)
							end

							if v:HasTag("hasfurnituredecoritem") then
								score = score * 0.5
							end

							local skip_target = false
							if not skip_target and (v:HasTag("walkingplank") or v:HasTag("boatbumper") or v:HasTag("boat")) then
								skip_target = not TheInput:IsControlPressed(CHANGE_CONTROL_OPTION)
								if rmb ~= nil then
									if rmb.action == ACTIONS.BLINK or rmb.action == ACTIONS.CASTSPELL then
										skip_target = true
									elseif rmb.action == ACTIONS.REPAIR then
										skip_target = false
									end
								end
							end

							if not skip_target and CHANGE_WOBY_ACTION_MUST_PRESS_RB and
								(v.prefab == "wobysmall" or v.prefab =="wobybig") and
								v.replica.follower and v.replica.follower:GetLeader() == self.inst then
								skip_target = not TheInput:IsControlPressed(CHANGE_CONTROL_OPTION)
								if self.inst.HUD:IsSpellWheelOpen() or v.replica.container:IsOpenedBy(self.inst) then
									skip_target = false
								end
							end

							if not skip_target and ((v:HasTag("critter") and v.prefab ~= "wobysmall") or v:HasTag("kitcoon") or v:HasTag("ticoon")) and
								v.replica.follower and v.replica.follower:GetLeader() == self.inst then
								skip_target = not TheInput:IsControlPressed(CHANGE_CONTROL_OPTION)
								if rmb ~= nil and self.inst.replica.inventory:GetActiveItem() ~= nil then
									skip_target = false
								end
							end

							if not skip_target and CHANGE_MOUNT_AND_DISMOUNT_MUST_PRESS_RB and v:HasTag("saddled") and
								rmb ~= nil and rmb.action == ACTIONS.MOUNT then
								skip_target = not TheInput:IsControlPressed(CHANGE_CONTROL_OPTION)
							end

							-- print(v, angle_component, dist_component, alt_mult, add, score)

							if rmb ~= nil and (CHANGE_IS_USE_DPAD_SELECT_SPELLWHEEL_ITEM or not self.inst.HUD:IsSpellWheelOpen()) and not skip_target then
								if score < alt_target_score or
									(   score == alt_target_score and
										(   (alt_target ~= nil and not (alt_target.CanMouseThrough ~= nil and alt_target:CanMouseThrough())) or
											(v.CanMouseThrough ~= nil and v:CanMouseThrough())
										)
									) then
									--skip
								else
									alt_target = v
									alt_target_score = score
								end
							end
						end
					end
				end
			end
		end

		if alt_target ~= self.controller_alt_target then
			self.controller_alt_target = alt_target
			self.controller_alt_target_age = 0
			-- print("****** change alt_target to: ", alt_target)
		end
	end

	-- Not changed
	local function CheckControllerPriorityTagOrOverride(target, tag, override)
		if override ~= nil then
			return FunctionOrValue(override)
		end
		return target:HasTag(tag)
	end

	-- New Added and Not Change
	local function TargetIsHostile(inst, target)
		if inst.HostileTest ~= nil then
			return inst:HostileTest(target)
		elseif target.HostileToPlayerTest ~= nil then
			return target:HostileToPlayerTest(inst)
		else
			return target:HasTag("hostile")
		end
	end

	-- New Added
	self.IsNeedForceAttack = function (self, target)
		return not TargetIsHostile(self.inst, target) and
			target ~= self.inst.replica.combat:GetTarget() and
			self.inst ~= target.replica.combat:GetTarget()
	end
	-- changed a little
	local function UpdateControllerAttackTarget(self, dt, x, y, z, dirx, dirz)
		local inventory = self.inst.replica.inventory
		if inventory:IsHeavyLifting() or inventory:IsFloaterHeld() or self.inst:HasTag("playerghost") then
			self.controller_attack_target = nil

			-- we can't target right now; disable target locking
			self.controller_targeting_lock_target = false
			return
		end

		local combat = self.inst.replica.combat


		if self.controller_attack_target ~= nil and
			not (combat:CanTarget(self.controller_attack_target) and
				CanEntitySeeTarget(self.inst, self.controller_attack_target)) then
			self.controller_attack_target = nil

			-- target is no longer valid; disable target locking
			self.controller_targeting_lock_target = false
			--it went invalid, but we're not resetting the age yet
		end

		local equipped_item = inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		local forced_rad = equipped_item ~= nil and equipped_item.controller_use_attack_distance or CHANGE_ADD_ATTACKABLE_TARGET_DETECT_RADIUS

		local min_rad = 3
		local max_rad = math.max(forced_rad, combat:GetAttackRangeWithWeapon()) + 3.5
		local max_rad_sq = max_rad * max_rad

		--see entity_replica.lua for "_combat" tag

		local nearby_ents = TheSim:FindEntities_Registered(x, y, z, max_rad + 3, REGISTERED_CONTROLLER_ATTACK_TARGET_TAGS)
		if self.controller_attack_target ~= nil then
			--Note: it may already contain controller_attack_target,
			--      so make sure to handle it only once later
			table.insert(nearby_ents, 1, self.controller_attack_target)
		end

		local target = nil
		local target_score = 0
		local preferred_target =
			TheInput:IsControlPressed(CONTROL_CONTROLLER_ATTACK) and
			self.controller_attack_target or
			combat:GetTarget() or
			nil

		local current_controller_targeting_targets = {}
		local selected_target_index = 0
		for i, v in ipairs(nearby_ents) do
			if v ~= self.inst and (v ~= self.controller_attack_target or i == 1) then
				if combat:CanTarget(v) then
					local isally = combat:IsAlly(v)
					local need_force_attack = self:IsNeedForceAttack(v)
					if not CHANGE_FORCE_BUTTON or not CHANGE_IS_FORCE_ATTACK or not need_force_attack or TheInput:IsControlPressed(CHANGE_FORCE_BUTTON) or self.controller_targeting_lock_target then

						--Check distance including y value
						local x1, y1, z1 = v.Transform:GetWorldPosition()
						local dx, dy, dz = x1 - x, y1 - y, z1 - z
						local dsq = dx * dx + dy * dy + dz * dz

						--include physics radius for max range check since we don't have (dist - phys_rad) yet
						local phys_rad = v:GetPhysicsRadius(0)
						local max_range = max_rad + phys_rad

						if dsq < max_range * max_range and CanEntitySeePoint(self.inst, x1, y1, z1) then
							local dist = dsq > 0 and math.sqrt(dsq) or 0
							local dot = dist > 0 and dx / dist * dirx + dz / dist * dirz or 0
							if (CHANGE_IS_ATTACK_ALL_DIRECTION or dot > 0) or dist < min_rad + phys_rad then
								--now calculate score with physics radius subtracted
								dist = math.max(0, dist - phys_rad)
								if CHANGE_IS_ATTACK_ALL_DIRECTION and dot < 0 then
									dot = (-0.7) * dot
								end
								local score = dot + 1 - 0.5 * dist * dist / max_rad_sq

								if CHANGE_IS_ATTACK_ALL_DIRECTION or TheInput:IsControlPressed(CHANGE_CONTROL_OPTION) then
									-- do nothing
								elseif CheckControllerPriorityTagOrOverride(v, "epic", v.controller_priority_override_is_epic) then
									score = score * 5
								elseif CheckControllerPriorityTagOrOverride(v, "monster", v.controller_priority_override_is_monster) then
									score = score * 4
								end

								if CHANGE_IS_ATTACK_ALL_DIRECTION or TheInput:IsControlPressed(CHANGE_CONTROL_OPTION) then
									-- do nothing
								elseif v.replica.combat:GetTarget() == self.inst or FunctionOrValue(v.controller_priority_override_is_targeting_player) then
									score = score * 6
								end

								if v == preferred_target then
									score = score * 10
								end

								local skip_target = false
								if CHANGE_FORCE_BUTTON and CHANGE_IS_FORCE_ATTACK and isally and not self.Double_Click_Left_Bumper_And_Holding then
									skip_target = true
								end

								if not skip_target then
									table.insert(current_controller_targeting_targets, v)
									if score > target_score then
										selected_target_index = #current_controller_targeting_targets
										target = v
										target_score = score
									end
								end
							end
						end
					end
				end
			end
		end

		if self.controller_attack_target ~= nil and self.controller_targeting_lock_target then
			-- we have a target and target locking is enabled so only update the list of valid targets, ie. check for targets that have appeared or disappeared

			-- first check if any targets should be removed
			for idx_outer = #self.controller_targeting_targets, 1, -1 do
				local found = false
				local existing_target = self.controller_targeting_targets[idx_outer]
				for idx_inner = #current_controller_targeting_targets, 1, -1 do
					if existing_target == current_controller_targeting_targets[idx_inner] then
						-- we found the existing target in the list of current nearby entities so remove it from the current entity list to
						-- make later addition of new entities more straightforward
						table.remove(current_controller_targeting_targets, idx_inner)
						found = true
						break
					end
				end

				-- if the existing target isn't found in the nearby entities then remove it from the targets
				if not found then
					table.remove(self.controller_targeting_targets, idx_outer)
				end
			end

			-- now add new targets; check everything left in the nearby_ents table as we've been
			-- removing existing targets from it as we checked for targets that were no longer valid
			for i, v in ipairs(current_controller_targeting_targets) do
				table.insert(self.controller_targeting_targets, v)
			end

			-- fin
			return
		end

		if self.controller_target ~= nil and self.controller_target:IsValid() then
			if target ~= nil then
				if target:HasTag("wall") and
					self.classified ~= nil and
					self.classified.hasgift:value() and
					self.classified.hasgiftmachine:value() and
					self.controller_target:HasTag("giftmachine") then
					--if giftmachine has (Y) control priority, then it
					--should also have (X) control priority over walls
					target = nil
				end
			end
		end

		if target ~= self.controller_attack_target then
			self.controller_attack_target = target
			self.controller_targeting_target_index = selected_target_index
		end

	end

	-- Numerous Changed, 
	-- 1. apply local function UpdateControllerInteractionTarget
	-- 2. Update attack target while AOETargeting
	self.UpdateControllerTargets = function (self, dt, ...)
		local x, y, z = self.inst.Transform:GetWorldPosition()
		local heading_angle = -self.inst.Transform:GetRotation()
		local dirx = math.cos(heading_angle * DEGREES)
		local dirz = math.sin(heading_angle * DEGREES)

		if self:IsAOETargeting() or
			self.inst:HasTag("sitting_on_chair") or
			(self.inst:HasTag("weregoose") and not self.inst:HasTag("playerghost")) or
			(self.classified and self.classified.inmightygym:value() > 0) then
			self.controller_target = nil
			self.controller_target_age = 0
			self.controller_alt_target = nil
			self.controller_alt_target_age = 0
			if self:IsAOETargeting() then
				UpdateControllerAttackTarget(self, dt, x, y, z, dirx, dirz)
			else
				self.controller_attack_target = nil
				self.controller_targeting_lock_target = nil
			end
		else
			UpdateControllerInteractionTarget(self, dt, x, y, z, dirx, dirz, heading_angle)
			UpdateControllerInteractionAltTarget(self, dt, x, y, z, dirx, dirz, heading_angle)
			UpdateControllerAttackTarget(self, dt, x, y, z, dirx, dirz)
		end
		self.Change_drop_position = Vector3(x + dirx, y, z + dirz)
	end

	local DoControllerActionButton_Old = self.DoControllerActionButton
	self.DoControllerActionButton = function (self, ...)
		local active_obj = self.inst.replica.inventory:GetActiveItem()
		if (self.controller_target_action == nil or (CHANGE_FORCE_BUTTON and TheInput:IsControlPressed(CHANGE_FORCE_BUTTON))) and active_obj ~= nil and
			self.placer == nil and self.placer_recipe == nil and self.deployplacer == nil and self:IsEnabled() and not self:IsAOETargeting() and
			(CHANGE_IS_USE_DPAD_SELECT_SPELLWHEEL_ITEM or not self.inst.HUD:IsSpellWheelOpen()) and
			not TheWorld.Map:IsPassableAtPoint(self.Change_drop_position:Get()) and TheWorld.Map:IsOceanTileAtPoint(self.Change_drop_position:Get()) then
			self:DoControllerOneStepForwardAndDropActiveItem(active_obj, TheInput:IsControlPressed(CHANGE_CONTROL_LEFT))
		else
			DoControllerActionButton_Old(self, ...)
		end
	end

	local GetGroundUseAction_Old = self.GetGroundUseAction
	self.GetGroundUseAction = function (self, ...)
		local lmb, rmb = GetGroundUseAction_Old(self, ...)
		if self.inst.replica.inventory:GetActiveItem() then
			rmb = nil
		end
		return lmb, rmb
	end


	-- Newly created function
	self.GetControllerAltTarget = function (self, ...)
		return self.controller_alt_target ~= nil and self.controller_alt_target:IsValid() and self.controller_alt_target or nil
	end

	local DoControllerAltActionButton_New = function (self, target, ...)
		self:ClearActionHold()

		if self.placer_recipe ~= nil then
			self:CancelPlacement()
			return
		elseif self.deployplacer ~= nil then
			self:CancelDeployPlacement()
			return
		elseif self:IsAOETargeting() then
			self:CancelAOETargeting()
			return
		end

		self.actionholdtime = GetTime()

		local lmb, act, obj, isspecial
		local not_force = CHANGE_FORCE_BUTTON and CHANGE_IS_FORCE_PING_RETICULE and not TheInput:IsControlPressed(CHANGE_FORCE_BUTTON)
		local is_reticule = self.reticule ~= nil and self.reticule.reticule ~= nil and self.reticule.reticule.entity:IsVisible()
		if target ~= nil then
			obj = target
			lmb, act = self:GetSceneItemControllerAction(obj)
		else
			lmb, act = self:GetGroundUseAction()
			obj = act ~= nil and act.target or nil
			-- print("act: ", act, "obj: ", obj)

			-- [[place ground action]] -> act ~= nil 
				-- [[using oil to row]] -> act ~= nil and obj == nil
				-- [[stop using magician tool]] -> act ~= nil and obj ~= nil

			if act == nil or (is_reticule and not_force) then
				local rider = self.inst.replica.rider
				local mount = rider and rider:GetMount() or nil
				local container = mount and mount.replica.container or nil
				if container and container:IsOpenedBy(self.inst) then
					-- [[close woby's bag container]]
					obj = self.inst
					act = BufferedAction(obj, obj, ACTIONS.RUMMAGE)
				elseif self.inst.components.spellbook and self.inst.components.spellbook:CanBeUsedBy(self.inst) and
					TheInput:IsControlPressed(CHANGE_CONTROL_OPTION) then
					-- [[use spellbook]]
					obj = self.inst
					act = BufferedAction(obj, obj, ACTIONS.USESPELLBOOK)
				elseif mount and TheInput:IsControlPressed(CHANGE_CONTROL_OPTION) then
					-- [[dismount]]
					obj = self.inst
					act = BufferedAction(obj, obj, ACTIONS.DISMOUNT)
				else
					local alt_obj = self:GetControllerAltTarget()
					local special_act = self:GetGroundUseSpecialAction(nil, true)
					if alt_obj ~= nil and special_act ~= nil then
						if (not CHANGE_IS_FORCE_PING_RETICULE or not_force) then
							-- [[normal alt action]]
							obj = alt_obj
							lmb, act = self:GetSceneItemControllerAction(obj)
							if act ~= nil and act.action == ACTIONS.APPLYCONSTRUCTION then
								local container = act.target ~= nil and act.target.replica.container
								if container ~= nil and
									container.widget ~= nil and
									container.widget.overrideactionfn ~= nil and
									container.widget.overrideactionfn(act.target, self.inst)
									then
									--e.g. rift offering has a local confirmation popup
									return
								end
							end
						else
							-- [[special action]]
							act = special_act
							obj = nil
							isspecial = true
						end
					elseif alt_obj ~= nil then
						-- [[normal alt action]]
						obj = alt_obj
						lmb, act = self:GetSceneItemControllerAction(obj)
						if act ~= nil and act.action == ACTIONS.APPLYCONSTRUCTION then
							local container = act.target ~= nil and act.target.replica.container
							if container ~= nil and
								container.widget ~= nil and
								container.widget.overrideactionfn ~= nil and
								container.widget.overrideactionfn(act.target, self.inst)
								then
								--e.g. rift offering has a local confirmation popup
								return
							end
						end
					elseif special_act ~= nil and not not_force then
						-- [[special action]]
						act = special_act
						obj = nil
						isspecial = true
					else
						-- [[AOETargeting or AOECharging]]
						if self:TryAOETargeting() or
							(self.TryAOECharging and self:TryAOECharging(nil, true)) then
							-- do nothing
						end
						return
					end
				end
			end
		end
		
		-- I don't know why others break down, 
		-- I can only do some protect here
		if act == nil then
			return
		end

		if is_reticule and not not_force then
			self.reticule:PingReticuleAt(act:GetDynamicActionPoint())
		end

		local maptarget = self:GetMapTarget(act)
		if maptarget ~= nil then
			self:PullUpMap(maptarget)
			return
		end

		if self.ismastersim then
			self.inst.components.combat:SetTarget(nil)
		elseif obj ~= nil then
			if self.locomotor == nil then
				act.non_preview_cb = function()
					self.remote_controls[CONTROL_CONTROLLER_ALTACTION] = 0
					SendRPCToServer(RPC.ControllerAltActionButton, act.action.code, obj, nil, act.action.canforce, act.action.mod_name)
				end
			elseif self:CanLocomote() then
				act.preview_cb = function()
					self.remote_controls[CONTROL_CONTROLLER_ALTACTION] = 0
					local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ALTACTION)
					SendRPCToServer(RPC.ControllerAltActionButton, act.action.code, obj, isreleased, nil, act.action.mod_name)
				end
			end
		elseif self.locomotor == nil then
			act.non_preview_cb = function()
				self.remote_controls[CONTROL_CONTROLLER_ALTACTION] = 0
				SendRPCToServer(RPC.ControllerAltActionButtonPoint, act.action.code, act.pos.local_pt.x, act.pos.local_pt.z, nil, act.action.canforce, isspecial, act.action.mod_name, act.pos.walkable_platform, act.pos.walkable_platform ~= nil)
			end
		elseif self:CanLocomote() then
			act.preview_cb = function()
				self.remote_controls[CONTROL_CONTROLLER_ALTACTION] = 0
				local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ALTACTION)
				SendRPCToServer(RPC.ControllerAltActionButtonPoint, act.action.code, act.pos.local_pt.x, act.pos.local_pt.z, isreleased, nil, isspecial, act.action.mod_name, act.pos.walkable_platform, act.pos.walkable_platform ~= nil)
			end
		end

		self:DoAction(act)
	end

	self.TryWidgetButtonFunction = function (self, call, ...)
		local _, _, _, _, _, cooker_type_container = self:GetAllTypeContainers()
		if cooker_type_container ~= nil then
			local isreadonlycontainer = cooker_type_container.replica.container ~= nil and
										cooker_type_container.replica.container.IsReadOnlyContainer and
										cooker_type_container.replica.container:IsReadOnlyContainer()
			local widget = cooker_type_container.replica.container ~= nil and cooker_type_container.replica.container:GetWidget() or nil
			if not isreadonlycontainer and widget ~= nil and widget.buttoninfo ~= nil and widget.buttoninfo.fn ~= nil then
				if self.inst:HasTag("busy") then
					return
				end
				local iscontrolsenabled, ishudblocking = self:IsEnabled()
				if not (iscontrolsenabled or ishudblocking) then
					return
				end
				if call then
					widget.buttoninfo.fn(cooker_type_container, self.inst)
				end
				return cooker_type_container
			end
		end
	end

	local DoControllerAltActionButton_New_Old = DoControllerAltActionButton_New
	self.DoControllerAltActionButton = function (self, ...)
		if CHANGE_FORCE_BUTTON and TheInput:IsControlPressed(CHANGE_FORCE_BUTTON) and self:TryWidgetButtonFunction(true) then
			return
		end
		DoControllerAltActionButton_New_Old(self, ...)
	end

	local DoControllerAttackButton_Old = self.DoControllerAttackButton
	self.DoControllerAttackButton = function (self, target, ...)
		local IsAOETargeting_Old = self.IsAOETargeting
		self.IsAOETargeting = function(self, ...) return false end
		local IsSittingOnChair = self.inst:HasTag("sitting_on_chair")
		if IsSittingOnChair then
			self.inst:RemoveTag("sitting_on_chair")
		end
		DoControllerAttackButton_Old(self, target, ...)
		if IsSittingOnChair then
			self.inst:AddTag("sitting_on_chair")
		end
		self.IsAOETargeting = IsAOETargeting_Old
	end

	local CancelPlacement_Old = self.CancelPlacement
	self.CancelPlacement = function (self, cache, ...)
		CancelPlacement_Old(self, cache, ...)
		if TheInput:ControllerAttached() then
			if self.fake_placer ~= nil then
				if self.reticule ~= nil and self.reticule == self.fake_placer.components.reticule then
					self.reticule:DestroyReticule()
					self.reticule = nil
				end
				self.fake_placer:Remove()
				self.fake_placer = nil
				self:RefreshReticule()
			end
		end
	end

	local CancelDeployPlacement_Old = self.CancelDeployPlacement
	self.CancelDeployPlacement = function (self, ...)
		CancelDeployPlacement_Old(self, ...)
		if TheInput:ControllerAttached() then
			if self.fake_deployplacer ~= nil then
				if self.reticule ~= nil and self.reticule == self.fake_deployplacer.components.reticule then
					self.reticule:DestroyReticule()
					self.reticule = nil
				end
				self.fake_deployplacer:Remove()
				self.fake_deployplacer = nil
				self:RefreshReticule()
			end
		end
	end

	local function ReticuleTargetFn(inst)
		return Vector3(ThePlayer.entity:LocalToWorldSpace(inst.components.placer.offset_old, 0, 0))
	end

	local StartBuildPlacementMode_Old = self.StartBuildPlacementMode
	self.StartBuildPlacementMode = function (self, recipe, skin, ...)
		StartBuildPlacementMode_Old(self, recipe, skin, ...)
		if TheInput:ControllerAttached() then
			if self.fake_placer ~= nil then
				self.fake_placer:Remove()
			end
			self.fake_placer =
				skin ~= nil and
				SpawnPrefab(recipe.placer, skin, nil, self.inst.userid) or
				SpawnPrefab(recipe.placer)
			self.fake_placer.components.placer.offset_old = self.fake_placer.components.placer.offset
			self.fake_placer.components.placer.offset = 0
			self.fake_placer.components.placer.fake = true
			self.fake_placer.components.placer:SetBuilder(self.inst, recipe)
			self.fake_placer:Hide()
			
			self.fake_placer:AddComponent("reticule")
			self.fake_placer.components.reticule.targetfn = ReticuleTargetFn
			self.fake_placer.components.reticule.ease = true

			local newreticule = self.fake_placer.components.reticule
			if newreticule ~= self.reticule then
				if self.reticule ~= nil then
					self.reticule:DestroyReticule()
				end
				self.reticule = newreticule
				if newreticule ~= nil and newreticule.reticule == nil and (newreticule.mouseenabled or TheInput:ControllerAttached()) then
					newreticule:CreateReticule()
					if newreticule.reticule ~= nil and (not self:IsEnabled() or newreticule:ShouldHide()) then
						newreticule.reticule:Hide()
					end
				end
			end
		end
		LoadGeometricPlacementCtrlOption()
	end

	-- Only for query correct "placer_item" value in OnUpdate Function 
	local GetCursorInventoryObject_Old = self.GetCursorInventoryObject
	self.GetCursorInventoryObject = function(self, ...)
		local result = GetCursorInventoryObject_Old(self, ...)
		if self.deploy_mode then
			result = self.inst.replica.inventory:GetActiveItem() or result
		end
		return result
	end

	local OnUpdate_Old = self.OnUpdate
	self.OnUpdate = function (self, dt, ...)
		if TheInput:ControllerAttached() then
			local isenabled, _ = self:IsEnabled()
			if isenabled then
				if self.handler ~= nil then
					local controller_mode = TheInput:ControllerAttached()
					local placer_item = controller_mode and self:GetCursorInventoryObject() or self.inst.replica.inventory:GetActiveItem()
					if self.deploy_mode and
						self.placer == nil and
						placer_item ~= nil and
						placer_item.replica.inventoryitem ~= nil and
						placer_item.replica.inventoryitem:IsDeployable(self.inst) then

						local placer_name = placer_item.replica.inventoryitem:GetDeployPlacerName()
						local placer_skin = placer_item.AnimState:GetSkinBuild() --hack that relies on the build name to match the linked skinname
						if placer_skin == "" then
							placer_skin = nil
						end

						if self.fake_deployplacer == nil then
							self.fake_deployplacer = SpawnPrefab(placer_name, placer_skin, nil, self.inst.userid )
							if self.fake_deployplacer ~= nil then
								self.fake_deployplacer.components.placer.offset_old = self.fake_deployplacer.components.placer.offset
								self.fake_deployplacer.components.placer.offset = 0
								self.fake_deployplacer.components.placer.fake = true
								self.fake_deployplacer.components.placer:SetBuilder(self.inst, nil, placer_item)
								self.fake_deployplacer:Hide()

								self.fake_deployplacer:AddComponent("reticule")
								self.fake_deployplacer.components.reticule.targetfn = ReticuleTargetFn
								self.fake_deployplacer.components.reticule.ease = true

								local newreticule = self.fake_deployplacer.components.reticule
								if newreticule ~= self.reticule then
									if self.reticule ~= nil then
										self.reticule:DestroyReticule()
									end
									self.reticule = newreticule
									if newreticule ~= nil and newreticule.reticule == nil and (newreticule.mouseenabled or TheInput:ControllerAttached()) then
										newreticule:CreateReticule()
										if newreticule.reticule ~= nil and (not self:IsEnabled() or newreticule:ShouldHide()) then
											newreticule.reticule:Hide()
										end
									end
								end
								self.fake_deployplacer.components.placer:OnUpdate(0) --so that our position is accurate on the first frame
							end
							LoadGeometricPlacementCtrlOption()
						end
					end
				end
			end
		end
		OnUpdate_Old(self, dt, ...)
	end

	local ToggleController_Old = self.ToggleController
	self.ToggleController = function (self, val, ...)
		ToggleController_Old(self, val, ...)
		self.inst.HUD.controls.inv.rebuild_pending = true
	end

	self.ShouldPlayerHUDControlBeIgnored = function (self, control, down, ...)
		if self:IsAxisAlignedPlacement() and
			control ~= CONTROL_AXISALIGNEDPLACEMENT_CYCLEGRID and
			TheInput:ControlsHaveSameMapping(TheInput:GetControllerID(), control, CONTROL_AXISALIGNEDPLACEMENT_CYCLEGRID) then
			return true
		end
		return false
	end

end)