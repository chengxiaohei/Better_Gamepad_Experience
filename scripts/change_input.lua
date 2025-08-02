local RemapTo_CONTROL_INVENTORY =
{
	[0] = CONTROL_INVENTORY_UP,
	[1] = CONTROL_INVENTORY_DOWN,
	[2] = CONTROL_INVENTORY_LEFT,
	[3] = CONTROL_INVENTORY_RIGHT,
}

local RemapTo_CONTROL_INVENTORY_ACTIONS =
{
	[0] = CONTROL_INVENTORY_EXAMINE,
	[1] = CONTROL_INVENTORY_DROP,
	[2] = CONTROL_INVENTORY_USEONSCENE,
	[3] = CONTROL_INVENTORY_USEONSELF,
}

local function IsVCtrlCamera(control)	return control >= VIRTUAL_CONTROL_CAMERA_ZOOM_IN	and control <= VIRTUAL_CONTROL_CAMERA_ROTATE_RIGHT	end
local function IsVCtrlAiming(control)	return control >= VIRTUAL_CONTROL_AIM_UP			and control <= VIRTUAL_CONTROL_AIM_RIGHT			end
local function IsVCtrlInvNav(control)	return control >= VIRTUAL_CONTROL_INV_UP			and control <= VIRTUAL_CONTROL_INV_RIGHT			end
local function IsVCtrlInvAct(control)	return control >= VIRTUAL_CONTROL_INV_ACTION_UP		and control <= VIRTUAL_CONTROL_INV_ACTION_RIGHT		end
local function IsVCtrlStrafe(control)	return control >= VIRTUAL_CONTROL_STRAFE_UP			and control <= VIRTUAL_CONTROL_STRAFE_RIGHT			end

local function IsCamAndInvCtrlScheme1(scheme) return scheme < 2 or scheme > 7 end

local function IsTwinStickAiming(player, scheme)
	if player.components.playercontroller and player.components.playercontroller:IsTwinStickAiming() then
		if scheme < 4 or scheme > 7 then
			return player.components.playercontroller:IsAOETargeting()
		end
		return true
	end
	return false
end

local function IsStrafing(player)
	return player.components.strafer and player.components.strafer:IsAiming()
end

Input.ResolveVirtualControls__ = function (self, control, ...)
	if control == nil then
		return
	elseif control < VIRTUAL_CONTROL_START then
		if control == CONTROL_CAM_AND_INV_MODIFIER then
			--Modifier button is not used in control scheme 1
			local scheme = self:GetActiveControlScheme(CONTROL_SCHEME_CAM_AND_INV)
			return not IsCamAndInvCtrlScheme1(scheme) and control or nil
		end
		return control
	end

	local player = ThePlayer
	if player and player.HUD and player.HUD:IsSpellWheelOpen() then
		--Spell wheel is treated as "ishudblocking" in playercontroller,
		--which allows some controls to continue working, but we do want
		--to block all virtual directional controls instead.
		return
	end

	local scheme = self:GetActiveControlScheme(CONTROL_SCHEME_CAM_AND_INV)

	--Scheme 1 is classic style, where we have no modifier button, and everyhting is remappable.
	if IsCamAndInvCtrlScheme1(scheme) then
		if IsVCtrlInvNav(control) then
			--Handle CONTROL_INVENTORY priorities
			if player and not (player.HUD and player.HUD:IsCraftingOpen()) then
				if IsTwinStickAiming(player, scheme) or IsStrafing(player) then
					return
				end
			end
			-- =================================================================================================================== --
            if player and player.components.playercontroller and player.components.playercontroller.reticule ~= nil and
				TheSim:GetDigitalControl(CHANGE_CONTROL_RIGHT) then
                return
            end
			-- =================================================================================================================== --
			return RemapTo_CONTROL_INVENTORY[control - VIRTUAL_CONTROL_INV_UP]
		elseif IsVCtrlInvAct(control) then
			return RemapTo_CONTROL_INVENTORY_ACTIONS[control - VIRTUAL_CONTROL_INV_ACTION_UP]
		elseif IsVCtrlAiming(control) then
			-- =================================================================================================================== --
			-- --Twin stick aiming outside of AOE targeting is only supported by schemes 4 to 7
			-- if not (player and player.components.playercontroller and player.components.playercontroller:IsAOETargeting()) then
			-- 	return
			-- end
			-- =================================================================================================================== --
			--Handle CONTROL_INVENTORY priorities
			if player and player.HUD and player.HUD:IsCraftingOpen() then
				return
			end
			return RemapTo_CONTROL_INVENTORY[control - VIRTUAL_CONTROL_AIM_UP]
		elseif IsVCtrlStrafe(control) then
			--Handle CONTROL_INVENTORY priorities
			if player and player.HUD and player.HUD:IsCraftingOpen() then
				return
			end
			return RemapTo_CONTROL_INVENTORY[control - VIRTUAL_CONTROL_STRAFE_UP]
		end
		return
	end

	--Now handle all the new schemes (2 to 7) for each control category

	if IsVCtrlCamera(control) then
		--R.Stick for all schemes, modifier button for even number schemes
		local ismodified = TheSim:GetDigitalControl(CONTROL_CAM_AND_INV_MODIFIER)
		local needsmodifier = bit.band(scheme, 1) == 0
		if ismodified ~= needsmodifier then
			return
		end
		--Handle unmodified R.Stick priorities
		if not needsmodifier and player then
			if scheme ~= 5 and scheme ~= 7 and IsTwinStickAiming(player, scheme) or IsStrafing(player) then
				return
			end
		end
		-- =================================================================================================================== --
		if player and player.components.playercontroller and player.components.playercontroller.reticule ~= nil and
			TheSim:GetDigitalControl(CHANGE_CONTROL_RIGHT) then
			return
		end
		-- =================================================================================================================== --
		return control - VIRTUAL_CONTROL_CAMERA_ZOOM_IN + CONTROL_PRESET_RSTICK_UP
	elseif IsVCtrlInvNav(control) then
		--R.Stick for 2 and 3, DPad for 4 to 7, modifier button for 3 to 5
		if scheme <= 3 and player.HUD and player.HUD:IsControllerInventoryOpen() then
			--In controller inventory screen, we can ignore R.stick modifier
			return control - VIRTUAL_CONTROL_INV_UP + CONTROL_PRESET_RSTICK_UP
		end
		local ismodified = TheSim:GetDigitalControl(CONTROL_CAM_AND_INV_MODIFIER)
		local needsmodifier = scheme >= 3 and scheme <= 5
		if ismodified ~= needsmodifier then
			return
		elseif scheme <= 3 then
			--Handle unmodified R.Stick priorities
			if not needsmodifier and player then
				if not (player.HUD and player.HUD:IsCraftingOpen()) then
					if IsTwinStickAiming(player, scheme) or IsStrafing(player) then
						return
					end
				end
			end
			-- =================================================================================================================== --
            if player and player.components.playercontroller and player.components.playercontroller.reticule ~= nil and
				TheSim:GetDigitalControl(CHANGE_CONTROL_RIGHT) then
                return
            end
			-- =================================================================================================================== --
			return control - VIRTUAL_CONTROL_INV_UP + CONTROL_PRESET_RSTICK_UP
		else
			return control - VIRTUAL_CONTROL_INV_UP + CONTROL_PRESET_DPAD_UP
		end
	elseif IsVCtrlInvAct(control) then
		--Classic mapping for 2 and 3, DPad for 4 to 7, modifier button for 6 and 7
		if scheme <= 3 then
			return RemapTo_CONTROL_INVENTORY_ACTIONS[control - VIRTUAL_CONTROL_INV_ACTION_UP]
		end
		local ismodified = TheSim:GetDigitalControl(CONTROL_CAM_AND_INV_MODIFIER)
		local needsmodifier = scheme == 6 or scheme == 7
		if ismodified ~= needsmodifier then
			return
		else
			return control - VIRTUAL_CONTROL_INV_ACTION_UP + CONTROL_PRESET_DPAD_UP
		end
	elseif IsVCtrlAiming(control) then
		--R.Stick for all schemes, modifier button for 5 and 7
		local ismodified = TheSim:GetDigitalControl(CONTROL_CAM_AND_INV_MODIFIER)
		local needsmodifier = scheme == 5 or scheme == 7
		if ismodified ~= needsmodifier then
			return
		end
		-- =================================================================================================================== --
		--Twin stick aiming outside of AOE targeting is only supported by schemes 4 to 7
		-- if scheme <= 3 and not (player and player.components.playercontroller and player.components.playercontroller:IsAOETargeting()) then
		-- 	return
		-- end
		-- =================================================================================================================== --
		--Handle unmodified R.Stick priorities
		if not needsmodifier and player then
			if scheme == 2 and player.HUD and player.HUD:IsCraftingOpen() then
				return
			end
		end
		return control - VIRTUAL_CONTROL_AIM_UP + CONTROL_PRESET_RSTICK_UP
	elseif IsVCtrlStrafe(control) then
		--Unmodified R.Stick for all schemes
		local ismodified = TheSim:GetDigitalControl(CONTROL_CAM_AND_INV_MODIFIER)
		local needsmodifier = false
		if ismodified ~= needsmodifier then
			return
		end
		--Handle unmodified R.Stick priorities
		if not needsmodifier and player then
			if scheme == 2 and player.HUD and player.HUD:IsCraftingOpen() then
				return
			end
		end
		return control - VIRTUAL_CONTROL_STRAFE_UP + CONTROL_PRESET_RSTICK_UP
	end
end

local ResolveVirtualControls_Old = Input.ResolveVirtualControls
-- Same as above ResolveVirtualControls__
Input.ResolveVirtualControls = function (self, control, ...)
	if control == nil then
		return
	elseif control < VIRTUAL_CONTROL_START then
		if control == CONTROL_CAM_AND_INV_MODIFIER then
			--Modifier button is not used in control scheme 1
			local scheme = self:GetActiveControlScheme(CONTROL_SCHEME_CAM_AND_INV)
			return not IsCamAndInvCtrlScheme1(scheme) and control or nil
		end
		return control
	end

	local player = ThePlayer
	if player and player.HUD and player.HUD:IsSpellWheelOpen() then
		--Spell wheel is treated as "ishudblocking" in playercontroller,
		--which allows some controls to continue working, but we do want
		--to block all virtual directional controls instead.
		return
	end

	local scheme = self:GetActiveControlScheme(CONTROL_SCHEME_CAM_AND_INV)

	local playercontroller_IsAOETargeting_Old
	if IsVCtrlAiming(control) then
		if player and player.components.playercontroller then
			playercontroller_IsAOETargeting_Old = player.components.playercontroller.IsAOETargeting
			player.components.playercontroller.IsAOETargeting = function (...) return true end
		end
	end

	local resolved_control = ResolveVirtualControls_Old(self, control, ...)
	
	if player and player.components.playercontroller then
		player.components.playercontroller.IsAOETargeting = playercontroller_IsAOETargeting_Old
	end

	if IsCamAndInvCtrlScheme1(scheme) then
		if IsVCtrlInvNav(control) then
			if resolved_control ~= nil then
				if player and player.components.playercontroller and player.components.playercontroller.reticule ~= nil and
					TheSim:GetDigitalControl(CHANGE_CONTROL_RIGHT) then
					return
				end
			end
		end
		return resolved_control
	end

	if IsVCtrlCamera(control) or IsVCtrlInvNav(control) then
		if resolved_control ~= nil then
			if player and player.components.playercontroller and player.components.playercontroller.reticule ~= nil and
				TheSim:GetDigitalControl(CHANGE_CONTROL_RIGHT) then
				return
			end
		end
	end
	return resolved_control
end

local function IsCamAndInvCtrlScheme123(scheme) return scheme < 4 or scheme > 7 end

local SupportsControllerFreeAiming_Old = Input.SupportsControllerFreeAiming
Input.SupportsControllerFreeAiming = function (self, ...)
	local scheme = self:GetActiveControlScheme(CONTROL_SCHEME_CAM_AND_INV)
	if IsCamAndInvCtrlScheme123(scheme) then
		return TheSim:GetDigitalControl(CHANGE_CONTROL_RIGHT)
	end
	return SupportsControllerFreeAiming_Old(self, ...)
end
