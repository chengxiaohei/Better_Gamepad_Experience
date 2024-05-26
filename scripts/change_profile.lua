
AddClassPostConstruct("playerprofile", function(self)
    local GetIntegratedBackpack_Old = self.GetIntegratedBackpack
    self.GetIntegratedBackpack = function (self, ...)
        if CHANGE_ADD_EXTRAL_BACKPACK_INTEGRATE_SETTING and TheInput:IsControllerAttached() then
            return CHANGE_INTEGRATE_BACKPACK 
        else
            return GetIntegratedBackpack_Old(self, ...)
        end
    end
end)