AddClassPostConstruct("screens/mapscreen", function(self)
    local OnControl_Old = self.OnControl
    self.OnControl = function(self, control, down, ...)
        if TheInput:ControllerAttached() and CHANGE_IS_SWAP_CAMERA_ROTATION then
            if control == CONTROL_ROTATE_LEFT then
                control = CONTROL_ROTATE_RIGHT
            elseif control == CONTROL_ROTATE_RIGHT then
                control = CONTROL_ROTATE_LEFT
            end
        end
        return OnControl_Old(self, control, down, ...)
    end
end)