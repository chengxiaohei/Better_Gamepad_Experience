local FollowText = require "widgets/followtext"
local Text = require "widgets/text"

AddClassPostConstruct("widgets/controls", function(self)

    -- self.playeractionhint
    self.playeractionhint:SetOffset(Vector3(0, 120, 0))

    -- self.playeractionhint_itemhighlight
    self.playeractionhint_itemhighlight:SetOffset(Vector3(0, 120, 0))
    
    self.playeraltactionhint = self:AddChild(FollowText(TALKINGFONT, 28))
    self.playeraltactionhint:SetHUD(self.owner.HUD.inst)
    self.playeraltactionhint:SetOffset(Vector3(0, 120, 0))
    self.playeraltactionhint:Hide()

    self.playeraltactionhint_itemhighlight = self:AddChild(FollowText(TALKINGFONT, 28))
    self.playeraltactionhint_itemhighlight:SetHUD(self.owner.HUD.inst)
    self.playeraltactionhint_itemhighlight:SetOffset(Vector3(0, 120, 0))
    self.playeraltactionhint_itemhighlight:Hide()

    -- self.attackhint
    self.attackhint:SetOffset(Vector3(0, 120, 0))

    self.attackhint_itemhighlight = self:AddChild(FollowText(TALKINGFONT, 28))
    self.attackhint_itemhighlight:SetHUD(self.owner.HUD.inst)
    self.attackhint_itemhighlight:SetOffset(Vector3(0, 120, 0))
    self.attackhint_itemhighlight:Hide()

    -- self.groundactionhint
    self.groundactionhint:SetOffset(Vector3(0, 120, 0))

    local HighlightSceneItem = function(target, followerWidget, itemhighlight)
        if target ~= nil and followerWidget.text.string ~= nil then
            itemhighlight:Show()
            local offsetx, offsety = followerWidget:GetScreenOffset()
            itemhighlight:SetScreenOffset(offsetx, offsety)
            itemhighlight:SetTarget(followerWidget.target)

            local str = followerWidget.text.string
            local itemlines = {}
            local commandlines = {}
            for idx,line in ipairs(string.split(str, "\n")) do
                if idx==1 then
                    itemlines[#itemlines+1] = line
                    commandlines[#commandlines+1]= " "
                else
                    itemlines[#itemlines+1] = " "
                    commandlines[#commandlines+1] = line
                end
            end
            followerWidget.text:SetString(table.concat(commandlines,"\n"))

            itemhighlight.text:SetString(table.concat(itemlines,"\n"))
            if target:GetIsWet() then
                itemhighlight.text:SetColour(unpack(WET_TEXT_COLOUR))
            else
                itemhighlight.text:SetColour(unpack(NORMAL_TEXT_COLOUR))
            end
        else
            itemhighlight:Hide()
        end
    end

    self.mapcontrols.rotleft2 = self.mapcontrols:AddChild(Text(UIFONT, 30))
    self.mapcontrols.rotleft2:SetPosition(-40, -40, 0)
    self.mapcontrols.rotleft2:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_LEFT))
    self.mapcontrols.rotleft2:Hide()

    self.mapcontrols.rotright2 = self.mapcontrols:AddChild(Text(UIFONT, 30))
    self.mapcontrols.rotright2:SetPosition(40, -40, 0)
    self.mapcontrols.rotright2:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_RIGHT))
    self.mapcontrols.rotright2:Hide()

    local OnUpdate_Old = self.OnUpdate

    local OnUpdate_New = function (self, dt, ...)
        if PerformingRestart then
            self.playeractionhint:SetTarget(nil)
            self.playeractionhint_itemhighlight:SetTarget(nil)
            self.playeraltactionhint:SetTarget(nil)
            self.playeraltactionhint_itemhighlight:SetTarget(nil)
            self.attackhint:SetTarget(nil)
            self.attackhint_itemhighlight:SetTarget(nil)
            self.groundactionhint:SetTarget(nil)
            return
        end

        local scrnw, scrnh = TheSim:GetScreenSize()
        if scrnw ~= self._scrnw or scrnh ~= self._scrnh then
            self._scrnw, self._scrnh = scrnw, scrnh
            self:SetHUDSize()
        end

        local controller_mode = TheInput:ControllerAttached()
        local controller_id = TheInput:GetControllerID()

        if CHANGE_ALWAYS_SHOW_MAP_CONTROL_WIDGET then
            self.mapcontrols:Show()
            if controller_mode and TheInput:IsControlPressed(CHANGE_CONTROL_LEFT) then
                self.mapcontrols.rotleft:Hide()
                self.mapcontrols.rotright:Hide()
                self.mapcontrols.rotleft2:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_LEFT))
                self.mapcontrols.rotleft2:Show()
                self.mapcontrols.rotright2:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_RIGHT))
                self.mapcontrols.rotright2:Show()
            else
                self.mapcontrols.rotleft:Show()
                self.mapcontrols.rotright:Show()
                self.mapcontrols.rotleft2:Hide()
                self.mapcontrols.rotright2:Hide()
            end
        else
            self.mapcontrols:Hide()
        end

        for k,v in pairs(self.containers) do
            if v.should_close_widget then
                self.containers[k] = nil
                v:Kill()
            end
        end

        --[[if false and self.demotimer then
            if IsGamePurchased() then
                self.demotimer:Kill()
                self.demotimer = nil
            end
        end]]

        if controller_mode and self.owner:IsActionsVisible() then
            local ground_l, ground_r = self.owner.components.playercontroller:GetGroundUseAction()
            local ground_cmds = {}
            local isplacing = self.owner.components.playercontroller.deployplacer ~= nil or self.owner.components.playercontroller.placer ~= nil
            if isplacing then
                local placer = self.terraformplacer

                if self.owner.components.playercontroller.deployplacer ~= nil then
                    self.groundactionhint:Show()
                    self.groundactionhint:SetTarget(self.owner.components.playercontroller.deployplacer)

                    if self.owner.components.playercontroller.deployplacer.components.placer.can_build then
                        self.groundactionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION) .. " " .. self.owner.components.playercontroller.deployplacer.components.placer:GetDeployAction():GetActionString().."\n"..TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..STRINGS.UI.HUD.CANCEL)
                    else
                        self.groundactionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..STRINGS.UI.HUD.CANCEL)
                    end

                elseif self.owner.components.playercontroller.placer ~= nil then
                    self.groundactionhint:Show()
                    self.groundactionhint:SetTarget(self.owner.components.playercontroller.placer)
                    if self.owner.components.playercontroller.placer.components.placer.can_build then
                        self.groundactionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION) .. " " .. STRINGS.UI.HUD.BUILD.."\n" .. TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION) .. " " .. STRINGS.UI.HUD.CANCEL.."\n")
                    else
                        self.groundactionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION) .. " " .. STRINGS.UI.HUD.CANCEL.."\n")
                    end
                end
            else
                local aoetargeting = self.owner.components.playercontroller:IsAOETargeting()
                if ground_r ~= nil then
                    if ground_r.action ~= ACTIONS.CASTAOE then
                        table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..ground_r:GetActionString())
                    elseif aoetargeting then
                        table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION).." "..ground_r:GetActionString())
                    end
                end
                if aoetargeting then
                    table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..STRINGS.UI.HUD.CANCEL)
                end
                if #ground_cmds > 0 then
                    self.groundactionhint:Show()
                    self.groundactionhint:SetTarget(self.owner)
                    -- self.groundactionhint:SetTarget(self.owner.components.playercontroller.reticule ~= nil and self.owner.components.playercontroller.reticule.reticule or self.owner)
                    self.groundactionhint.text:SetString(table.concat(ground_cmds, "\n"))
                else
                    self.groundactionhint:Hide()
                end
            end

            local A_shown = false
            local Y_shown = false
            local B_shown = false
            local X_shown = false
            local controller_target = self.owner.components.playercontroller:GetControllerTarget()
            local controller_alt_target = self.owner.components.playercontroller:GetControllerAltTarget()
            local controller_attack_target = self.owner.components.playercontroller:GetControllerAttackTarget()
            local l, r
            if controller_target ~= nil then
                l, r = self.owner.components.playercontroller:GetSceneItemControllerAction(controller_target)
            end
            local alt_l, alt_r
            if controller_alt_target ~= nil then
                alt_l, alt_r = self.owner.components.playercontroller:GetSceneItemControllerAction(controller_alt_target)
            end

            if not isplacing and l == nil and alt_l == nil and ground_l == nil then
                ground_l = self.owner.components.playercontroller:GetGroundUseSpecialAction(nil, false)
                if ground_l ~= nil then
                    print("****** usinging special Action")
                    table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION).." "..ground_l:GetActionString())
                    A_shown = true
                    self.groundactionhint:Show()
                    self.groundactionhint:SetTarget(self.owner)
                    self.groundactionhint.text:SetString(table.concat(ground_cmds, "\n"))
                end
            end
            if not isplacing and r == nil and alt_r and ground_r == nil then
                ground_r = self.owner.components.playercontroller:GetGroundUseSpecialAction(nil, true)
                if ground_r ~= nil then
                    print("****** usinging special Alt Action")
                    table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..ground_r:GetActionString())
                    B_shown = true
                    self.groundactionhint:Show()
                    self.groundactionhint:SetTarget(self.owner)
                    self.groundactionhint.text:SetString(table.concat(ground_cmds, "\n"))
                end
            end

            if controller_target ~= nil then
                local cmds = {}

                local adjective = controller_target:GetAdjective()
                table.insert(cmds, adjective ~= nil and (adjective.." "..controller_target:GetDisplayName()) or controller_target:GetDisplayName())

                if (self.owner.CanExamine == nil or self.owner:CanExamine()) and
                    --V2C: Closing the avatar popup takes priority
                    not self.owner.HUD:IsPlayerAvatarPopUpOpen() and
                    (self.owner.sg == nil or self.owner.sg:HasStateTag("moving") or self.owner.sg:HasStateTag("idle") or self.owner.sg:HasStateTag("channeling")) and
                    (self.owner:HasTag("moving") or self.owner:HasTag("idle") or self.owner:HasTag("channeling")) and
                    controller_target:HasTag("inspectable") then
                    table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT) .. " " .. STRINGS.UI.HUD.INSPECT)
                    Y_shown = true
                end
                if not X_shown and controller_target == controller_attack_target then
                    table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. STRINGS.UI.HUD.ATTACK)
                    X_shown = true
                end
                if not A_shown and l ~= nil then
                    table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION) .. " " .. l:GetActionString())
                    A_shown = true
                end
                if not B_shown and controller_target == controller_attack_target and self.owner.components.playercontroller:IsControllerTargetLocked() then
                    table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HUD.UNLOCK_TARGET)
                    B_shown = true
                end
                if not B_shown and r ~= nil and ground_r == nil and controller_target == controller_alt_target and not self.owner.components.playercontroller:IsControllerTargetLocked() then
                    table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION) .. " " .. r:GetActionString())
                    B_shown = true
                end
                if controller_target.quagmire_shoptab ~= nil then
                    for k, v in pairs(self.craftingmenu.tabs.shown) do
                        if k.filter == controller_target.quagmire_shoptab then
                            if v then
                                table.insert(cmds, TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_OPEN_CRAFTING).." "..STRINGS.UI.CRAFTING.TABACTION[controller_target.quagmire_shoptab.str])
                            end
                            break
                        end
                    end
                end

                if #cmds ~= 0 then
                    self.playeractionhint:Show()
                    self.playeractionhint:SetTarget(controller_target)
                    self.playeractionhint.text:SetString(table.concat(cmds, "\n"))
                else
                    self.playeractionhint:Hide()
                    self.playeractionhint:SetTarget(nil)
                end
            else
                self.playeractionhint:Hide()
                self.playeractionhint:SetTarget(nil)
            end

            if controller_alt_target ~= nil then
                local alt_cmds = {}

                local adjective = controller_alt_target:GetAdjective()
                table.insert(alt_cmds, adjective ~= nil and adjective .. controller_alt_target:GetDisplayName() or controller_alt_target:GetDisplayName())

                if not Y_shown and (self.owner.CanExamine == nil or self.owner:CanExamine()) and
                    --V2C: Closing the avatar popup takes priority
                    not self.owner.HUD:IsPlayerAvatarPopUpOpen() and
                    (self.owner.sg == nil or self.owner.sg:HasStateTag("moving") or self.owner.sg:HasStateTag("idle") or self.owner.sg:HasStateTag("channeling")) and
                    (self.owner:HasTag("moving") or self.owner:HasTag("idle") or self.owner:HasTag("channeling")) and
                    controller_alt_target:HasTag("inspectable") then
                    table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT) .. " " .. STRINGS.UI.HUD.INSPECT)
                    Y_shown = true
                end

                if not X_shown and controller_alt_target == controller_attack_target then
                    table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. STRINGS.UI.HUD.ATTACK)
                    X_shown = true
                end
                if not B_shown and controller_alt_target == controller_attack_target and self.owner.components.playercontroller:IsControllerTargetLocked() then
                    table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HUD.UNLOCK_TARGET)
                    B_shown = true
                end
                if not B_shown and alt_r ~= nil and ground_r == nil and not self.owner.components.playercontroller:IsControllerTargetLocked() then
                    table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION) .. " " .. alt_r:GetActionString())
                    B_shown = true
                end

                if #alt_cmds > 1 then
                    self.playeraltactionhint:Show()
                    self.playeraltactionhint:SetTarget(controller_alt_target)
                    self.playeraltactionhint.text:SetString(table.concat(alt_cmds, "\n"))
                else
                    self.playeraltactionhint:Hide()
                    self.playeraltactionhint:SetTarget(nil)
                end
            else
                self.playeraltactionhint:Hide()
                self.playeraltactionhint:SetTarget(nil)
            end

            if not B_shown and not self.groundactionhint.shown and not self.owner.components.playercontroller:IsControllerTargetLocked() then
                if self.dismounthintdelay <= 0
                    and self.owner.replica.rider ~= nil
                    and self.owner.replica.rider:IsRiding() then
                    self.groundactionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..STRINGS.ACTIONS.DISMOUNT)
                    B_shown = true
                    self.groundactionhint:Show()
                    self.groundactionhint:SetTarget(self.owner)
                else
                    self.groundactionhint:Hide()
                    self.groundactionhint:SetTarget(nil)
                end
            elseif not self.groundactionhint.shown then
                self.groundactionhint:Hide()
                self.groundactionhint:SetTarget(nil)
            end

            if controller_attack_target ~= nil then
                local attack_cmds = {}

                local adjective = controller_attack_target:GetAdjective()
                table.insert(attack_cmds, adjective ~= nil and adjective .. controller_attack_target:GetDisplayName() or controller_attack_target:GetDisplayName())

                if not Y_shown and (self.owner.CanExamine == nil or self.owner:CanExamine()) and
                    --V2C: Closing the avatar popup takes priority
                    not self.owner.HUD:IsPlayerAvatarPopUpOpen() and
                    (self.owner.sg == nil or self.owner.sg:HasStateTag("moving") or self.owner.sg:HasStateTag("idle") or self.owner.sg:HasStateTag("channeling")) and
                    (self.owner:HasTag("moving") or self.owner:HasTag("idle") or self.owner:HasTag("channeling")) and
                    controller_attack_target:HasTag("inspectable") then
                    table.insert(attack_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT) .. " " .. STRINGS.UI.HUD.INSPECT)
                    Y_shown = true
                end
                if not X_shown then
                    table.insert(attack_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. STRINGS.UI.HUD.ATTACK)
                    X_shown = true
                end
                if not B_shown and self.owner.components.playercontroller:IsControllerTargetLocked() then
                    table.insert(attack_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HUD.UNLOCK_TARGET)
                    B_shown = true
                end

                if #attack_cmds > 1 then
                    self.attackhint:Show()
                    self.attackhint:SetTarget(controller_attack_target)
                    self.attackhint.text:SetString(table.concat(attack_cmds, "\n"))
                else
                    self.attackhint:Hide()
                    self.attackhint:SetTarget(nil)
                end
            else
                self.attackhint:Hide()
                self.attackhint:SetTarget(nil)
            end
        else
            self.attackhint:Hide()
            self.attackhint:SetTarget(nil)

            self.playeractionhint:Hide()
            self.playeractionhint:SetTarget(nil)

            self.playeraltactionhint:Hide()
            self.playeraltactionhint:SetTarget(nil)

            self.groundactionhint:Hide()
            self.groundactionhint:SetTarget(nil)
        end

        if not self.owner:HasTag("idle") then
            self.dismounthintdelay = .5
        elseif self.dismounthintdelay > 0 then
            self.dismounthintdelay = self.dismounthintdelay - dt
        end

        --default offsets
        self.playeractionhint:SetScreenOffset(0,0)
        self.playeraltactionhint:SetScreenOffset(0,0)
        self.attackhint:SetScreenOffset(0,0)
        self.groundactionhint:SetScreenOffset(0,0)

        local AdjustLocation = function(x_axis, first, second)
            if first == nil or second == nil then
                return
            end
            if first.shown and second.shown then
                local w1, h1 = first.text:GetRegionSize()
                local x1, y1 = first:GetPosition():Get()
                --print (w1, h1, x1, y1)

                local w2, h2 = second.text:GetRegionSize()
                local x2, y2 = second:GetPosition():Get()
                --print (w2, h2, x2, y2)

                local sep = (x1 + w1/2) < (x2 - w2/2) or
                            (x1 - w1/2) > (x2 + w2/2) or
                            (y1 + h1/2) < (y2 - h2/2) or
                            (y1 - h1/2) > (y2 + h2/2)

                if not sep then
                    if x_axis then
                        local f_l = x1 - w1/2
                        local f_r = x1 + w1/2

                        local s_l = x2 - w2/2
                        local s_r = x2 + w2/2

                        if math.abs(s_r - f_l) < math.abs(s_l - f_r) then
                            local d = (s_r - f_l) + 20
                            first:SetScreenOffset(d/2,0)
                            second:SetScreenOffset(-d/2,0)
                        else
                            local d = (f_r - s_l) + 20
                            first:SetScreenOffset( -d/2,0)
                            second:SetScreenOffset(d/2,0)
                        end
                    else
                        local f_b = x1 - h1/2
                        local f_t = x1 + h1/2

                        local s_b = x2 - h2/2
                        local s_t = x2 + h2/2

                        if math.abs(s_t - f_b) < math.abs(s_b - f_t) then
                            local d = (s_t - f_b) + 20
                            first:SetScreenOffset(0,d/2)
                            second:SetScreenOffset(0,-d/2)
                        else
                            local d = (f_t - s_b)
                            first:SetScreenOffset(0,-d/2)
                            second:SetScreenOffset(0,d/2)
                        end
                    end
                end
            end
        end

        AdjustLocation(true, self.playeractionhint, self.attackhint)
        AdjustLocation(true, self.playeraltactionhint, self.attackhint)
        AdjustLocation(true, self.playeractionhint, self.playeraltactionhint)
        AdjustLocation(true, self.playeractionhint, self.groundactionhint)
        AdjustLocation(true, self.playeraltactionhint, self.groundactionhint)
        AdjustLocation(true, self.attackhint, self.groundactionhint)

        HighlightSceneItem(self.owner.components.playercontroller.controller_target, self.playeractionhint, self.playeractionhint_itemhighlight)
        HighlightSceneItem(self.owner.components.playercontroller.controller_alt_target, self.playeraltactionhint, self.playeraltactionhint_itemhighlight)
        HighlightSceneItem(self.owner.components.playercontroller.controller_attack_target, self.attackhint, self.attackhint_itemhighlight)
    end

    self.OnUpdate = function (self, dt, ...)
        if TheInput:ControllerAttached() then
            return OnUpdate_New(self, dt, ...)
        else
            self.playeractionhint:Hide()
            self.playeractionhint:SetTarget(nil)
            self.playeractionhint_itemhighlight:Hide()
            self.playeractionhint_itemhighlight:SetTarget(nil)

            self.playeraltactionhint:Hide()
            self.playeraltactionhint:SetTarget(nil)
            self.playeraltactionhint_itemhighlight:Hide()
            self.playeraltactionhint_itemhighlight:SetTarget(nil)

            self.attackhint:Hide()
            self.attackhint:SetTarget(nil)
            self.attackhint_itemhighlight:Hide()
            self.attackhint_itemhighlight:SetTarget(nil)

            self.groundactionhint:Hide()
            self.groundactionhint:SetTarget(nil)
            return OnUpdate_Old(self, dt, ...)
        end
    end

end)