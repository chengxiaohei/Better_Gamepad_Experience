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
        
        table.insert(t,  TheInput:GetLocalizedControl(controller_id, CHANGE_IS_REVERSE_CAMERA_ROTATION_MAP and CONTROL_ROTATE_RIGHT or CONTROL_ROTATE_LEFT) .. " " .. STRINGS.UI.HELP.ROTATE_LEFT)
        table.insert(t,  TheInput:GetLocalizedControl(controller_id, CHANGE_IS_REVERSE_CAMERA_ROTATION_MAP and CONTROL_ROTATE_LEFT or CONTROL_ROTATE_RIGHT) .. " " .. STRINGS.UI.HELP.ROTATE_RIGHT)
        table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MAP_ZOOM_IN) .. " " .. STRINGS.UI.HELP.ZOOM_IN)
        table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_MAP_ZOOM_OUT) .. " " .. STRINGS.UI.HELP.ZOOM_OUT)
        table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

        return table.concat(t, "  ")
    end
end)
