local G = GLOBAL
-- local TARGET_EXCLUDE_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO" }
-- local ATTACK_TARGET_EXCLUDE_TAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "companion" }


-- local misc_control = G["CONTROL_MENU_MISC_"..tostring(GetModConfigData("misc"))]
local misc_control = G["CONTROL_MENU_MISC_3"]

-- local hotkeys_enabled = GetModConfigData("item_hotkeys")
-- local combatmod_enabled = GetModConfigData("combatchange")

-- local function isLowPriorityAttackTarget(target)
-- 	return target:HasTag("wall") or target:HasTag("bird")
-- end
-- local function shouldCountRadiusInteractionTarget(target)
-- 	return target.prefab == "pigman" or target.prefab == "birdcage" or target:HasTag("fishable")
-- end
AddComponentPostInit("playercontroller", function(self)
	
	-- self.wortox_reticule_dist = 13
	-- self.controller_target_delay = 0
	-- self.enabled_override = true
	-- ---------------- garbage i hate this
	-- self.placer_parent = G.CreateEntity()
	-- self.placer_parent.entity:AddTransform() self.placer_parent:AddTag("FX") self.placer_parent:AddTag("CLASSIFIED") self.placer_parent.entity:SetCanSleep(false)
	-- self.placer_parent:DoPeriodicTask(0, function(inst)
	-- 	if G.ThePlayer ~= nil and inst.move then inst.Transform:SetPosition(G.ThePlayer.Transform:GetWorldPosition()) end
	-- end)
	-- ---------------------------------
	-- local enabled_old = self.IsEnabled
	-- self.IsEnabled = function(self, ...)
	-- 	if not self.enabled_override then return false end
	-- 	return enabled_old(self, ...)
	-- end
	-- local UpdateControllerAttackTarget = function(self)
	-- 	--local targ = self:GetAttackTarget(false, nil, false)
	-- 	--if targ == nil then
	-- 		--targ = self:GetAttackTarget(true, nil, false)
	-- 	--end
	-- 	--self.controller_attack_target = targ
		
	-- 	if self.controller_attack_target ~= nil
	-- 		and (not self.controller_attack_target:IsValid() or
	-- 			self.controller_attack_target:HasTag("INLIMBO") or
	-- 			self.controller_attack_target:HasTag("NOCLICK") or
	-- 			not G.CanEntitySeeTarget(self.inst, self.controller_attack_target)) then
	-- 		self.controller_attack_target = nil
	-- 	end
		
		
	-- 	local combat = self.inst.replica.combat
	-- 	if combat == nil then return end
		
	-- 	local playerpos = self.inst:GetPosition()
	-- 	local possibleTargets = G.TheSim:FindEntities(playerpos.x, playerpos.y, playerpos.z, combat:GetAttackRangeWithWeapon()+6, { "_combat" }, TARGET_EXCLUDE_TAGS)
	-- 	-- sort by ascending distance
	-- 	local dists = {}
	-- 	table.sort(possibleTargets, function(a, b)
	-- 		if dists[a] == nil then
	-- 			dists[a] = a:GetDistanceSqToInst(G.ThePlayer)-(a:GetPhysicsRadius(0)/2)
	-- 		end
	-- 		if dists[b] == nil then
	-- 			dists[b] = b:GetDistanceSqToInst(G.ThePlayer)-(b:GetPhysicsRadius(0)/2)
	-- 		end
	-- 		return dists[a]<dists[b]
	-- 	end)
		
	-- 	local is_mod_pressed = G.TheInput:IsControlPressed(misc_control)
	-- 	if is_mod_pressed then
	-- 		for k, v in pairs(possibleTargets) do
	-- 			if combat:CanTarget(v) then
	-- 				self.controller_attack_target = v
	-- 				return
	-- 			end
	-- 		end
	-- 		return nil --we aren't getting anything after this if this fails, haha
	-- 	end
	-- 	for k, v in pairs(possibleTargets) do
	-- 		if not combat:IsAlly(v) and combat:CanTarget(v) and not isLowPriorityAttackTarget(v) then
	-- 			self.controller_attack_target = v
	-- 			return
	-- 		end
	-- 	end
	-- 	for k, v in pairs(possibleTargets) do
	-- 		if not combat:IsAlly(v) and combat:CanTarget(v) then
	-- 			self.controller_attack_target = v
	-- 			return
	-- 		end
	-- 	end
		
	-- 	self.controller_attack_target = nil
		
	-- end
	-- local UpdateControllerInteractionTarget = function(self, dt)
	-- 	if self.placer ~= nil or (self.deployplacer ~= nil and self.deploy_mode) then
	-- 		self.controller_target = nil
	-- 		self.controller_target_delay = 0.5
	-- 		return
	-- 	elseif self.controller_target ~= nil
	-- 		and (not self.controller_target:IsValid() or
	-- 			self.controller_target:HasTag("INLIMBO") or
	-- 			self.controller_target:HasTag("NOCLICK") or
	-- 			not G.CanEntitySeeTarget(self.inst, self.controller_target)) then
	-- 		self.controller_target = nil
	-- 	end
	-- 	if self.inst:HasTag("fishing") then return end
	-- 	if self.controller_target_delay > 0 then
	-- 		self.controller_target_delay = self.controller_target_delay - dt
	-- 		return
	-- 	end
	
	-- 	local playerpos = self.inst:GetPosition()
	-- 	local possibleTargets = G.TheSim:FindEntities(playerpos.x, playerpos.y, playerpos.z, 8, nil, TARGET_EXCLUDE_TAGS)
	-- 	--sort by ascending distance
	-- 	local dists = {}
	-- 	table.sort(possibleTargets, function(a, b)
	-- 		if dists[a] == nil then
	-- 			dists[a] = a:GetDistanceSqToInst(G.ThePlayer) or math.huge
	-- 			if shouldCountRadiusInteractionTarget(a) then
	-- 				dists[a] = dists[a] - a:GetPhysicsRadius(0)
	-- 			end
	-- 		end
	-- 		if dists[b] == nil then
	-- 			dists[b] = b:GetDistanceSqToInst(G.ThePlayer) or math.huge
	-- 			if shouldCountRadiusInteractionTarget(b) then
	-- 				dists[b] = dists[b] - b:GetPhysicsRadius(0)
	-- 			end
	-- 		end
	-- 		return dists[a]<dists[b]
	-- 	end)
	-- 	local inv_obj = self:GetCursorInventoryObject()
	-- 	for k, v in pairs(possibleTargets) do --look for valid action ents first
	-- 		local lmb, rmb = self:GetSceneItemControllerAction(v)
	-- 		if (v ~= self.inst) and (lmb ~= nil or rmb ~= nil or (inv_obj ~= nil and self:GetItemUseAction(inv_obj, v) ~= nil) or (v:HasTag("_writeable"))) and G.CanEntitySeeTarget(self.inst, v) then
	-- 			self.controller_target = v 
	-- 			return
	-- 		end
	-- 	end
	-- 	-- use attack target if former is not available
	-- 	if self.controller_attack_target ~= nil then self.controller_target = self.controller_attack_target	return end
	-- 	-- bleh whatever just use anything
	-- 	for k, v in pairs(possibleTargets) do
	-- 		local lmb, rmb = self:GetSceneItemControllerAction(v)
	-- 		if (v ~= self.inst) and G.CanEntitySeeTarget(self.inst, v) and v:HasTag("inspectable") then
	-- 			self.controller_target = v 
	-- 			return
	-- 		end
	-- 	end
	-- 	-- if there's literally nothing nearby then have nothing selected
	-- 	if self.controller_target ~= nil and self.controller_target:IsValid() and self.controller_target:GetDistanceSqToInst(self.inst) > 8*8 then
	-- 		self.controller_target = nil
	-- 	end
	-- end
	
	-- local updatetargs_old = self.UpdateControllerTargets
	-- self.UpdateControllerTargets = function(self, dt, ...)
	-- 	if self:IsAOETargeting() then
	-- 		self.controller_target = nil
	-- 		self.controller_target_age = 0
	-- 		self.controller_attack_target = nil
	-- 		self.controller_attack_target_ally_cd = nil
	-- 		self.controller_targeting_lock_target = nil
	-- 		return
	-- 	end
	-- 	if combatmod_enabled then
	-- 		UpdateControllerAttackTarget(self)
	-- 	else
	-- 		updatetargs_old(self, dt, ...)
	-- 	end
	-- 	UpdateControllerInteractionTarget(self, dt)
	-- end
	
	-- Zoom In and Zoom Out to look cloud
	local rotleft_old = self.RotLeft
	self.RotLeft = function(...)
		if G.TheInput:IsControlPressed(misc_control) then
			G.TheCamera:ZoomOut() G.TheCamera:ZoomOut()
		else
			rotleft_old(...)
		end
	end
	
	local rotright_old = self.RotRight
	self.RotRight = function(...)
		if G.TheInput:IsControlPressed(misc_control) then
			G.TheCamera:ZoomIn() G.TheCamera:ZoomIn()
		else
			rotright_old(...)
		end
	end
	
	--i hate placers
	-- local StartBuildPlacementMode_old = self.StartBuildPlacementMode
	-- self.StartBuildPlacementMode = function(...)
	-- 	StartBuildPlacementMode_old(...)
	-- 	if G.TheInput:ControllerAttached() and GetModConfigData("placer_enabled") then
	-- 		self.placer_parent:AddChild(self.placer)
	-- 		self.placer.Transform:SetPosition(0,0,0)
	-- 	end
	-- end
	
	-- refuel--------------------------------------------------------------------------------------------------------------------
	-- function self:RefuelEquippedItem(slot)
	-- 	local item = self.inst.replica.inventory:GetEquippedItem(slot)
	-- 	if item == nil then return end --stop if no equipped item
	-- 	local fueltype = nil
	-- 	for k, v in pairs(G.FUELTYPE) do
	-- 		if item:HasTag(v.."_fueled") then
	-- 			fueltype = v
	-- 		end
	-- 	end
	-- 	if fueltype == nil then return end --stop if item takes no fuel
	-- 	local items = self.inst.replica.inventory:GetItems()
	-- 	local backpack_items = {}
	-- 	local backpack = self.inst.replica.inventory:GetEquippedItem(G.EQUIPSLOTS.BODY)
	-- 	if backpack ~= nil and backpack.replica.container then
	-- 		backpack_items = backpack.replica.container:GetItems()
	-- 	end
	-- 	local function tryRefuel(itemlist)
	-- 		for k, v in pairs(itemlist) do
	-- 			if v:IsValid() and v:HasTag(fueltype.."_fuel") then
	-- 				self.inst.replica.inventory:ControllerUseItemOnItemFromInvTile(item, v)
	-- 				return false -- true if failed
	-- 			end
	-- 		end
	-- 		return true
	-- 	end
	-- 	if tryRefuel(items) then tryRefuel(backpack_items) end
	-- end
end)

-- AddComponentPostInit("placer", function(self)
-- 	self.controller_offset = G.Vector3()
-- 	self.speed_mult = 0.05
-- 	local acceleration = 0.75--not actually acceleration
-- 	self.meters_move_time = 0
-- 	local OnUpdate_old = self.OnUpdate
-- 	self.OnUpdate = function(self, dt, ...)
-- 		if self.onground or self.snap_to_meters then
-- 			local pos = G.ThePlayer:GetPosition() - G.Vector3(G.ThePlayer.entity:LocalToWorldSpace(1, 0, 0)) + self.controller_offset
-- 			if self.snap_to_meters then
-- 				pos.x = math.floor(pos.x) 
-- 				pos.z = math.floor(pos.z) 
-- 			end
-- 			G.ThePlayer.components.playercontroller.placer_parent.move = false
-- 			G.ThePlayer.components.playercontroller.placer_parent.Transform:SetPosition(pos:Get())
-- 		else
-- 			G.ThePlayer.components.playercontroller.placer_parent.move = true
-- 		end
-- 		if not (self.snap_to_tile) and G.TheInput:ControllerAttached() and GetModConfigData("placer_enabled") and G.ThePlayer then
-- 			local xdir = G.TheInput:GetAnalogControlValue(G.CONTROL_INVENTORY_RIGHT) - G.TheInput:GetAnalogControlValue(G.CONTROL_INVENTORY_LEFT)
-- 			local ydir = G.TheInput:GetAnalogControlValue(G.CONTROL_INVENTORY_UP) - G.TheInput:GetAnalogControlValue(G.CONTROL_INVENTORY_DOWN)
-- 			local deadzone = 0.3
-- 			if math.abs(xdir) > deadzone or math.abs(ydir) > deadzone then
-- 				local offset = self.controller_offset

-- 				--offset.x = offset.x + xdir*0.1
-- 				--offset.z = offset.z + ydir*0.1
-- 				local dir = (G.TheCamera:GetRightVec() * xdir - G.TheCamera:GetDownVec() * ydir) * self.speed_mult
-- 				--dir = dir:GetNormalized()
-- 				if not self.snap_to_meters then
-- 					self.controller_offset = offset+dir
-- 				elseif G.GetTime() - self.meters_move_time > 0.1 then
-- 					dir = dir:GetNormalized()
-- 					if math.abs(dir.x) > math.abs(dir.z) then
-- 						self.controller_offset.x = self.controller_offset.x + dir.x
-- 					else
-- 						self.controller_offset.z = self.controller_offset.z + dir.z
-- 					end
-- 					self.meters_move_time = G.GetTime()
-- 				end
-- 				if self.speed_mult > 1 then 
-- 					self.speed_mult = 1 
-- 				else
-- 					self.speed_mult = self.speed_mult + (self.speed_mult*acceleration*dt)
-- 				end
-- 			else -- reset speed
-- 				self.speed_mult = 0.05
-- 			end
-- 			if self.inst.parent ~= G.ThePlayer.components.playercontroller.placer_parent then 
-- 				G.ThePlayer.components.playercontroller.placer_parent:AddChild(self.inst)
-- 			end
-- 			if self.onground or self.snap_to_meters then
-- 				--self.inst.Transform:SetPosition((self.inst:GetPosition()+self.controller_offset):Get())
-- 			else
-- 				self.inst.Transform:SetPosition(self.controller_offset:Get())
-- 			end
-- 		end
-- 		OnUpdate_old(self, dt, ...)
-- 	end
-- end)

-- AddClassPostConstruct("screens/playerhud", function(self)
-- 	self.alt_widget_select = false
-- 	local GetFirstOpenContainerWidget_old = self.GetFirstOpenContainerWidget
-- 	self.GetFirstOpenContainerWidget = function(self, ...)
-- 		local result = GetFirstOpenContainerWidget_old(self, ...)
-- 		if self.alt_widget_select then
-- 			for k, v in pairs(self.controls.containers) do
-- 				if v ~= result then
-- 					return v
-- 				end
-- 			end
-- 		end
-- 		return result
-- 	end
	
-- 	function self:GetCrockpotIfOpen()
-- 		for k, v in pairs(self.controls.containers) do
-- 			if k and k:IsValid() and 
-- 			(k.prefab == "cookpot" or k.prefab == "portablecookpot" or k.prefab == "portablespicer") then
-- 				return k
-- 			end
-- 		end
-- 		return nil
-- 	end
	
-- 	function self:DoContainerButtons()
-- 		for k, v in pairs(self.controls.containers) do
-- 			if k and k:IsValid() and k.replica.container then
-- 				local widgetinfo = k.replica.container:GetWidget()
-- 				if widgetinfo and widgetinfo.buttoninfo and widgetinfo.buttoninfo.fn ~= nil 
-- 				and (widgetinfo.buttoninfo.validfn == nil or widgetinfo.buttoninfo.validfn(k, G.ThePlayer)) then
-- 					widgetinfo.buttoninfo.fn(k, G.ThePlayer)
-- 				end
-- 			end
-- 		end
-- 	end
-- end)

-- local function GetHotkeyNumber(control)
-- 	if control == G.CONTROL_INVENTORY_EXAMINE then
-- 		return 1
-- 	elseif control == G.CONTROL_INVENTORY_USEONSELF then
-- 		return 2
-- 	elseif control == G.CONTROL_INVENTORY_USEONSCENE then
-- 		return 3
-- 	elseif control == G.CONTROL_INVENTORY_DROP then
-- 		return 4
-- 	else
-- 		return nil
-- 	end
-- end
-- AddClassPostConstruct("widgets/inventorybar", function(self)
-- 	self.controller_trade_button_pressed = false
-- 	function self:SwitchFocusWidgets()
-- 		if self.open then
-- 			local old_widget = self.owner.HUD:GetFirstOpenContainerWidget()
-- 			if old_widget then
-- 				old_widget:ScaleTo(self.selected_scale, self.base_scale, .1)
-- 			end
-- 		end
-- 		self.owner.HUD.alt_widget_select = not self.owner.HUD.alt_widget_select
-- 		if self.open then
-- 			local new_widget = self.owner.HUD:GetFirstOpenContainerWidget()
-- 			if new_widget then
-- 				new_widget:ScaleTo(self.base_scale, self.selected_scale, .1)
-- 				local midslot = math.ceil(#new_widget.inv/2)
-- 				self:SelectSlot(new_widget.inv[midslot])
-- 			end
-- 		end
-- 	end
-- 	function self:TradeActiveSlot()
-- 		if self.open and self.active_slot ~= nil then
-- 			self.active_slot:TradeItem(G.TheInput:IsControlPressed(G.CONTROL_PUTSTACK))
-- 		end
-- 	end
-- 	self.hotkeys = {}
-- 	function self:SetHotkeyPrefab(keynum, prefab)
-- 		self.hotkeys[keynum] = prefab
-- 	end
-- 	function self:GetHotkeyPrefab(keynum)
-- 		return self.hotkeys[keynum]
-- 	end
-- 	local OnControl_old = self.OnControl
-- 	self.OnControl = function(self, control, down, ...)
-- 		if down and control == misc_control then
-- 			self:SwitchFocusWidgets()
-- 		end
-- 		if control == G.CONTROL_SCROLLBACK then
-- 			if down and not self.controller_trade_button_pressed then
-- 				self.controller_trade_button_pressed = true
-- 				self:TradeActiveSlot()
-- 			elseif not down then
-- 				self.controller_trade_button_pressed = false
-- 			end
-- 		end
-- 		return OnControl_old(self, control, down, ...)
-- 	end
-- end)

-- local function NoHoles(pt)
--     return not G.TheWorld.Map:IsGroundTargetBlocked(pt)
-- end
-- local function Wortox_ReticuleTargetFn(inst)
--     local rotation = inst.Transform:GetRotation() * G.DEGREES
--     local pos = inst:GetPosition()
--     pos.y = 0
-- 	local radd = inst.components.playercontroller.wortox_reticule_dist
--     for r = radd, 1.5, -.5 do
--         local offset = G.FindWalkableOffset(pos, rotation, r, 1, false, true, NoHoles)
--         if offset ~= nil then
--             pos.x = pos.x + offset.x
--             pos.z = pos.z + offset.z
--             return pos
--         end
--     end
--     for r = radd+.5, 36, .5 do
--         local offset = G.FindWalkableOffset(pos, rotation, r, 1, false, true, NoHoles)
--         if offset ~= nil then
--             pos.x = pos.x + offset.x
--             pos.z = pos.z + offset.z
--             return pos
--         end
--     end
--     pos.x = pos.x + math.cos(rotation) * radd
--     pos.z = pos.z - math.sin(rotation) * radd
--     return pos
-- end

-- local input = G.getmetatable(G.TheInput).__index
-- local oncontrol_old = input.OnControl
-- local iscontrolpressed_old = input.IsControlPressed
-- local controller_mod_controls = {
-- 	[46] = function()
-- 		local ctrler = G.ThePlayer and G.ThePlayer.components.playercontroller or nil
-- 		if ctrler ~= nil then
-- 			ctrler.wortox_reticule_dist = math.clamp(ctrler.wortox_reticule_dist + 1, 2, 35)
-- 		end
-- 	end,
-- 	[45] = function()
-- 		local ctrler = G.ThePlayer and G.ThePlayer.components.playercontroller or nil
-- 		if ctrler ~= nil then
-- 			ctrler.wortox_reticule_dist = math.clamp(ctrler.wortox_reticule_dist - 1, 2, 36)
-- 		end
-- 	end,
-- 	[G.CONTROL_CONTROLLER_ALTACTION] = function() -- i have to do this here because for whatever reason the regular action won't work with movepred off
-- 		local locomotor = G.ThePlayer and G.ThePlayer.components.locomotor or nil
-- 		local pt = Wortox_ReticuleTargetFn(G.ThePlayer)
-- 		if locomotor ~= nil then
-- 			locomotor:GoToPoint(pt)
-- 		else
-- 			G.SendRPCToServer(G.RPC.LeftClick, G.ACTIONS.WALKTO.code, pt.x, pt.z)
-- 		end
-- 		G.ThePlayer.components.playercontroller.enabled_override = false
-- 		G.ThePlayer:DoTaskInTime(0.5, function(p)
-- 			p.components.playercontroller.enabled_override = true
-- 		end)
-- 	end,
-- }
-- refuel --------------------------------------------------------------------------------------------------------------------------
-- if GetModConfigData("refuel_hotkeys") then
-- 	controller_mod_controls[G.CONTROL_CONTROLLER_ATTACK] = function(down)
-- 		if G.ThePlayer then
-- 			G.ThePlayer.components.playercontroller:RefuelEquippedItem(G.EQUIPSLOTS.HANDS)
-- 		end
-- 	end
-- 	controller_mod_controls[G.CONTROL_CONTROLLER_ACTION] = function(down)
-- 		if G.ThePlayer then
-- 			G.ThePlayer.components.playercontroller:RefuelEquippedItem(G.EQUIPSLOTS.BODY)
-- 		end
-- 	end
-- 	controller_mod_controls[G.CONTROL_INSPECT] = function(down)
-- 		if G.ThePlayer then
-- 			G.ThePlayer.components.playercontroller:RefuelEquippedItem(G.EQUIPSLOTS.HEAD)
-- 		end
-- 	end
-- end----------------------------------------------------------------------------------------------------------------------------------
-- local function isInventoryControl(ctrl)
-- 	return ctrl == G.CONTROL_INVENTORY_LEFT or ctrl == G.CONTROL_INVENTORY_RIGHT or ctrl == G.CONTROL_INVENTORY_UP or ctrl == G.CONTROL_INVENTORY_DOWN
-- end
-- input.IsControlPressed = function(self, control, e, ...)
-- 	if e then --not efficient, i know.
-- 		return iscontrolpressed_old(self, control, e, ...)
-- 	end
-- 	local ctrler = G.ThePlayer and G.ThePlayer.components.playercontroller or nil
-- 	if isInventoryControl(control) and ctrler and (ctrler.placer or (ctrler.deploy_mode and ctrler.deployplacer)) then
-- 		return false
-- 	elseif iscontrolpressed_old(self, misc_control) and (control == G.CONTROL_CONTROLLER_ATTACK or control == G.CONTROL_CONTROLLER_ACTION) then
-- 		return false
-- 	else
-- 		return iscontrolpressed_old(self, control, e, ...)
-- 	end
-- end
-- input.OnControl = function(self, control, down, ...)
-- 	--70 is the mod (menu misc 3)
-- 	local ctrler = G.ThePlayer and G.ThePlayer.components.playercontroller or nil
-- 	local player = G.ThePlayer
-- 	if self:IsControlPressed(misc_control) and controller_mod_controls[control] ~= nil then
-- 		controller_mod_controls[control](down)
-- 	elseif ctrler and ctrler.placer and isInventoryControl(control) then
-- 		--do i want to put this code here or make it its own function?
-- 		--edit: decided it's going to OnUpdate. hooray for more _old functions!
-- 	elseif player ~= nil and control == G.CONTROL_PAUSE and player.HUD.controls.inv.open then
-- 		-- player.HUD.controls.inv.open and player.HUD:GetCrockpotIfOpen() ~= nil then
-- 		-- local inst = player.HUD:GetCrockpotIfOpen()
-- 		-- if inst.components.container ~= nil then
-- 			-- G.BufferedAction(inst.components.container.opener, inst, G.ACTIONS.COOK):Do()
-- 		-- elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
-- 			-- G.SendRPCToServer(G.RPC.DoWidgetButtonAction, G.ACTIONS.COOK.code, inst, G.ACTIONS.COOK.mod_name)
-- 		-- end
-- 		player.HUD:DoContainerButtons()
-- 	elseif hotkeys_enabled and control == G.CONTROL_SCROLLFWD and G.TheInput:IsControlPressed(G.CONTROL_MENU_MISC_4) then
-- 	elseif hotkeys_enabled and GetHotkeyNumber(control) ~= nil and G.TheInput:IsControlPressed(G.CONTROL_MENU_MISC_4) then
-- 		local keynum = GetHotkeyNumber(control)
-- 		local inv = G.ThePlayer.HUD.controls.inv
-- 		if G.TheInput:IsControlPressed(G.CONTROL_SCROLLFWD) then
-- 			--set item
-- 			local container = inv.active_slot.container
-- 			local item = container ~= nil and container:GetItemInSlot(inv.active_slot.num) or nil
-- 			if item ~= nil then
-- 				inv:SetHotkeyPrefab(keynum, item.prefab)
-- 			end
-- 		else
-- 			--look for item
-- 			local prefab = inv:GetHotkeyPrefab(keynum)
-- 			if prefab == nil then return end
-- 			local items = {}
-- 			local slots = {}
-- 			local function checklist(list)
-- 				for k, v in pairs(list) do
-- 					local container = v.container
-- 					local item = container ~= nil and container:GetItemInSlot(v.num) or nil
-- 					if item ~= nil and item.prefab == prefab then 
-- 						table.insert(items, item)
-- 						table.insert(slots, v)
-- 					end
-- 				end
-- 				if slots[1] ~= nil then
-- 					inv:SelectSlot(slots[1])
-- 					return true
-- 				end
-- 				return false
-- 			end
-- 			if not checklist(inv.inv) then
-- 				for slot, v in pairs(inv.equip) do
-- 					local item = G.ThePlayer.replica.inventory:GetEquippedItem(slot)
-- 					if item ~= nil and item.prefab == prefab then
-- 						inv:SelectSlot(v)
-- 						return
-- 					end
-- 				end
-- 				checklist(inv.backpackinv)
-- 			end
-- 		end
-- 	else
-- 		oncontrol_old(self, control, down, ...)
-- 	end
-- end
-- AddPlayerPostInit(function(inst)

-- 	local function OnSetOwner(inst)
-- 		if inst.components.playeractionpicker ~= nil then
-- 			local fn_old = inst.components.playeractionpicker.pointspecialactionsfn
-- 			local function GetPointSpecialActions(inst, pos, useitem, right)
-- 				if right and (G.ThePlayer ~= nil and G.TheInput:IsControlPressed(misc_control)) then
-- 					local act = G.ACTIONS.WALKTO
-- 					return { act }
-- 				end
-- 				return fn_old ~= nil and fn_old(inst, pos, useitem, right) or {}
-- 			end
-- 			inst.components.playeractionpicker.pointspecialactionsfn = GetPointSpecialActions
-- 		end
-- 	end
-- 	inst:ListenForEvent("setowner", OnSetOwner)
-- 	if inst.components.reticule == nil then
-- 		inst:AddComponent("reticule")
-- 		inst.components.reticule.ease = true
-- 	end
-- 	inst.components.reticule.targetfn = Wortox_ReticuleTargetFn
-- end)
