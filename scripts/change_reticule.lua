
AddPrefabPostInitAny(function(inst)
    if inst.components.reticule then
        inst.components.reticule.origin_twinstickmode = inst.components.reticule.twinstickmode
    elseif inst.components.aoetargeting then
        inst.components.aoetargeting.reticule.origin_twinstickmode = inst.components.aoetargeting.reticule.twinstickmode
    end
end)

AddComponentPostInit("reticule", function(self)

    local OnCameraUpdate_Old = self.OnCameraUpdate
    self.OnCameraUpdate = function (self, dt, ...)
    	if TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
            self.twinstickmode = 1
        else
            self.twinstickmode = self.origin_twinstickmode
        end
        OnCameraUpdate_Old(self, dt, ...)
    end

    local UpdateTwinStickMode1_Old = self.UpdateTwinStickMode1
    self.UpdateTwinStickMode1 = function (self, ...)
        if self.twinstickoverride_mode1 then
            self.twinstickx = self.twinstickx_mode1
            self.twinstickz = self.twinstickz_mode1
            self.twinstickoverride = self.twinstickoverride_mode1
        end
        
        UpdateTwinStickMode1_Old(self, ...)
        self.twinstickx_mode1 = self.twinstickx
        self.twinstickz_mode1 = self.twinstickz
        self.twinstickoverride_mode1 = self.twinstickoverride

        local x, _, z = self.inst.Transform:GetWorldPosition()
        self.targetpos_mode1_delta_x = self.targetpos.x - x
        self.targetpos_mode1_delta_z = self.targetpos.z - z
    end

    local UpdatePosition_Old = self.UpdatePosition
    self.UpdatePosition = function (self, dt, ...)
        if self.twinstickoverride_mode1 then
            if self.targetpos_mode1_delta_x ~= nil and self.targetpos_mode1_delta_z ~= nil then
                local x, _, z = self.inst.Transform:GetWorldPosition()
                self.targetpos.x = self.targetpos_mode1_delta_x + x
                self.targetpos.z = self.targetpos_mode1_delta_z + z
            end
        end
        UpdatePosition_Old(self, dt, ...)
    end

    -- Found a honey place to clean up
    local CreateReticule_Old = self.CreateReticule
    self.CreateReticule = function (self, ...)
        self.twinstickx_mode1 = nil
        self.twinstickz_mode1 = nil
        self.twinstickoverride_mode1 = nil
        CreateReticule_Old(self, ...)
    end

end)