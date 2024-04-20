
AddComponentPostInit("playercontroller", function(self)
	-- Achieve ZoomIn and ZoomOut ------------------------------------------------------------------------

	self.change_IsControllerLeftShoulderDown = function(self)
		return self.change_controller_left_shoulder_down
	end

	self.change_ControllerLeftShoulderHold = function(self, enable)
		self.change_ControllerLeftShoulderHeld = enable
	end

	local OnControl_Old = self.OnControl
	self.OnControl = function(self, control, down, ...)
		if control == CONTROL_MAP then
			self.change_controller_left_shoulder_down = down
			if down then
				self.change_controller_left_shoulder_hold_timer = 0.0
			else
				self.change_controller_left_shoulder_hold_timer = nil
			end
		end
		return OnControl_Old(self, control, down, ...)
	end


	local OnUpdate_Old = self.OnUpdate
	self.OnUpdate = function(self, dt, ...)
		if self:change_IsControllerLeftShoulderDown() and self.change_controller_left_shoulder_hold_timer then
			self.change_controller_left_shoulder_hold_timer = self.change_controller_left_shoulder_hold_timer + dt
			if CHANGE_CONTROLLER_LEFT_SHOULDER_HOLD_TIME < self.change_controller_left_shoulder_hold_timer then
				self:change_ControllerLeftShoulderHold(true)
				print("change's Controller left shoulder holding...")
				self.change_controller_left_shoulder_hold_timer = nil
			end
		end
		return OnUpdate_Old(self, dt, ...)
	end

	-- Used for achieving target locking as quickly as possible --------------------------------------------
	-- local IsControllerTargetingModifierDown_Old = self.IsControllerTargetingModifierDown
	-- self.IsControllerTargetingModifierDown = function(...)
	-- 	if self.controller_targeting_lock_timer ~= 0.0 then
	-- 		self.controller_targeting_lock_timer = 1.0
	-- 	end
	-- 	return IsControllerTargetingModifierDown_Old(...)
	-- end

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