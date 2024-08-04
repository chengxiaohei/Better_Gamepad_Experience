
AddClassPostConstruct("widgets/wheel", function(self)
    local OnControl_Old = self.OnControl
    self.OnControl = function(self, control, down, ...)
        if TheInput:ControllerAttached() and CHANGE_IS_USE_DPAD_SELECT_SPELLWHEEL_ITEM then
            if control == CONTROL_ACCEPT then return false
            elseif control == CONTROL_CANCEL then return false
            elseif control == CONTROL_INVENTORY_USEONSCENE then return true
            elseif control == CONTROL_INVENTORY_USEONSELF then control = CONTROL_CANCEL
            elseif control == CONTROL_INVENTORY_DROP then control = CONTROL_ACCEPT
            end
        end
        return OnControl_Old(self, control, down, ...)
    end

    local GetHelpText_Old = self.GetHelpText
    local GetHelpText_New = function (self, ...)
        local controller_id = TheInput:GetControllerID()
        local t = {}
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF, false, false ) .. " " .. STRINGS.UI.OPTIONS.CLOSE)	
        return table.concat(t, "  ")
    end

    self.GetHelpText = function (self, ...)
        if TheInput:ControllerAttached() and CHANGE_IS_USE_DPAD_SELECT_SPELLWHEEL_ITEM then
            return GetHelpText_New(self, ...)
        end
        return GetHelpText_Old(self, ...)
    end


    local Open_Old = self.Open
    self.Open = function (self, dataset_name, ...)
        local result = Open_Old(self, dataset_name, ...)
        if TheInput:ControllerAttached() and CHANGE_IS_USE_DPAD_SELECT_SPELLWHEEL_ITEM then
            for _, v in ipairs(self.activeitems) do
                if v ~= nil and v.widget ~= nil then
                    v.widget.GetHelpText = function (_self, ...)
                        local controller_id = TheInput:GetControllerID()
                        local t = {}
                        if (not _self:IsSelected() or _self.AllowOnControlWhenSelected) and _self.help_message ~= "" then
                            table.insert(t, TheInput:GetLocalizedControl(controller_id,CONTROL_INVENTORY_DROP, false, false ) .. " " .. _self.help_message)
                        end
                        return table.concat(t, "  ")
                    end
                end
            end
        end
        return result
        
    end

    local OnUpdate_Old = self.OnUpdate
    self.OnUpdate = function (self, dt, ...)
        if TheInput:ControllerAttached() and TheInput:IsControlPressed(CHANGE_CONTROL_LEFT) then
            return
        end
        OnUpdate_Old(self, dt, ...)
    end
end)