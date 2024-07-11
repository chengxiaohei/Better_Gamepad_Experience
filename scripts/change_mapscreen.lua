AddClassPostConstruct("screens/mapscreen", function(self)
    local OnControl_Old = self.OnControl
    self.OnControl = function(self, control, down, ...)
        if TheInput:ControllerAttached() then
            if control == CONTROL_ROTATE_LEFT or control == CONTROL_ROTATE_RIGHT then return true end
            if TheInput:IsControlPressed(CHANGE_CONTROL_CAMERA) then
                if control == CONTROL_INVENTORY_LEFT then
                    control = CONTROL_ROTATE_RIGHT
                elseif control == CONTROL_INVENTORY_RIGHT then
                    control = CONTROL_ROTATE_LEFT
                end
            end
            return OnControl_Old(self, control, down, ...)
        end
    end

    self.GetHelpText = function ()
        local controller_id = TheInput:GetControllerID()
        local t = {}

        table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_ROTATE_LEFT) .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_LEFT) .. " " .. STRINGS.UI.HELP.ROTATE_LEFT)
        table.insert(t,  TheInput:GetLocalizedControl(controller_id, CONTROL_ROTATE_LEFT) .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_RIGHT) .. " " .. STRINGS.UI.HELP.ROTATE_RIGHT)
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