
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
	self.GetAllTypeContainers = function (self)
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
					else
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
			if left and right and active_item ~= nil and inv_item ~= nil and inv_item.replica.container ~= nil then
				PutActiveItemInContainer(self, active_item, inv_item, true)
			elseif left and active_item ~= nil and inv_item ~= nil and inv_item.replica.container ~= nil then
				PutActiveItemInContainer(self, active_item, inv_item, false)
			elseif right and container ~= nil and slot ~= nil then
				local cursor_container_type = QueryContainerType(self, container.inst)
				local iv,hc,pc,bc,lc,rc = self:GetAllTypeContainers()
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
			else
				if inv_item ~= nil and active_item ~= nil and self:GetItemUseAction(active_item, inv_item) ~= nil then
					self.inst.replica.inventory:ControllerUseItemOnItemFromInvTile(inv_item, active_item)
				else
					self:DoControllerUseItemOnSelfFromInvTile(active_item or inv_item)
				end
			end

		elseif control == CONTROL_INVENTORY_USEONSCENE then
			if right and container ~= nil and slot ~= nil then
				local cursor_container_type = QueryContainerType(self, container.inst)
				local iv,hc,pc,bc,lc,rc = self:GetAllTypeContainers()
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
			if v ~= ocean_fishing_target then

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

	-- Not changed yet
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
			elseif self.controller_target:HasTag("wall") and not IsEntityDead(self.controller_target, true) then
				--if we have no (X) control target, then give
				--it to our (Y) control target if it's a wall
				target = self.controller_target
				target_isally = false
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

	-- A little Changed, but the main purpose is apply local function UpdateControllerInteractionTarget
	self.UpdateControllerTargets = function (self, dt, ...)
		if self:IsAOETargeting() or
			self.inst:HasTag("sitting_on_chair") or
			(self.inst:HasTag("weregoose") and not self.inst:HasTag("playerghost")) or
			(self.classified and self.classified.inmightygym:value() > 0) then
			self.controller_target = nil
			self.controller_target_age = 0
			-- ================================================================================= --
			self.controller_alt_target = nil
			self.controller_alt_target_age = 0
			-- ================================================================================= --
			self.controller_attack_target = nil
			self.controller_attack_target_ally_cd = nil
			self.controller_targeting_lock_target = nil
			return
		end
		local x, y, z = self.inst.Transform:GetWorldPosition()
		local heading_angle = -self.inst.Transform:GetRotation()
		local dirx = math.cos(heading_angle * DEGREES)
		local dirz = math.sin(heading_angle * DEGREES)
		UpdateControllerInteractionTarget(self, dt, x, y, z, dirx, dirz, heading_angle)
		UpdateControllerAttackTarget(self, dt, x, y, z, dirx, dirz)
		-- ================================================================================= --
		-- UpdateControllerConflictingTargets(self)
		-- ================================================================================= --
	end

	-- Newly created function
	self.GetControllerAltTarget = function (self, ...)
		return self.controller_alt_target ~= nil and self.controller_alt_target:IsValid() and self.controller_alt_target or nil
	end

	-- Only Change One Line
	self.DoControllerAltActionButton = function (self, ...)
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

		if act.invobject ~= nil and act.invobject:HasTag("action_pulls_up_map") then
			if self.inst.HUD ~= nil then
				PullUpMap(self.inst, act.invobject)
				return
			end
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

	-- Not Changed
	local START_DRAG_TIME = 8 * FRAMES
	local BUTTON_REPEAT_COOLDOWN = .5
	local ACTION_REPEAT_COOLDOWN = 0.2
	local INVENTORY_ACTIONHOLD_REPEAT_COOLDOWN = 0.8
	local BUFFERED_CASTAOE_TIME = .5
	local BUFFERED_ACTION_NO_CANCEL_TIME = FRAMES + .0001
	local CONTROLLER_TARGETING_LOCK_TIME = 1.0
	local RUBBER_BAND_PING_TOLERANCE_IN_SECONDS = 0.7
	local RUBBER_BAND_DISTANCE = 4
	local RUBBER_BAND_DISTANCE_SQ = RUBBER_BAND_DISTANCE * RUBBER_BAND_DISTANCE

	local ACTIONHOLD_CONTROLS = {CONTROL_PRIMARY, CONTROL_SECONDARY, CONTROL_CONTROLLER_ALTACTION, CONTROL_INVENTORY_USEONSELF, CONTROL_INVENTORY_USEONSCENE}
	local function IsAnyActionHoldButtonHeld()
		for i, v in ipairs(ACTIONHOLD_CONTROLS) do
			if TheInput:IsControlPressed(v) then
				return true
			end
		end
		return false
	end

	local OnUpdate_Old = self.OnUpdate
	-- Fix Bug: Can Not Holding B to do alt action
	local OnUpdate_New = function (self, dt, ...)
		local isenabled, ishudblocking = self:IsEnabled()
		self.predictionsent = false

		if self:IsControllerTargetingModifierDown() and self.controller_targeting_lock_timer then
			-- check whether the controller targeting modifier has been held long enough to toggle locking
			self.controller_targeting_lock_timer = self.controller_targeting_lock_timer + dt
			if CONTROLLER_TARGETING_LOCK_TIME < self.controller_targeting_lock_timer then
				self:ControllerTargetLock(true)
				-- Use the block below if you want to both lock and unlock the target by holding down the modifier button
				--[[
				if self:IsControllerTargetLockEnabled() then
					self:ControllerTargetLock(false)
				else
					self:ControllerTargetLock(true)
				end
				--]]
				self.controller_targeting_lock_timer = nil
			end
		end

		if self.actionholding and not (isenabled and IsAnyActionHoldButtonHeld()) then
			self:ClearActionHold()
		end

		if self.draggingonground and not (isenabled and TheInput:IsControlPressed(CONTROL_PRIMARY)) then
			local buffaction
			if self.locomotor ~= nil then
				self.locomotor:Stop()
				if isenabled then
					buffaction = self.locomotor.bufferedaction
				else
					self.locomotor:Clear()
				end
			end
			self.draggingonground = false
			self.startdragtime = nil
			TheFrontEnd:LockFocus(false)

			--restart any buffered actions that may have been pushed at the
			--same time as the user releasing draggingonground
			if buffaction then
				if self.ismastersim then
					self.locomotor:PushAction(buffaction)
				else
					self.locomotor:PreviewAction(buffaction)
				end
			end
		end

		--ishudblocking set to true lets us know that the only reason for isenabled returning false is due to HUD wanting to handle some input.
		if not isenabled then
			local allow_loco = ishudblocking
			if not allow_loco then
				if self.directwalking or self.dragwalking then
					if self.locomotor ~= nil then
						self.locomotor:Stop()
						self.locomotor:Clear()
					end
					self.directwalking = false
					self.dragwalking = false
					self.predictwalking = false
					if not self.ismastersim then
						self:RemoteStopWalking()
					end
				end
			end

			if self.handler ~= nil then
				self:CancelPlacement(true)
				self:CancelDeployPlacement()
				self:CancelAOETargeting()
				if not ishudblocking and self.inst.HUD ~= nil then
					self.inst.HUD:CloseSpellWheel()
				end

				if self.reticule ~= nil and self.reticule.reticule ~= nil then
					self.reticule.reticule:Hide()
				end

				if self.terraformer ~= nil then
					self.terraformer:Remove()
					self.terraformer = nil
				end
				
				self.LMBaction, self.RMBaction = nil, nil
				self.controller_target = nil
				self.controller_attack_target = nil
				self.controller_attack_target_ally_cd = nil
				if self.highlight_guy ~= nil and self.highlight_guy:IsValid() and self.highlight_guy.components.highlight ~= nil then
					self.highlight_guy.components.highlight:UnHighlight()
				end
				self.highlight_guy = nil
			end

			if self.ismastersim then
				self:ResetRemoteController()
			else
				self:RemoteStopAllControls()

				--Other than HUD blocking, we would've been enabled otherwise
				if not self:IsBusy() then
					self:DoPredictWalking(dt)
				end
			end

			self.controller_attack_override = nil
			self.recent_bufferedaction.act = nil

			if not allow_loco then
				self.attack_buffer = nil
			end
		end

		if self:IsAOETargeting() then
			if not self.reticule.inst:IsValid() or self.reticule.inst:HasTag("fueldepleted") then
				self:CancelAOETargeting()
			else
				local inventoryitem = self.reticule.inst.replica.inventoryitem
				if inventoryitem ~= nil and not inventoryitem:IsGrandOwner(self.inst) then
					self:CancelAOETargeting()
				end
			end
		end

		if self.handler ~= nil and self.inst:HasTag("usingmagiciantool") then
			self:CancelPlacement()
			if not self:UsingMouse() then
				self:CancelDeployPlacement()
			end
			self:CancelAOETargeting()
		end

		--Attack controls are buffered and handled here in the update
		if self.attack_buffer ~= nil then
			if self.attack_buffer == CONTROL_ATTACK then
				self:DoAttackButton()
			elseif self.attack_buffer == CONTROL_CONTROLLER_ATTACK then
				self:DoControllerAttackButton()
			else
				if self.attack_buffer._predictpos then
					self.attack_buffer:SetActionPoint(self:GetRemotePredictPosition() or self.inst:GetPosition())
				end
				if self.attack_buffer._controller then
					if self.attack_buffer.target == nil then
						self.controller_attack_override = self:IsControlPressed(CONTROL_CONTROLLER_ATTACK) and self.attack_buffer or nil
					end
					self:DoAction(self.attack_buffer)
				else
					--Check for duplicate actions
					local currentbuffaction = self.inst:GetBufferedAction()
					if not (currentbuffaction ~= nil and
							currentbuffaction.action == self.attack_buffer.action and
							currentbuffaction.target == self.attack_buffer.target)
					then
						self.locomotor:PushAction(self.attack_buffer, true)
					end
				end
			end
			self.attack_buffer = nil
		end

		if isenabled then
			--Restore cached placer
			if self.placer_cached ~= nil then
				if self.inst.replica.inventory:IsVisible() then
					self:StartBuildPlacementMode(unpack(self.placer_cached))
				end
				self.placer_cached = nil
			end


			if self.handler ~= nil then
				local controller_mode = TheInput:ControllerAttached()
				local new_highlight = nil
				if not self.inst:IsActionsVisible() then
					--Don't highlight when actions are hidden
				elseif controller_mode then
					self.LMBaction, self.RMBaction = nil, nil
					self:UpdateControllerTargets(dt)
					new_highlight = self.controller_target
				else
					self.controller_target = nil
					self.controller_attack_target = nil
					self.controller_attack_target_ally_cd = nil
					self.LMBaction, self.RMBaction = self.inst.components.playeractionpicker:DoGetMouseActions()

					--If an action has a target, highlight the target.
					--If an action has no target and no pos, then it should
					--be an inventory action where doer is ourself and we are
					--targeting ourself, so highlight ourself
					new_highlight =
						(self.LMBaction ~= nil
						and (self.LMBaction.target
							or (self.LMBaction.pos == nil and
								self.LMBaction.doer == self.inst and
								self.inst))) or
						(self.RMBaction ~= nil
						and (self.RMBaction.target
							or (self.RMBaction.pos == nil and
								self.RMBaction.doer == self.inst and
								self.inst))) or
						nil
				end

				local new_highlight_guy = new_highlight ~= nil and new_highlight.highlightforward or new_highlight
				if new_highlight_guy ~= self.highlight_guy then
					if self.highlight_guy ~= nil and self.highlight_guy:IsValid() and self.highlight_guy.components.highlight ~= nil then
						self.highlight_guy.components.highlight:UnHighlight()
					end
					self.highlight_guy = new_highlight_guy
				end

				if new_highlight_guy ~= nil and new_highlight_guy:IsValid() then
					if new_highlight_guy.components.highlight == nil then
						new_highlight_guy:AddComponent("highlight")
					end

					if not self.inst.shownothightlight then
						--V2C: check tags on the original, not the forwarded
						if new_highlight:HasTag("burnt") then
							new_highlight_guy.components.highlight:Highlight(.5, .5, .5)
						else
							new_highlight_guy.components.highlight:Highlight()
						end
					end
				else
					self.highlight_guy = nil
				end

				if self.reticule ~= nil and not (controller_mode or self.reticule.mouseenabled) then
					self.reticule:DestroyReticule()
					self.reticule = nil
				end

				if self.placer ~= nil and self.placer_recipe ~= nil and
					not (self.inst.replica.builder ~= nil and self.inst.replica.builder:IsBuildBuffered(self.placer_recipe.name)) then
					self:CancelPlacement()
				end

				local placer_item = controller_mode and self:GetCursorInventoryObject() or self.inst.replica.inventory:GetActiveItem()
				--show deploy placer
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
					if self.deployplacer ~= nil and (self.deployplacer.prefab ~= placer_name or self.deployplacer.skinname ~= placer_skin) then
						self:CancelDeployPlacement()
					end
					if self.deployplacer == nil then
						self.deployplacer = SpawnPrefab(placer_name, placer_skin, nil, self.inst.userid )
						if self.deployplacer ~= nil then
							self.deployplacer.components.placer:SetBuilder(self.inst, nil, placer_item)
							self.deployplacer.components.placer.testfn = function(pt)
								local mouseover = TheInput:GetWorldEntityUnderMouse()
								return placer_item:IsValid() and
									placer_item.replica.inventoryitem ~= nil and
									placer_item.replica.inventoryitem:CanDeploy(pt, mouseover, self.inst, self.deployplacer.Transform:GetRotation()),
									(mouseover ~= nil and not mouseover:HasTag("walkableplatform") and not mouseover:HasTag("walkableperipheral") and not mouseover:HasTag("ignoremouseover")) or TheInput:GetHUDEntityUnderMouse() ~= nil
							end
							self.deployplacer.components.placer:OnUpdate(0) --so that our position is accurate on the first frame
						end
					end
				else
					self:CancelDeployPlacement()
				end

				local terraform = false
				local hideactionreticuleoverride = false
				local terraform_action = nil
				if controller_mode then
					local lmb, rmb = self:GetGroundUseAction()
					if rmb ~= nil then
						terraform = rmb.action.tile_placer ~= nil
						terraform_action = terraform and rmb.action or nil
						--hide reticule if not a point action (ie. STOPUSINGMAGICTOOL)
						hideactionreticuleoverride = rmb.pos == nil
					end
					--If reticule is from special action, hide it when other actions are available
					if not hideactionreticuleoverride and self.reticule ~= nil and self.reticule.inst == self.inst then
						if rmb == nil and self.controller_target ~= nil then
							lmb, rmb = self:GetSceneItemControllerAction(self.controller_target)
						end
						hideactionreticuleoverride = rmb ~= nil or not self:HasGroundUseSpecialAction(true)
					end
				else
					local rmb = self:GetRightMouseAction()
					if rmb ~= nil then
						terraform = rmb.action.tile_placer ~= nil and (rmb.action.show_tile_placer_fn == nil or rmb.action.show_tile_placer_fn(self:GetRightMouseAction()))
						terraform_action = terraform and rmb.action or nil
					end
				end

				--show right action reticule
				if self.placer == nil and self.deployplacer == nil then
					if terraform then
						if self.terraformer == nil then
							self.terraformer = SpawnPrefab(terraform_action.tile_placer)
							if self.terraformer ~= nil and self.terraformer.components.placer ~= nil then
								self.terraformer.components.placer:SetBuilder(self.inst)
								self.terraformer.components.placer:OnUpdate(0)
							end
						end
					elseif self.terraformer ~= nil then
						self.terraformer:Remove()
						self.terraformer = nil
					end

					if self.reticule ~= nil and self.reticule.reticule ~= nil then
						if hideactionreticuleoverride or self.reticule:ShouldHide() then
							self.reticule.reticule:Hide()
						else
							self.reticule.reticule:Show()
						end
					end
				else
					if self.terraformer ~= nil then
						self.terraformer:Remove()
						self.terraformer = nil
					end

					if self.reticule ~= nil and self.reticule.reticule ~= nil then
						self.reticule.reticule:Hide()
					end
				end

				if not self.actionholding and self.actionholdtime and IsAnyActionHoldButtonHeld() then
					if GetTime() - self.actionholdtime > START_DRAG_TIME then
						self.actionholding = true
					end
				end

				if not self.draggingonground and self.startdragtime ~= nil and TheInput:IsControlPressed(CONTROL_PRIMARY) then
					local now = GetTime()
					if now - self.startdragtime > START_DRAG_TIME then
						TheFrontEnd:LockFocus(true)
						self.draggingonground = true
					end
				end

				if TheFrontEnd:GetFocusWidget() ~= self.inst.HUD then
					if self.draggingonground then
						self.draggingonground = false
						self.startdragtime = nil

						TheFrontEnd:LockFocus(false)

						if self:CanLocomote() then
							self.locomotor:Stop()
							self.locomotor:Clear()
						end
					-- ==================================================================================================== --
					-- This is Very Useful to make alt action repeat correctly
					-- elseif self.actionholding then
					-- 	self:ClearActionHold()
					-- ==================================================================================================== --
					end
				end
			elseif self.ismastersim and self.inst:HasTag("nopredict") and self.remote_vector.y >= 3 then
				self.remote_vector.y = 0
				self.remote_predict_dir = nil
			end

			self:CooldownHeldAction(dt)
			if self.actionholding then
				self:RepeatHeldAction()
			end

			if self.controller_attack_override ~= nil and
				not (self.locomotor.bufferedaction == self.controller_attack_override and
					self:IsControlPressed(CONTROL_CONTROLLER_ATTACK)) then
				self.controller_attack_override = nil
			end
		end

		self:DoPredictHopping(dt)

		if not isenabled and not ishudblocking then
			self:DoClientBusyOverrideLocomote()
			return
		end

		--NOTE: isbusy is used further below as well
		local isbusy = self:IsBusy()

		--#HACK for hopping prediction
		--ignore server "busy" if server still "boathopping" but we're not anymore
		if isbusy and self.inst.sg ~= nil and self.inst:HasTag("boathopping") and not self.inst.sg:HasStateTag("boathopping") then
			isbusy = false
		end

		if isbusy then
			self:DoClientBusyOverrideLocomote()
			self.recent_bufferedaction.act = nil
		elseif self:DoPredictWalking(dt)
			or self:DoDragWalking(dt)
			then
			self.recent_bufferedaction.act = nil
		else
			local aimingcannon = self.inst.components.boatcannonuser ~= nil and self.inst.components.boatcannonuser:GetCannon() ~= nil
			if not (aimingcannon or self.inst:HasTag("steeringboat") or self.inst:HasTag("rotatingboat")) then
				if self.wassteering then
					-- end reticule
					local boat = self.inst:GetCurrentPlatform()
					if boat then
						boat:PushEvent("endsteeringreticule",{player=self.inst})
					end
					self.wassteering = nil
				end
				self:DoDirectWalking(dt)
			elseif aimingcannon then

			else
				if not self.wassteering then
					-- start reticule
					local boat = self.inst:GetCurrentPlatform()
					if boat then
						boat:PushEvent("starsteeringreticule",{player=self.inst})
					end
				end
				self.wassteering = true

				if self.inst:HasTag("steeringboat") then
					self:DoBoatSteering(dt)
				end

			end
		end

		--do automagic control repeats
		if self.handler ~= nil then
			local isidle = self.inst:HasTag("idle")

			if not self.ismastersim then
				--clear cooldowns if we actually did something on the server
				--otherwise just decrease
				--if the server is still "idle", then it hasn't begun processing the action yet
				--when using movement prediction, the RPC is sent AFTER reaching the destination,
				--so we must also check that the server is not still "moving"
				self:CooldownRemoteController((isidle or (self.inst.sg ~= nil and self.inst:HasTag("moving"))) and dt or nil)
			end

			if self.inst.sg ~= nil then
				isidle = self.inst.sg:HasStateTag("idle") or (isidle and self.inst:HasTag("nopredict"))
			end
			if isidle then
				if TheInput:IsControlPressed(CONTROL_ACTION) then
					self:OnControl(CONTROL_ACTION, true)
				elseif TheInput:IsControlPressed(CONTROL_CONTROLLER_ACTION)
					and not self:IsDoingOrWorking() then
					self:OnControl(CONTROL_CONTROLLER_ACTION, true)
				end
			end
		end

		if self.ismastersim and self.handler == nil and not self.inst.sg.mem.localchainattack then
			if self.inst.sg.statemem.chainattack_cb ~= nil then
				if self.locomotor ~= nil and self.locomotor.bufferedaction ~= nil and self.locomotor.bufferedaction.action == ACTIONS.CASTAOE then
					self.inst.sg.statemem.chainattack_cb = nil
				elseif not self.inst.sg:HasStateTag(self.remote_authority and self.remote_predicting and "abouttoattack" or "attack") then
					--Handles chain attack commands received at irregular intervals
					local fn = self.inst.sg.statemem.chainattack_cb
					self.inst.sg.statemem.chainattack_cb = nil
					fn()
				end
			end
		elseif (self.ismastersim or self.handler ~= nil)
			and not (self.directwalking or isbusy)
			and not (self.locomotor ~= nil and self.locomotor.bufferedaction ~= nil and self.locomotor.bufferedaction.action == ACTIONS.CASTAOE) then
			local attack_control = false
			local currenttarget = self:GetCombatTarget()
			local retarget = self:GetCombatRetarget()
			if self.inst.sg ~= nil then
				attack_control = not self.inst.sg:HasStateTag("attack") or currenttarget ~= retarget
			else
				attack_control = not self.inst:HasTag("attack")
			end
			if attack_control then
				attack_control = (self.handler == nil or not IsPaused())
					and ((self:IsControlPressed(CONTROL_ATTACK) and CONTROL_ATTACK) or
						(self:IsControlPressed(CONTROL_PRIMARY) and CONTROL_PRIMARY) or
						(self:IsControlPressed(CONTROL_CONTROLLER_ATTACK) and not self:IsAOETargeting() and CONTROL_CONTROLLER_ATTACK))
					or nil
				if attack_control ~= nil then
					if retarget and not IsEntityDead(retarget) and CanEntitySeeTarget(self.inst, retarget) then
						--Handle chain attacking
						if self.inst.sg ~= nil then
							if self.handler == nil then
								retarget = self:GetAttackTarget(false, retarget, retarget ~= currenttarget)
								if retarget ~= nil then
									self.locomotor:PushAction(BufferedAction(self.inst, retarget, ACTIONS.ATTACK), true)
								end
							elseif attack_control ~= CONTROL_CONTROLLER_ATTACK then
								self:DoAttackButton(retarget)
							else
								self:DoControllerAttackButton(retarget)
							end
						end
					elseif attack_control ~= CONTROL_PRIMARY and self.handler ~= nil then
						--Check for starting a new attack
						local isidle
						if self.inst.sg ~= nil then
							isidle = self.inst.sg:HasStateTag("idle") or (self.inst:HasTag("idle") and self.inst:HasTag("nopredict"))
						else
							isidle = self.inst:HasTag("idle")
						end
						if isidle then
							self:OnControl(attack_control, true)
						end
					end
				end
			end
		end

		if self.handler ~= nil and TheInput:TryRecacheController() then
			--Could also push pause screen, but it won't come up right
			--away if controls were disabled at the time of the switch
			TheWorld:PushEvent("continuefrompause")
			TheInput:EnableMouse(not TheInput:ControllerAttached())
		end
	end

	self.OnUpdate = function (self, dt, ...)
		if TheInput:ControllerAttached() then
			return OnUpdate_New(self, dt, ...)
		else
			return OnUpdate_Old(self, dt, ...)
		end
	end
end)