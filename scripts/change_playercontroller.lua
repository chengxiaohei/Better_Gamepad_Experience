
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
							iitem.replica.stackable ~= nil and container.replica.container:AcceptsStacks() then
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
							iitem.replica.stackable ~= nil and container.replica.inventory:AcceptsStacks() then
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

	-- New Added
	local ChangePlayerController = function (self, control, inv_item, active_item, slot, container, target, left, right)
		self:ClearActionHold()
		if control == CONTROL_INVENTORY_DROP then
			self:DoControllerDropItemFromInvTile(active_item or inv_item, right)
		elseif control == CONTROL_INVENTORY_EXAMINE then
			self:DoControllerInspectItemFromInvTile(active_item or inv_item)
		elseif control == CONTROL_INVENTORY_USEONSELF then
			if left and right and active_item ~= nil and inv_item ~= nil and inv_item.replica.container ~= nil and inv_item.replica.container:IsOpenedBy(self.inst) then
				PutActiveItemInContainer(self, active_item, inv_item, true)
			elseif left and active_item ~= nil and inv_item ~= nil and inv_item.replica.container ~= nil and inv_item.replica.container:IsOpenedBy(self.inst) then
				PutActiveItemInContainer(self, active_item, inv_item, false)
			elseif right and container ~= nil and slot ~= nil and inv_item ~= nil then
				local cursor_container_type = QueryContainerType(self, container.inst)
				local iv,hc,pc,bc,lc,rc = self:GetAllTypeContainers()
				local container_list = {}
				if cursor_container_type == "inv" then
					--put into (rc or lc or bc or pc or hc or iv)
					table.insert(container_list, rc) table.insert(container_list, lc) table.insert(container_list, bc)
					table.insert(container_list, pc) table.insert(container_list, hc) --[[ table.insert(container_list, iv) ]]
					container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
				elseif cursor_container_type == "hand" then
					-- put into (rc or lc or bc or pc or iv or hc)
					table.insert(container_list, rc) table.insert(container_list, lc) table.insert(container_list, bc)
					table.insert(container_list, pc) table.insert(container_list, iv) --[[ table.insert(container_list, hc) ]]
					container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
				elseif cursor_container_type == "pack" then
					-- put into (rc or lc or bc or hc or iv or pc)
					table.insert(container_list, rc) table.insert(container_list, lc) table.insert(container_list, bc)
					table.insert(container_list, hc) table.insert(container_list, iv) --[[ table.insert(container_list, pc) ]]
					container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
				elseif cursor_container_type == "beard" then
					-- put into (rc or lc or pc or hc or iv or bc)
					table.insert(container_list, rc) table.insert(container_list, lc) table.insert(container_list, pc)
					table.insert(container_list, hc) table.insert(container_list, iv) --[[ table.insert(container_list, bc) ]]
					container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
				elseif cursor_container_type == "chest" then
					-- put into (rc or bc or pc or hc or iv or lc)
					table.insert(container_list, rc) table.insert(container_list, bc) table.insert(container_list, pc)
					table.insert(container_list, hc) table.insert(container_list, iv) --[[ table.insert(container_list, lc) ]]
					container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
				elseif cursor_container_type == "cooker" then
					-- put into (bc or pc or hc or iv or lc or rc)
					table.insert(container_list, bc) table.insert(container_list, pc) table.insert(container_list, hc)
					table.insert(container_list, iv) table.insert(container_list, lc) --[[ table.insert(container_list, rc) ]]
					container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
				end
			else
				if inv_item ~= nil and active_item ~= nil and self:GetItemUseAction(active_item, inv_item) ~= nil then
					self.inst.replica.inventory:ControllerUseItemOnItemFromInvTile(inv_item, active_item)
				else
					self:DoControllerUseItemOnSelfFromInvTile(active_item or inv_item)
				end
			end

		elseif control == CONTROL_INVENTORY_USEONSCENE then
			if right and container ~= nil and slot ~= nil and inv_item ~= nil then
				local cursor_container_type = QueryContainerType(self, container.inst)
				local iv,hc,pc,bc,lc,rc = self:GetAllTypeContainers()
				local container_list = {}
				if cursor_container_type == "inv" then
					--put into (lc or rc or bc or pc or hc or iv)
					table.insert(container_list, lc) table.insert(container_list, rc) table.insert(container_list, bc)
					table.insert(container_list, pc) table.insert(container_list, hc) --[[ table.insert(container_list, iv) ]]
					container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
				elseif cursor_container_type == "hand" then
					-- put into (lc or rc or iv or bc or pc or hc)
					table.insert(container_list, lc) table.insert(container_list, rc) table.insert(container_list, iv)
					table.insert(container_list, bc) table.insert(container_list, pc) --[[ table.insert(container_list, hc) ]]
					container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
				elseif cursor_container_type == "pack" then
					-- put into (lc or rc or iv or hc or bc or pc)
					table.insert(container_list, lc) table.insert(container_list, rc) table.insert(container_list, iv)
					table.insert(container_list, hc) table.insert(container_list, bc) --[[ table.insert(container_list, pc) ]]
					container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
				elseif cursor_container_type == "beard" then
					-- put into (lc or rc or iv or hc or pc or bc)
					table.insert(container_list, lc) table.insert(container_list, rc) table.insert(container_list, iv)
					table.insert(container_list, hc) table.insert(container_list, pc) --[[ table.insert(container_list, bc) ]]
					container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
				elseif cursor_container_type == "chest" then
					-- put into (iv or hc or bc or pc or rc or lc)
					table.insert(container_list, iv) table.insert(container_list, hc) table.insert(container_list, bc)
					table.insert(container_list, pc) table.insert(container_list, rc) --[[ table.insert(container_list, lc) ]]
					container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
				elseif cursor_container_type == "cooker" then
					-- put into (lc or iv or hc or bc or pc or rc)
					table.insert(container_list, lc) table.insert(container_list, iv) table.insert(container_list, hc)
					table.insert(container_list, bc) table.insert(container_list, pc) --[[ table.insert(container_list, rc) ]]
					container:MoveItemFromAllOfSlot(slot, FilterContainer(inv_item, container_list))
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

	local IsControllerTargetingModifierDown_Old = self.IsControllerTargetingModifierDown
	self.IsControllerTargetingModifierDown = function (self, ...)
		local result = IsControllerTargetingModifierDown_Old(self, ...)
		if result and CHANGE_IS_LOCK_TARGET_QUICKLY and TheInput:IsControlPressed(CHANGE_FORCE_BUTTON or CHANGE_CONTROL_LEFT) then
			self.controller_targeting_lock_timer = self.controller_targeting_lock_timer and self.controller_targeting_lock_timer + 0.9 or 0.9
			return result
		end
		return result
	end

	local GetInspectButtonAction_Old = self.GetInspectButtonAction
	self.GetInspectButtonAction = function (self, target, ...)
		return GetInspectButtonAction_Old(self, target or self:GetControllerAltTarget() or self:GetControllerAttackTarget(), ...)
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

		if down and self._hack_ignore_held_controls then
			self._hack_ignore_ups_for[control] = true
			return true
		end
		if not down and self._hack_ignore_ups_for and self._hack_ignore_ups_for[control] then
			self._hack_ignore_ups_for[control] = nil
			return true
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

	-- Used for change the way your camera control ----------------------------------------------------------------------
	local DoCameraControl_Old = self.DoCameraControl
	local CHANGE_ROT_REPEAT = .25
	local CHANGE_ZOOM_REPEAT = .1
	local DoCameraControl_New = function(self, ...)
		if not TheCamera:CanControl() then
			return
		end

		if self.inst.HUD:IsCraftingOpen() then
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
			if not CHANGE_IS_USE_DPAD_SELECT_CRAFTING_MENU and self.inst.HUD:IsCraftingOpen() then
				return isenabled, ishudblocking
			end
			if not CHANGE_IS_USE_DPAD_SELECT_SPELLBOOK_ITEM and self.inst.HUD:IsSpellWheelOpen() then
				return isenabled, ishudblocking
			end
			return true
		end
		return isenabled, ishudblocking
	end

	self.controller_alt_target = nil
    self.controller_alt_target_age = math.huge

	local TARGET_EXCLUDE_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }
	local REGISTERED_CONTROLLER_ATTACK_TARGET_TAGS = TheSim:RegisterFindTags({ "_combat" }, TARGET_EXCLUDE_TAGS)

	-- Numerous changes
	local function UpdateControllerInteractionTarget(self, dt, x, y, z, dirx, dirz, heading_angle)
		if self.placer ~= nil or (self.deployplacer ~= nil and self.deploy_mode) or self.inst:HasTag("usingmagiciantool") then
			self.controller_target = nil
			self.controller_target_age = 0
			self.controller_alt_target = nil
			self.controller_alt_target_age = 0
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

		if self.controller_alt_target ~= nil
			and (not self.controller_alt_target:IsValid() or
				self.controller_alt_target:HasTag("INLIMBO") or
				self.controller_alt_target:HasTag("NOCLICK") or
				not CanEntitySeeTarget(self.inst, self.controller_alt_target)) then
			--"FX" and "DECOR" tag should never change, should be safe to skip that check
			self.controller_alt_target = nil
			--it went invalid, but we're not resetting the age yet
		end

		self.controller_target_age = self.controller_target_age + dt
		self.controller_alt_target_age = self.controller_alt_target_age + dt
		if self.controller_target_age < .2 and self.controller_alt_target_age < .2 then
			--prevent target flickering
			return
		end

		local equiped_item = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

		--Fishing targets may have large radius, making it hard to target with normal priority
		local fishing = equiped_item ~= nil and equiped_item:HasTag("fishingrod")

		-- we want to never target our fishing hook, but others can
		local ocean_fishing_target = (equiped_item ~= nil and equiped_item.replica.oceanfishingrod ~= nil) and equiped_item.replica.oceanfishingrod:GetTarget() or nil

		local min_rad = 1.5
		local max_rad = 6
		local min_rad_sq = min_rad * min_rad
		local max_rad_sq = max_rad * max_rad

		local target_rad =
				self.controller_target ~= nil and
				math.max(min_rad, math.min(max_rad, math.sqrt(self.inst:GetDistanceSqToInst(self.controller_target)))) or
				max_rad
		local alt_target_rad =
				self.controller_alt_target ~= nil and
				math.max(min_rad, math.min(max_rad, math.sqrt(self.inst:GetDistanceSqToInst(self.controller_alt_target)))) or
				max_rad
		local target_rad_sq = target_rad * target_rad + .1 --allow small error
		local alt_target_rad_sq = alt_target_rad * alt_target_rad + .1 --allow small error

		local nearby_ents = TheSim:FindEntities(x, y, z, fishing and max_rad or math.max(target_rad, alt_target_rad), nil, TARGET_EXCLUDE_TAGS)

		--Note: it may already contain controller_target,
		--      so make sure to handle it only once later
		if self.controller_target ~= nil and self.controller_alt_target ~= nil then
			if self.controller_target ~= self.controller_alt_target then
				table.insert(nearby_ents, 1, self.controller_alt_target)
			end
			table.insert(nearby_ents, 1, self.controller_target)
		elseif self.controller_target ~= nil or self.controller_alt_target ~= nil then
			table.insert(nearby_ents, 1, self.controller_target or self.controller_alt_target)
		end

		local target = nil
		local target_score = 0
		local alt_target = nil
		local alt_target_score = 0
		local examine_target = nil
		local examine_target_score = 0
		local alt_target_has_found = false
		local canexamine = (self.inst.CanExamine == nil or self.inst:CanExamine())
					and (not self.inst.HUD:IsPlayerAvatarPopUpOpen())
					and (self.inst.sg == nil or self.inst.sg:HasStateTag("moving") or self.inst.sg:HasStateTag("idle") or self.inst.sg:HasStateTag("channeling"))
					and (self.inst:HasTag("moving") or self.inst:HasTag("idle") or self.inst:HasTag("channeling"))

		local onboat = self.inst:GetCurrentPlatform() ~= nil
		local anglemax = onboat and TUNING.CONTROLLER_BOATINTERACT_ANGLE or TUNING.CONTROLLER_INTERACT_ANGLE
		for i, v in ipairs(nearby_ents) do
			v = v.client_forward_target or v
			if v ~= ocean_fishing_target then

				if not CHANGE_FORCE_BUTTON or TheInput:IsControlPressed(CHANGE_FORCE_BUTTON) or
					-- not(v:HasTag("trap") and v.replica.inventoryitem ~= nil and v:HasTag("mineactive")) then
					not((v.prefab == "trap_teeth" or v.prefab == "trap_teeth_maxwell" or v.prefab == "trap_bramble") and v:HasTag("mineactive")) then

					--Only handle controller_target if it's the one we added at the front
					if v ~= self.inst and (v ~= self.controller_target or i == 1) and (v ~= self.controller_alt_target or i == 1 or i == 2) and v.entity:IsVisible() then
						if v.entity:GetParent() == self.inst and v:HasTag("bundle") then
							--bundling or constructing
							alt_target = v
							alt_target_has_found = true
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

						-- local included_angle = dsq > 0 and math.acos((dx*dirx + dz*dirz) / (math.sqrt(dx*dx + dz*dz) * math.sqrt(dirx*dirx + dirz*dirz))) / DEGREES or 0
						local included_angle = dsq > 0 and math.acos((dx*dirx + dz*dirz) / (math.sqrt(dsq))) / DEGREES or 0

						if (dsq < min_rad_sq) or
							(dsq <= target_rad_sq and v == self.controller_target and dx * dirx + dz * dirz > 0) or
							(dsq <= alt_target_rad_sq and v == self.controller_alt_target and dx * dirx + dz * dirz > 0) or
							(self.controller_target ~= nil and dsq <= target_rad_sq and included_angle < anglemax) or
							(self.controller_alt_target ~= nil and dsq <= alt_target_rad_sq and included_angle < anglemax) or
							(dsq <= max_rad_sq and included_angle < anglemax) and
							CanEntitySeePoint(self.inst, x1, y1, z1) then
							-- Incorporate the y component after we've performed the inclusion radius test.
							-- We wait until now because we might disqualify our controller_target if its transform has a y component,
							-- but we still want to use the y component as a tiebreaker for objects at the same x,z position.
							dsq = dsq + (dy * dy)

							local dist = dsq > 0 and math.sqrt(dsq) or 0
							local dot = dist > 0 and dx / dist * dirx + dz / dist * dirz or 0

							--keep the angle component between [0..1]
							local angle_component = (dot + 1) / 2

							--distance doesn't matter when you're really close, and then attenuates down from 1 as you get farther away
							local dist_component = dsq < min_rad_sq and 1 or min_rad_sq / dsq

							--for stuff that's *really* close - ie, just dropped
							local add = dsq < .0625 --[[.25 * .25]] and 1 or 0

							--just a little hysteresis
							local mult = v == self.controller_target and not v:HasTag("wall") and 1.5 or 1
							local alt_mult = v == self.controller_alt_target and not v:HasTag("wall") and 1.5 or 1

							local score = angle_component * dist_component * mult * alt_mult + add

							--make it easier to target stuff dropped inside the portal when alive
							--make it easier to haunt the portal for resurrection in endless mode
							if v:HasTag("portal") then
								score = score * (self.inst:HasTag("playerghost") and GetPortalRez() and 1.1 or .9)
							end

							if v:HasTag("hasfurnituredecoritem") then
								score = score * 0.5
							end

							-- print(v, angle_component, dist_component, mult, add, score)

							local lmb, rmb = self:GetSceneItemControllerAction(v)

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
							else
								local inv_obj = self:GetCursorInventoryObject()
								if inv_obj ~= nil then
									local act = self:GetItemUseAction(inv_obj, v)
									if act ~= nil and act.target == v then
										target = v
										target_score = score
									end
								end
							end

							if score < alt_target_score or
								(   score == alt_target_score and
									(   (alt_target ~= nil and not (alt_target.CanMouseThrough ~= nil and alt_target:CanMouseThrough())) or
										(v.CanMouseThrough ~= nil and v:CanMouseThrough())
									)
								) then
								--skip
							elseif rmb ~= nil and not alt_target_has_found then
								alt_target = v
								alt_target_score = score
							end
							
							-- find examine_target
							if score < examine_target_score or
								(   score == examine_target_score and
									(   (examine_target ~= nil and not (examine_target.CanMouseThrough ~= nil and examine_target:CanMouseThrough())) or
										(v.CanMouseThrough ~= nil and v:CanMouseThrough())
									)
								) then
								--skip
							elseif canexamine and v:HasTag("inspectable") then
								examine_target = v
								examine_target_score = score
							end
						end
					end
				end
			end
		end

		if target == nil then
			target = examine_target
		end
		if alt_target == nil then
			alt_target = examine_target
		end

		if target ~= self.controller_target then
			self.controller_target = target
			self.controller_target_age = 0
			-- print("****** change target to: ", target)
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
	local function IsNeedForceAttack(self, target)
		return not TargetIsHostile(self.inst, target) and
			target ~= self.inst.replica.combat:GetTarget() and
			self.inst ~= target.replica.combat:GetTarget()
	end
	-- changed a little
	local function UpdateControllerAttackTarget(self, dt, x, y, z, dirx, dirz)
		if self.inst:HasTag("playerghost") or self.inst.replica.inventory:IsHeavyLifting() then
			self.controller_attack_target = nil
			self.controller_attack_target_ally_cd = nil

			-- we can't target right now; disable target locking
			self.controller_targeting_lock_target = false
			return
		end

		local combat = self.inst.replica.combat

		self.controller_attack_target_ally_cd = math.max(0, (self.controller_attack_target_ally_cd or 1) - dt)

		if self.controller_attack_target ~= nil and
			not (combat:CanTarget(self.controller_attack_target) and
				CanEntitySeeTarget(self.inst, self.controller_attack_target)) then
			self.controller_attack_target = nil

			-- target is no longer valid; disable target locking
			self.controller_targeting_lock_target = false
			--it went invalid, but we're not resetting the age yet
		end

		--self.controller_attack_target_age = self.controller_attack_target_age + dt
		--if self.controller_attack_target_age < .3 then
			--prevent target flickering
		--    return
		--end

		local equipped_item = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		local forced_rad = equipped_item ~= nil and equipped_item.controller_use_attack_distance or 0

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
		local target_isally = true
		local preferred_target =
			TheInput:IsControlPressed(CONTROL_CONTROLLER_ATTACK) and
			self.controller_attack_target or
			combat:GetTarget() or
			nil

		local current_controller_targeting_targets = {}
		local selected_target_index = 0
		for i, v in ipairs(nearby_ents) do
			if v ~= self.inst and (v ~= self.controller_attack_target or i == 1) then
				local isally = combat:IsAlly(v)
				if not (isally and
						self.controller_attack_target_ally_cd > 0 and
						v ~= preferred_target) and
					combat:CanTarget(v) then
					
					-- ================================================================================================= --
					local need_force_attack = IsNeedForceAttack(self, v)
					if not CHANGE_FORCE_BUTTON or not need_force_attack or TheInput:IsControlPressed(CHANGE_FORCE_BUTTON) or self.controller_targeting_lock_target then
					-- ================================================================================================= --

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
							if dot > 0 or dist < min_rad + phys_rad then
								--now calculate score with physics radius subtracted
								dist = math.max(0, dist - phys_rad)
								local score = dot + 1 - 0.5 * dist * dist / max_rad_sq

								if isally then
									score = score * .25
								elseif CheckControllerPriorityTagOrOverride(v, "epic", v.controller_priority_override_is_epic) then
									score = score * 5
								elseif CheckControllerPriorityTagOrOverride(v, "monster", v.controller_priority_override_is_monster) then
									score = score * 4
								end

								if v.replica.combat:GetTarget() == self.inst or FunctionOrValue(v.controller_priority_override_is_targeting_player) then
									score = score * 6
								end

								if v == preferred_target then
									score = score * 10
								end

								table.insert(current_controller_targeting_targets, v)
								if score > target_score then
									selected_target_index = #current_controller_targeting_targets
									target = v
									target_score = score
									target_isally = isally
								end
							end
						end
					-- ================================================================================================= --
					end
					-- ================================================================================================= --
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
					target_isally = true
				end
			-- ============================================================================================================ --
			-- elseif self.controller_target:HasTag("wall") and not IsEntityDead(self.controller_target, true) then
			-- 	--if we have no (X) control target, then give
			-- 	--it to our (Y) control target if it's a wall
			-- 	target = self.controller_target
			-- 	target_isally = false
			-- ============================================================================================================ --
			end
		end

		if target ~= self.controller_attack_target then
			self.controller_attack_target = target
			self.controller_targeting_target_index = selected_target_index
			--self.controller_attack_target_age = 0
		end

		if not target_isally then
			--reset ally targeting cooldown
			self.controller_attack_target_ally_cd = nil
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
				self.controller_attack_target_ally_cd = nil
				self.controller_targeting_lock_target = nil
			end
		else
			UpdateControllerInteractionTarget(self, dt, x, y, z, dirx, dirz, heading_angle)
			UpdateControllerAttackTarget(self, dt, x, y, z, dirx, dirz)
		end
	end

	-- Not Changed
	local function PullUpMap(inst, maptarget)
		-- NOTES(JBK): This is assuming inst is the local client on call with a check to inst.HUD not being nil.
		if inst.HUD:IsCraftingOpen() then
			inst.HUD:CloseCrafting()
		end
		if inst.HUD:IsSpellWheelOpen() then
			inst.HUD:CloseSpellWheel()
		end
		if inst.HUD:IsControllerInventoryOpen() then
			inst.HUD:CloseControllerInventory()
		end
		-- Pull up map now.
		if not inst.HUD:IsMapScreenOpen() then
			inst.HUD.controls:ToggleMap()
			if inst.HUD:IsMapScreenOpen() then -- Just in case.
				local mapscreen = TheFrontEnd:GetActiveScreen()
				mapscreen._hack_ignore_held_controls = 0.1
				mapscreen._hack_ignore_ups_for = {}
				mapscreen.maptarget = maptarget
				local min_dist = maptarget.map_remap_min_dist
				if min_dist then
					min_dist = min_dist + 0.1 -- Padding for floating point precision.
					local x, y, z = inst.Transform:GetWorldPosition()
					local rotation = inst.Transform:GetRotation() * DEGREES
					local wx, wz = x + math.cos(rotation) * min_dist, z - math.sin(rotation) * min_dist -- Z offset is negative to desired from Transform coordinates.
					inst.HUD.controls:FocusMapOnWorldPosition(mapscreen, wx, wz)
				end
				-- Do not have to take into account max_dist because the map automatically centers on the player when opened.
			end
		end
	end

	-- Newly created function
	self.GetControllerAltTarget = function (self, ...)
		return self.controller_alt_target ~= nil and self.controller_alt_target:IsValid() and self.controller_alt_target or nil
	end

	-- Only Change One Line
	local DoControllerAltActionButton_New = function (self, ...)
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
		elseif self:IsControllerTargetLockEnabled() then
			self:ControllerTargetLock(false)
			return
		end

		self.actionholdtime = GetTime()

		local lmb, act = self:GetGroundUseAction()
		local isspecial = nil
		local obj = act ~= nil and act.target or nil
		if act == nil then
			-- ========================================================================= --
			-- obj = self:GetControllerTarget()
			obj = self:GetControllerAltTarget()
			-- ========================================================================= --
			if obj ~= nil then
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
			end
			if act == nil then
				act = self:GetGroundUseSpecialAction(nil, true)
				if act ~= nil then
					obj = nil
					isspecial = true
				else
					local rider = self.inst.replica.rider
					if rider ~= nil and rider:IsRiding() then
						obj = self.inst
						act = BufferedAction(obj, obj, ACTIONS.DISMOUNT)
					else
						self:TryAOETargeting()
						return
					end
				end
			end
		end

		if self.reticule ~= nil and self.reticule.reticule ~= nil and self.reticule.reticule.entity:IsVisible() then
			self.reticule:PingReticuleAt(act:GetDynamicActionPoint())
		end

		local maptarget = self:GetMapTarget(act)
		if maptarget ~= nil then
			PullUpMap(self.inst, maptarget)
			return
		end

		if self.ismastersim then
			self.inst.components.combat:SetTarget(nil)
		elseif obj ~= nil then
			if self.locomotor == nil then
				self.remote_controls[CONTROL_CONTROLLER_ALTACTION] = 0
				SendRPCToServer(RPC.ControllerAltActionButton, act.action.code, obj, nil, act.action.canforce, act.action.mod_name)
			elseif self:CanLocomote() then
				act.preview_cb = function()
					self.remote_controls[CONTROL_CONTROLLER_ALTACTION] = 0
					local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ALTACTION)
					SendRPCToServer(RPC.ControllerAltActionButton, act.action.code, obj, isreleased, nil, act.action.mod_name)
				end
			end
		elseif self.locomotor == nil then
			self.remote_controls[CONTROL_CONTROLLER_ALTACTION] = 0
			SendRPCToServer(RPC.ControllerAltActionButtonPoint, act.action.code, act.pos.local_pt.x, act.pos.local_pt.z, nil, act.action.canforce, isspecial, act.action.mod_name, act.pos.walkable_platform, act.pos.walkable_platform ~= nil)
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
			local widget = cooker_type_container.replica.container ~= nil and cooker_type_container.replica.container:GetWidget() or nil
			if widget ~= nil and widget.buttoninfo ~= nil and widget.buttoninfo.fn ~= nil then
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
		if TheInput:IsControlPressed(CHANGE_FORCE_BUTTON or CHANGE_CONTROL_LEFT) and self:TryWidgetButtonFunction(true) then
			return
		end
		DoControllerAltActionButton_New_Old(self, ...)
	end

	-- Allow Attack while AoeTargeting (Changed a little)
	local DoControllerAttackButton_Old = self.DoControllerAttackButton
	local DoControllerAttackButton_New = function (self, target, ...)
		-- ================================================================================================= --
		-- if target == nil and (self:IsAOETargeting() or self.inst:HasTag("sitting_on_chair")) then
		-- 	return
		-- elseif target ~= nil then
		if target ~= nil then
		-- ================================================================================================= --
			--Don't want to spam the controller attack button when retargetting
			if not self.ismastersim and (self.remote_controls[CONTROL_CONTROLLER_ATTACK] or 0) > 0 then
				return
			end

			if self.inst.sg ~= nil then
				if self.inst.sg:HasStateTag("attack") then
					return
				end
			elseif self.inst:HasTag("attack") then
				return
			end

			if not self.inst.replica.combat:CanHitTarget(target) or
				IsEntityDead(target, true) or
				not CanEntitySeeTarget(self.inst, target) then
				return
			end
		else
			target = self.controller_attack_target
			if target ~= nil then
				if target == self.inst.replica.combat:GetTarget() then
					--Still need to let the server know our controller attack button is down
					if not self.ismastersim and
						self.locomotor == nil and
						self.remote_controls[CONTROL_CONTROLLER_ATTACK] == nil then
						self.remote_controls[CONTROL_CONTROLLER_ATTACK] = 0
						SendRPCToServer(RPC.ControllerAttackButton, true)
					end
					return
				elseif not self.inst.replica.combat:CanTarget(target) then
					target = nil
				end
			end
			--V2C: controller attacks still happen even with no valid target
			if target == nil and (
				self.directwalking or
				self.inst:HasTag("playerghost") or
				self.inst:HasTag("weregoose") or
				self.inst.replica.inventory:IsHeavyLifting() or
				(self.classified and self.classified.inmightygym:value() > 0) or
				GetGameModeProperty("no_air_attack")
			) then
				--Except for player ghosts!
				return
			end
		end

		local act = BufferedAction(self.inst, target, ACTIONS.ATTACK)

		if self.ismastersim then
			self.inst.components.combat:SetTarget(nil)
		elseif self.locomotor == nil then
			self.remote_controls[CONTROL_CONTROLLER_ATTACK] = BUTTON_REPEAT_COOLDOWN
			SendRPCToServer(RPC.ControllerAttackButton, target, nil, act.action.canforce)
		elseif self:CanLocomote() then
			act.preview_cb = function()
				self.remote_controls[CONTROL_CONTROLLER_ATTACK] = BUTTON_REPEAT_COOLDOWN
				local isreleased = not TheInput:IsControlPressed(CONTROL_CONTROLLER_ATTACK)
				SendRPCToServer(RPC.ControllerAttackButton, target, isreleased)
			end
		end

		self:DoAction(act)
	end

	self.DoControllerAttackButton = function (self, target, ...)
		if TheInput:ControllerAttached() then
			DoControllerAttackButton_New(self, target, ...)
		else
			DoControllerAttackButton_Old(self, target, ...)
		end
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
						end
					end
				end
			end
		end
		OnUpdate_Old(self, dt, ...)
	end

end)