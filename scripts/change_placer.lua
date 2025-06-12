require("components/deployhelper")

AddComponentPostInit("placer", function(self)
    local SetBuilder_Old = self.SetBuilder
    self.SetBuilder = function (self, builder, recipe, invobject, ...)
        SetBuilder_Old(self, builder, recipe, invobject, ...)
        if TheInput:ControllerAttached() then
            self:InitializeAxisAlignedHelpers()
        end
    end

    local OnUpdate_Old = self.OnUpdate
    local OnUpdate_New = function (self, dt, ...)

        local rotating_from_boat_center
        local hide_if_cannot_build

        local axisalignedhelpers_visible = false
        self.axisalignedplacementtoggle = false
        if ThePlayer == nil then
            return
        elseif not TheInput:ControllerAttached() then
            local pt = self.selected_pos or TheInput:GetWorldPosition()
            if self.snap_to_tile then
                self.inst.Transform:SetPosition(TheWorld.Map:GetTileCenterPoint(pt:Get()))
            elseif self.snap_to_meters then
                self.inst.Transform:SetPosition(math.floor(pt.x) + .5, 0, math.floor(pt.z) + .5)
            elseif self.snaptogrid then
                self.inst.Transform:SetPosition(math.floor(pt.x + .5), 0, math.floor(pt.z + .5))
            elseif self.snap_to_boat_edge then
                local boats = TheSim:FindEntities(pt.x, 0, pt.z, TUNING.MAX_WALKABLE_PLATFORM_RADIUS, self.BOAT_MUST_TAGS)
                local boat = GetClosest(self.inst, boats)

                if boat then
                    SnapToBoatEdge(self.inst, boat, pt)
                    if self.inst:GetDistanceSqToPoint(pt) > 1 then
                        hide_if_cannot_build = true
                    end
                else
                    self.inst.Transform:SetPosition(pt:Get())
                    hide_if_cannot_build = true
                end
            else
                self.axisalignedplacementtoggle = TheInput:IsControlPressed(CONTROL_AXISALIGNEDPLACEMENT_TOGGLEMOD)
                if self:IsAxisAlignedPlacement() then
                    axisalignedhelpers_visible = true
                    self.inst.Transform:SetPosition(self:GetAxisAlignedPlacementTransform(pt.x, 0, pt.z))
                else
                    self.inst.Transform:SetPosition(pt:Get())
                end
            end

            -- Set the placer's rotation to point away from the boat's center point
            if self.rotate_from_boat_center then
                local boat = TheWorld.Map:GetPlatformAtPoint(pt.x, pt.z)
                if boat ~= nil then
                    local angle = GetAngleFromBoat(boat, pt.x, pt.z) / DEGREES
                    self.inst.Transform:SetRotation(-angle)
                    rotating_from_boat_center = true
                end
            end
        elseif self.snap_to_tile then
            --Using an offset in this causes a bug in the terraformer functionality while using a controller.
            self.inst.Transform:SetPosition(TheWorld.Map:GetTileCenterPoint(ThePlayer.entity:LocalToWorldSpace(0, 0, 0)))
        elseif self.snap_to_meters then
            local x, y, z = ThePlayer.entity:LocalToWorldSpace(self.offset, 0, 0)
            -- ================================================================================================================================ --
            if not self.fake then
                local target_pos = ThePlayer.components.playercontroller.reticule and ThePlayer.components.playercontroller.reticule.targetpos
                if target_pos then
                    x, y, z = target_pos:Get()
                end
            end
            -- ================================================================================================================================ --
            self.inst.Transform:SetPosition(math.floor(x) + .5, 0, math.floor(z) + .5)
        elseif self.snaptogrid then
            local x, y, z = ThePlayer.entity:LocalToWorldSpace(self.offset, 0, 0)
            -- ================================================================================================================================ --
            if not self.fake then
                local target_pos = ThePlayer.components.playercontroller.reticule and ThePlayer.components.playercontroller.reticule.targetpos
                if target_pos then
                    x, y, z = target_pos:Get()
                end
            end
            -- ================================================================================================================================ --
            self.inst.Transform:SetPosition(math.floor(x + .5), 0, math.floor(z + .5))
        elseif self.snap_to_boat_edge then
            local x, y, z = ThePlayer.entity:LocalToWorldSpace(self.offset, 0, 0)
            local boat = ThePlayer:GetCurrentPlatform()
            if boat and boat:HasTag("boat") then
                SnapToBoatEdge(self.inst, boat, Vector3(x, 0, z))
            else
                self.inst.Transform:SetPosition(x, 0, z)
            end
        elseif self.onground then
            --V2C: this will keep ground orientation accurate and smooth,
            --     but unfortunately position will be choppy compared to parenting
            --V2C: switched to WallUpdate, so should be smooth now
            local x, y, z = ThePlayer.entity:LocalToWorldSpace(self.offset, 0, 0)
            -- ================================================================================================================================ --
            if not self.fake then
                local target_pos = ThePlayer.components.playercontroller.reticule and ThePlayer.components.playercontroller.reticule.targetpos
                if target_pos then
                    x, y, z = target_pos:Get()
                end
            end
            -- ================================================================================================================================ --
            self.inst.Transform:SetPosition(x, y, z)
            if self.controllergroundoverridefn then
                self.controllergroundoverridefn(self, ThePlayer, x, y, z)
            end
        elseif self.inst.parent == nil then
    --        ThePlayer:AddChild(self.inst)
    --        self.inst.Transform:SetPosition(self.offset, 0, 0) -- this will cause the object to be rotated to face the same direction as the player, which is not what we want, rotate the camera if you want to rotate the object
            local x, y, z = ThePlayer.entity:LocalToWorldSpace(self.offset, 0, 0)
            -- ================================================================================================================================ --
            if not self.fake then
                local target_pos = ThePlayer.components.playercontroller.reticule and ThePlayer.components.playercontroller.reticule.targetpos
                if target_pos then
                    x, y, z = target_pos:Get()
                end

                self.axisalignedplacementtoggle = ThePlayer.components.playercontroller.Click_Right_Bumper_While_Holding_Left_Bumper
                -- TheInput:IsControlPressed(CHANGE_CONTROL_LEFT)
                if self:IsAxisAlignedPlacement() then
                    axisalignedhelpers_visible = true
                    x, y, z = self:GetAxisAlignedPlacementTransform(x, y, z)
                end
            end
            -- ================================================================================================================================ --
            self.inst.Transform:SetPosition(x, y, z)

            -- Set the placer's rotation to point away from the boat's center point
            if self.rotate_from_boat_center then
                local boat = TheWorld.Map:GetPlatformAtPoint(x, z)
                if boat ~= nil then
                    local angle = GetAngleFromBoat(boat, x, z) / DEGREES
                    self.inst.Transform:SetRotation(-angle)
                    rotating_from_boat_center = true
                end
            end
        end

        if self.fixedcameraoffset ~= nil and not rotating_from_boat_center then
            local rot = self.fixedcameraoffset - TheCamera:GetHeading() -- rotate against the camera
            local offset = self.rotationoffset ~= nil and self.rotationoffset or 0
            self.inst.Transform:SetRotation(rot + offset)
        end

        if self.onupdatetransform ~= nil then
            self.onupdatetransform(self.inst)
        end

        local was_mouse_blocked = self.mouse_blocked

        self.can_build, self.mouse_blocked = self:TestCanBuild()

        if hide_if_cannot_build and not self.can_build then
            self.mouse_blocked = true
        end

        if self.builder ~= nil and was_mouse_blocked ~= self.mouse_blocked and self.hide_inv_icon then
            self.builder:PushEvent(self.mouse_blocked and "onplacerhidden" or "onplacershown")
        end

        local x, y, z = self.inst.Transform:GetWorldPosition()
        TriggerDeployHelpers(x, y, z, 64, self.recipe, self.inst)


        if self.can_build then
            if self.oncanbuild ~= nil then
                self.oncanbuild(self.inst, self.mouse_blocked)
                return
            end

            if self.mouse_blocked then
                self.inst:Hide()
                for _, v in ipairs(self.linked) do
                    v:Hide()
                end
            else
                self.inst.AnimState:SetAddColour(.25, .75, .25, 0)
                self.inst:Show()
                for _, v in ipairs(self.linked) do
                    v.AnimState:SetAddColour(.25, .75, .25, 0)
                    v:Show()
                end
            end
        else
            if self.oncannotbuild ~= nil then
                self.oncannotbuild(self.inst, self.mouse_blocked)
                return
            end

            if self.mouse_blocked then
                self.inst:Hide()
                for _, v in ipairs(self.linked) do
                    v:Hide()
                end
            else
                self.inst.AnimState:SetAddColour(.75, .25, .25, 0)
                self.inst:Show()
                for _, v in ipairs(self.linked) do
                    v.AnimState:SetAddColour(.75, .25, .25, 0)
                    v:Show()
                end
            end
        end
        if self.axisalignedhelpers then
            self.axisalignedhelpers.visible = axisalignedhelpers_visible
            self:UpdateAxisAlignedHelpers(dt)
        end
    end

    self.OnUpdate = function (self, dt, ...)
        if TheInput:ControllerAttached() and (not IsOtherModEnabled("Geometric Placement") or GetOtherModConfig("Geometric Placement", "CTRL") or TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT)) then
            OnUpdate_New(self, dt, ...)
        else
            OnUpdate_Old(self, dt, ...)
        end
        if self.fake then
            self.inst:Hide()
            for _, v in ipairs(self.linked) do
                v:Hide()
            end
        end
    end
end)
