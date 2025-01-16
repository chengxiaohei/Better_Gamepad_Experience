AddClassPostConstruct("screens/mapscreen", function(self)
    local OnControl_Old = self.OnControl
    self.OnControl = function(self, control, down, ...)
        if TheInput:ControllerAttached() then
            if control == CONTROL_ROTATE_LEFT then
                control = CHANGE_IS_REVERSE_CAMERA_ROTATION_MAP and CONTROL_ROTATE_LEFT or CONTROL_ROTATE_RIGHT
            elseif control == CONTROL_ROTATE_RIGHT then
                control = CHANGE_IS_REVERSE_CAMERA_ROTATION_MAP and CONTROL_ROTATE_RIGHT or CONTROL_ROTATE_LEFT
            end
        end
        return OnControl_Old(self, control, down, ...)
    end

    self.GetHelpText = function (self, ...)
        local controller_id = TheInput:GetControllerID()
        local t = {}

        local rotate_left_bumper  = CHANGE_IS_REVERSE_CAMERA_ROTATION_MAP and TheInput:GetLocalizedControl(controller_id, CONTROL_ROTATE_RIGHT) or TheInput:GetLocalizedControl(controller_id, CONTROL_ROTATE_LEFT)
        local rotate_right_bumper = CHANGE_IS_REVERSE_CAMERA_ROTATION_MAP and TheInput:GetLocalizedControl(controller_id, CONTROL_ROTATE_LEFT) or TheInput:GetLocalizedControl(controller_id, CONTROL_ROTATE_RIGHT)

        table.insert(t,  rotate_left_bumper .. " " .. STRINGS.UI.HELP.ROTATE_LEFT)
        table.insert(t,  rotate_right_bumper .. " " .. STRINGS.UI.HELP.ROTATE_RIGHT)
        table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MAP_ZOOM_IN) .. " " .. STRINGS.UI.HELP.ZOOM_IN)
        table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MAP_ZOOM_OUT) .. " " .. STRINGS.UI.HELP.ZOOM_OUT)
        table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)
        local playercontroller = ThePlayer and ThePlayer.components.playercontroller or nil
        if playercontroller and playercontroller.RMBaction then
            table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. playercontroller.RMBaction:GetActionString())
        end

        return table.concat(t, "  ")
    end
end)
