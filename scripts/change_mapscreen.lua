AddClassPostConstruct("screens/mapscreen", function(self)
    local OnControl_Old = self.OnControl
    self.OnControl = function(self, control, down, ...)
        if TheInput:ControllerAttached() then
            if control == CONTROL_ROTATE_LEFT then
                control = CHANGE_IS_REVERSE_CAMERA_ROTATION and CONTROL_ROTATE_LEFT or CONTROL_ROTATE_RIGHT
            elseif control == CONTROL_ROTATE_RIGHT then
                control = CHANGE_IS_REVERSE_CAMERA_ROTATION and CONTROL_ROTATE_RIGHT or CONTROL_ROTATE_LEFT
            elseif control == CONTROL_INVENTORY_LEFT then
                control = CHANGE_IS_REVERSE_CAMERA_ROTATION and CONTROL_ROTATE_LEFT or CONTROL_ROTATE_RIGHT
            elseif control == CONTROL_INVENTORY_RIGHT then
                control = CHANGE_IS_REVERSE_CAMERA_ROTATION and CONTROL_ROTATE_RIGHT or CONTROL_ROTATE_LEFT
            end
        end
        return OnControl_Old(self, control, down, ...)
    end

    local ZOOM_CLAMP_MIN = 1
    local ZOOM_CLAMP_MAX = 20

    self.OnUpdate = function (self, dt, ...)
        if self._hack_ignore_held_controls then
            self._hack_ignore_held_controls = self._hack_ignore_held_controls - dt
            if self._hack_ignore_held_controls < 0 then
                self._hack_ignore_held_controls = nil
            end
        end
        local s = -100 * dt -- now per second, not per repeat

        -- NOTES(JBK): Controllers apply smooth analog input so use it for more precision with joysticks.
        local xdir = TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)
        local ydir = TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)
        local xmag = xdir * xdir + ydir * ydir
        local deadzone = TUNING.CONTROLLER_DEADZONE_RADIUS
        if xmag >= deadzone * deadzone then
            self.minimap:Offset(xdir * s, ydir * s)
            self.decorationdata.dirty = true
        end

        local zoom_in_key_pressed  = TheInput:IsControlPressed(CHANGE_IS_REVERSE_CAMERA_ZOOM and CONTROL_INVENTORY_DOWN or CONTROL_INVENTORY_UP)
        local zoom_out_key_pressed = TheInput:IsControlPressed(CHANGE_IS_REVERSE_CAMERA_ZOOM and CONTROL_INVENTORY_UP or CONTROL_INVENTORY_DOWN)

        -- NOTES(JBK): In order to change digital to analog without causing issues engine side with prior binds we emulate it.
        local indir = (zoom_in_key_pressed or TheInput:IsControlPressed(CONTROL_MAP_ZOOM_IN)) and -1 or 0
        local outdir = (zoom_out_key_pressed or TheInput:IsControlPressed(CONTROL_MAP_ZOOM_OUT)) and 1 or 0
        local inoutdir = indir + outdir
        local TIMETOZOOM = 0.1
        if inoutdir ~= 0 then
            self.zoom_target_time = TIMETOZOOM -- How much time remaining to get to the desired target.
            local exponential_factor = 1 / 60
            if not TheInput:ControllerAttached() then -- Controllers don't need this extra speed boosts with how digital inputs are handled.
                exponential_factor = exponential_factor * self.zoom_target
            end
            self.zoom_target = math.clamp(self.zoom_target + self.zoomsensitivity * inoutdir * exponential_factor, ZOOM_CLAMP_MIN, ZOOM_CLAMP_MAX)
            self.zoom_old = self.minimap:GetZoom()
        end
        if self.zoom_target_time > 0 then
            self.zoom_target_time = math.max(0, self.zoom_target_time - dt)
            local zoom_desired = Lerp(self.zoom_old, self.zoom_target, 1.0 - self.zoom_target_time / TIMETOZOOM)
            local zoom_delta = zoom_desired - self.minimap:GetZoom()
            if zoom_delta < 0 then
                self:DoZoomIn(zoom_delta)
            elseif zoom_delta > 0 then
                self:DoZoomOut(zoom_delta)
            end
        end

        local x, y, z = self:GetWorldPositionAtCursor()
        local aax, aay, aaz = self:AutoAimToStaticDecorations(x, y, z)
        local LMBaction, RMBaction = self:UpdateMapActions(aax, aay, aaz)
        self:UpdateMapActionsDecorations(x, y, z, LMBaction, RMBaction)
    end

    self.GetHelpText = function (self, ...)
        local controller_id = TheInput:GetControllerID()
        local t = {}
        
        local rotate_left_key  = CHANGE_IS_REVERSE_CAMERA_ROTATION and TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_RIGHT) or TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_LEFT)
        local rotate_right_key = CHANGE_IS_REVERSE_CAMERA_ROTATION and TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_LEFT) or TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_RIGHT)
        local zoom_in_key  = CHANGE_IS_REVERSE_CAMERA_ZOOM and TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DOWN) or TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_UP)
        local zoom_out_key = CHANGE_IS_REVERSE_CAMERA_ZOOM and TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_UP) or TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DOWN)

        table.insert(t,  rotate_left_key .. " / " .. TheInput:GetLocalizedControl(controller_id, CONTROL_ROTATE_RIGHT) .. " " .. STRINGS.UI.HELP.ROTATE_LEFT)
        table.insert(t,  rotate_right_key .. " / " .. TheInput:GetLocalizedControl(controller_id, CONTROL_ROTATE_LEFT) .. " " .. STRINGS.UI.HELP.ROTATE_RIGHT)
                            
        table.insert(t,  zoom_in_key .. " / " .. TheInput:GetLocalizedControl(controller_id, CONTROL_MAP_ZOOM_IN) .. " " .. STRINGS.UI.HELP.ZOOM_IN)
        table.insert(t,  zoom_out_key .. " / " .. TheInput:GetLocalizedControl(controller_id, CONTROL_MAP_ZOOM_OUT) .. " " .. STRINGS.UI.HELP.ZOOM_OUT)

        table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
        local playercontroller = ThePlayer and ThePlayer.components.playercontroller or nil
        if playercontroller and playercontroller.RMBaction then
            table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. playercontroller.RMBaction:GetActionString())
        end

        return table.concat(t, "  ")
    end
end)
