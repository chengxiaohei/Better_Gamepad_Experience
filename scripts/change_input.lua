local function IsVCtrlCamera(control)	return control >= VIRTUAL_CONTROL_CAMERA_ZOOM_IN	and control <= VIRTUAL_CONTROL_CAMERA_ROTATE_RIGHT	end
local function IsVCtrlAiming(control)	return control >= VIRTUAL_CONTROL_AIM_UP			and control <= VIRTUAL_CONTROL_AIM_RIGHT			end
local function IsVCtrlInvNav(control)	return control >= VIRTUAL_CONTROL_INV_UP			and control <= VIRTUAL_CONTROL_INV_RIGHT			end
local function IsVCtrlInvAct(control)	return control >= VIRTUAL_CONTROL_INV_ACTION_UP		and control <= VIRTUAL_CONTROL_INV_ACTION_RIGHT		end
local function IsVCtrlStrafe(control)	return control >= VIRTUAL_CONTROL_STRAFE_UP			and control <= VIRTUAL_CONTROL_STRAFE_RIGHT			end

local function IsCamAndInvCtrlScheme1(scheme) return scheme < 2 or scheme > 7 end
local function IsCamAndInvCtrlScheme123(scheme) return scheme < 4 or scheme > 7 end

local ResolveVirtualControls_Old = Input.ResolveVirtualControls

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

	-- Only support scheme123
	if not IsCamAndInvCtrlScheme123(scheme) then
		return
	end

	-- Scheme 1 is classic style, where we have no modifier button, and everyhting is remappable.
	if IsCamAndInvCtrlScheme1(scheme) then
		if IsVCtrlInvNav(control) then
            if player and player.components.playercontroller and player.components.playercontroller.reticule ~= nil and
				TheSim:GetDigitalControl(CHANGE_CONTROL_RIGHT) then
                return
            end
            return control - VIRTUAL_CONTROL_INV_UP + CONTROL_PRESET_RSTICK_UP 
		elseif IsVCtrlInvAct(control) then
            return control - VIRTUAL_CONTROL_INV_ACTION_UP + CONTROL_PRESET_DPAD_UP
		elseif IsVCtrlAiming(control) then
            if player and player.components.playercontroller and player.components.playercontroller.reticule == nil then
                return
            end
            if not TheSim:GetDigitalControl(CHANGE_CONTROL_RIGHT) then
                return
            end
            return control - VIRTUAL_CONTROL_AIM_UP + CONTROL_PRESET_RSTICK_UP
		elseif IsVCtrlStrafe(control) then
            return control - VIRTUAL_CONTROL_STRAFE_UP + CONTROL_PRESET_RSTICK_UP
		end
		return
	end

	-- now handle scheme 2 and scheme 3
	if IsVCtrlCamera(control) then
		--R.Stick for all schemes, modifier button for even number schemes
		local ismodified = TheSim:GetDigitalControl(CONTROL_CAM_AND_INV_MODIFIER)
		local needsmodifier = bit.band(scheme, 1) == 0
		if ismodified ~= needsmodifier then
			return
		end
		if player and player.components.playercontroller and player.components.playercontroller.reticule ~= nil and
			TheSim:GetDigitalControl(CHANGE_CONTROL_RIGHT) then
			return
		end
		return control - VIRTUAL_CONTROL_CAMERA_ZOOM_IN + CONTROL_PRESET_RSTICK_UP
	elseif IsVCtrlInvNav(control) then
		local ismodified = TheSim:GetDigitalControl(CONTROL_CAM_AND_INV_MODIFIER)
		local needsmodifier = scheme >= 3 and scheme <= 5
		if ismodified ~= needsmodifier then
			return
		end

		if player and player.components.playercontroller and player.components.playercontroller.reticule ~= nil and
			TheSim:GetDigitalControl(CHANGE_CONTROL_RIGHT) then
			return
		end
		return control - VIRTUAL_CONTROL_INV_UP + CONTROL_PRESET_RSTICK_UP
	elseif IsVCtrlInvAct(control) then
		return control - VIRTUAL_CONTROL_INV_ACTION_UP + CONTROL_PRESET_DPAD_UP
	elseif IsVCtrlAiming(control) then
		local ismodified = TheSim:GetDigitalControl(CONTROL_CAM_AND_INV_MODIFIER)
		local needsmodifier = scheme == 5 or scheme == 7
		if ismodified ~= needsmodifier then
			return
		end
		local isrightbumper = TheSim:GetDigitalControl(CHANGE_CONTROL_RIGHT)
		local needrightbumper = scheme <= 3
		if isrightbumper ~= needrightbumper then
			return
		end
		return control - VIRTUAL_CONTROL_AIM_UP + CONTROL_PRESET_RSTICK_UP
	end

	return ResolveVirtualControls_Old(self, control, ...)
end