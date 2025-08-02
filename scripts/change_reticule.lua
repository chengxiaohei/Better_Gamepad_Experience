
AddPrefabPostInitAny(function(inst)
    if inst.components.reticule then
        inst.components.reticule.origin_twinstickmode = inst.components.reticule.twinstickmode
        if inst.prefab == "wortox" then inst.components.reticule.twinstickrange = ACTIONS.BLINK.distance  -- 灵魂跳跃
        elseif inst.prefab == "orangestaff" then inst.components.reticule.twinstickrange = 30  -- 传送法杖
        elseif inst.prefab == "yellowstaff" then inst.components.reticule.twinstickrange = 20  -- 星杖
        elseif inst.prefab == "opalstaff" then inst.components.reticule.twinstickrange = 20  -- 月杖
        elseif inst.prefab == "trident" then inst.components.reticule.twinstickrange = 20  -- 三叉戟
        elseif inst.prefab == "oceanfishingrod" then inst.components.reticule.twinstickrange = 20  -- 海钓竿
        elseif inst.prefab == "gnarwail_horn" then inst.components.reticule.twinstickrange = 20  -- 一角鲸的角
        elseif inst.prefab == "wurt_swampitem_shadow" then inst.components.reticule.twinstickrange = 30  -- wurt's magic staff
        elseif inst.prefab == "wurt_swampitem_lunar" then inst.components.reticule.twinstickrange = 30  -- wurt's magic staff
        -- default:
            -- elseif inst:HasTag("dumbbell") then inst.components.reticule.twinstickrange = 8  -- 哑铃
            -- elseif inst.prefab == "wilson" then inst.components.reticule.twinstickrange = 8  -- 扔火把
            -- elseif inst.prefab == "sleepbomb" then inst.components.reticule.twinstickrange = 8  -- 催眠袋
            -- 水球  8
            -- 鱼食  8
            -- 海草种子  8
        end
    elseif inst.components.aoetargeting then
        inst.components.aoetargeting.reticule.origin_twinstickmode = inst.components.aoetargeting.reticule.twinstickmode
    end
end)

AddComponentPostInit("reticule", function(self)
    self.clear_memory_flag = false

    local OnCameraUpdate_Old = self.OnCameraUpdate
    self.OnCameraUpdate = function (self, dt, ...)
        local controller = ThePlayer and ThePlayer.components and ThePlayer.components.playercontroller
        local isplacer = controller ~= nil and (controller.deployplacer ~= nil or controller.placer ~= nil)
        if not (self.inst:HasTag("boat") or self.inst:HasTag("boatcannon") or self.inst.prefab == "winona") then
            if self.clear_memory_flag == false and (TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) or isplacer) then
                self.twinstickmode = 1
                self.twinstickrange = self.twinstickrange or 8  -- default is 8
            else
                self.twinstickmode = self.origin_twinstickmode
            end
        end
        OnCameraUpdate_Old(self, dt, ...)
        if ThePlayer and ThePlayer.components and ThePlayer.components.playercontroller
            and ThePlayer.components.playercontroller.Click_Right_Stick_While_Holding_Right_Bumper then
            self.clear_memory_flag = true
            self.twinstickx_mode1 = nil
            self.twinstickz_mode1 = nil
            self.twinstickoverride = nil
            self.twinstickoverride_mode1 = nil
        else
            self.clear_memory_flag = false
        end
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
        if self.targetpos ~= nil then
            self.targetpos_mode1_delta_x = self.targetpos.x - x
            self.targetpos_mode1_delta_z = self.targetpos.z - z
        end
    end

    local UpdatePosition_Old = self.UpdatePosition
    self.UpdatePosition = function (self, dt, ...)
        if self.twinstickoverride_mode1 then
            if self.targetpos ~= nil and self.targetpos_mode1_delta_x ~= nil and self.targetpos_mode1_delta_z ~= nil then
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
        self.clear_memory_flag = false
        self.twinstickx_mode1 = nil
        self.twinstickz_mode1 = nil
        self.twinstickoverride = nil
        self.twinstickoverride_mode1 = nil
        CreateReticule_Old(self, ...)
    end

end)