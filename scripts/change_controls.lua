local FollowText = require "widgets/followtext"

AddClassPostConstruct("widgets/controls", function(self)

    -- self.playeractionhint alread done

    -- self.playeractionhint_itemhighlight already done
    
    self.playeraltactionhint = self:AddChild(FollowText(TALKINGFONT, 28))
    self.playeraltactionhint:SetHUD(self.owner.HUD.inst)
    self.playeraltactionhint:SetOffset(Vector3(0, 100, 0))
    self.playeraltactionhint:Hide()

    self.playeraltactionhint_itemhighlight = self:AddChild(FollowText(TALKINGFONT, 28))
    self.playeraltactionhint_itemhighlight:SetHUD(self.owner.HUD.inst)
    self.playeraltactionhint_itemhighlight:SetOffset(Vector3(0, 100, 0))
    self.playeraltactionhint_itemhighlight:Hide()

    -- self.attackhint already done

    self.attackhint_itemhighlight = self:AddChild(FollowText(TALKINGFONT, 28))
    self.attackhint_itemhighlight:SetHUD(self.owner.HUD.inst)
    self.attackhint_itemhighlight:SetOffset(Vector3(0, 100, 0))
    self.attackhint_itemhighlight:Hide()

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

        -- ======================================================================= --
        -- if controller_mode then
        --     self.mapcontrols:Hide()
        -- else
        --     self.mapcontrols:Show()
        -- end
        self.mapcontrols:Show()
        -- ======================================================================= --

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
                    -- self.groundactionhint:SetTarget(self.owner)
                    self.groundactionhint:SetTarget(self.owner.components.playercontroller.reticule ~= nil and self.owner.components.playercontroller.reticule.reticule or self.owner)
                    self.groundactionhint.text:SetString(table.concat(ground_cmds, "\n"))
                else
                    self.groundactionhint:Hide()
                end
            end

            local alt_shown = false
            local attack_shown = false
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
                    table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION).." "..ground_l:GetActionString())
                    self.groundactionhint:Show()
                    self.groundactionhint:SetTarget(self.owner)
                    self.groundactionhint.text:SetString(table.concat(ground_cmds, "\n"))
                end
            end
            if not isplacing and r == nil and alt_r and ground_r == nil then
                ground_r = self.owner.components.playercontroller:GetGroundUseSpecialAction(nil, true)
                if ground_r ~= nil then
                    table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..ground_r:GetActionString())
                    self.groundactionhint:Show()
                    self.groundactionhint:SetTarget(self.owner)
                    self.groundactionhint.text:SetString(table.concat(ground_cmds, "\n"))
                end
            end

            if controller_target ~= nil then
                local cmds, cmdsoffset
                local textblock = self.playeractionhint.text

                cmds = {}
                cmdsoffset = 0
                self.playeractionhint:Show()
                self.playeractionhint:SetTarget(controller_target)

                local adjective = controller_target:GetAdjective()
                table.insert(cmds, adjective ~= nil and (adjective.." "..controller_target:GetDisplayName()) or controller_target:GetDisplayName())

                if controller_target == controller_attack_target then
                    table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. STRINGS.UI.HUD.ATTACK)
                    attack_shown = true
                end
                if (self.owner.CanExamine == nil or self.owner:CanExamine()) and
                    --V2C: Closing the avatar popup takes priority
                    not self.owner.HUD:IsPlayerAvatarPopUpOpen() and
                    (self.owner.sg == nil or self.owner.sg:HasStateTag("moving") or self.owner.sg:HasStateTag("idle") or self.owner.sg:HasStateTag("channeling")) and
                    (self.owner:HasTag("moving") or self.owner:HasTag("idle") or self.owner:HasTag("channeling")) and
                    controller_target:HasTag("inspectable") then
                    table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT) .. " " .. STRINGS.UI.HUD.INSPECT)
                end
                if l ~= nil then
                    table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION) .. " " .. l:GetActionString())
                end
                if r ~= nil and ground_r == nil then
                    table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION) .. " " .. r:GetActionString())
                    alt_shown = true
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

                if #cmds - cmdsoffset <= 1 then
                    --New special case that we support:
                    -- target is highlighted but with no actions
                    -- -> suppress any ground action hints
                    -- -> use target's custom display name to show special action hint
                    if cmds ~= ground_cmds then
                        self.groundactionhint:Hide()
                        self.groundactionhint:SetTarget(nil)
                    end
                    textblock:SetString(cmds[#cmds])
                else
                    textblock:SetString(table.concat(cmds, "\n"))
                end
            elseif not self.groundactionhint.shown then
                if self.dismounthintdelay <= 0
                    and self.owner.replica.rider ~= nil
                    and self.owner.replica.rider:IsRiding() then
                    self.playeractionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..STRINGS.ACTIONS.DISMOUNT)
                    self.playeractionhint:Show()
                    self.playeractionhint:SetTarget(self.owner)
                else
                    self.playeractionhint:Hide()
                    self.playeractionhint:SetTarget(nil)
                end
            else
                self.playeractionhint:Hide()
                self.playeractionhint:SetTarget(nil)
            end

            if controller_attack_target ~= nil and not attack_shown then
                local attackhint_textblock = ""
                local adjective = controller_attack_target:GetAdjective()
                if adjective ~= nil then
                    attackhint_textblock = attackhint_textblock .. adjective .. " "
                end
                attackhint_textblock = attackhint_textblock .. controller_attack_target:GetDisplayName() .. "\n"

                self.attackhint:Show()
                self.attackhint:SetTarget(controller_attack_target)
                attackhint_textblock = attackhint_textblock .. TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. STRINGS.UI.HUD.ATTACK .. "\n"
                if self.owner.components.playercontroller:IsControllerTargetLocked() then
                    attackhint_textblock = attackhint_textblock .. TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HUD.UNLOCK_TARGET
                elseif controller_alt_target ~= nil and alt_r ~= nil and ground_r == nil and controller_alt_target == controller_attack_target and not alt_shown then
                    attackhint_textblock = attackhint_textblock .. TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..alt_r:GetActionString()
                    alt_shown = true
                end
                self.attackhint.text:SetString(attackhint_textblock)
            else
                self.attackhint:Hide()
                self.attackhint:SetTarget(nil)
            end

            if controller_alt_target ~= nil and alt_r ~= nil and ground_r == nil and not (alt_shown or self.owner.components.playercontroller:IsControllerTargetLocked()) then
                local playeraltactionhint_textblock = ""
                local adjective = controller_alt_target:GetAdjective()
                if adjective ~= nil then
                    playeraltactionhint_textblock = playeraltactionhint_textblock .. adjective .. " "
                end
                playeraltactionhint_textblock = playeraltactionhint_textblock .. controller_alt_target:GetDisplayName() .. "\n"
                self.playeraltactionhint:Show()
                self.playeraltactionhint:SetTarget(controller_alt_target)

                playeraltactionhint_textblock = playeraltactionhint_textblock .. TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..alt_r:GetActionString()
                self.playeraltactionhint.text:SetString(playeraltactionhint_textblock)
            else
                self.playeraltactionhint:Hide()
                self.playeraltactionhint:SetTarget(nil)
            end
        else
            self.attackhint:Hide()
            self.attackhint:SetTarget(nil)

            self.playeractionhint:Hide()
            self.playeractionhint:SetTarget(nil)

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

        --if we are showing both hints, make sure they don't overlap
        if self.attackhint.shown and self.playeractionhint.shown then

            local w1, h1 = self.attackhint.text:GetRegionSize()
            local x1, y1 = self.attackhint:GetPosition():Get()
            --print (w1, h1, x1, y1)

            local w2, h2 = self.playeractionhint.text:GetRegionSize()
            local x2, y2 = self.playeractionhint:GetPosition():Get()
            --print (w2, h2, x2, y2)

            local sep = (x1 + w1/2) < (x2 - w2/2) or
                        (x1 - w1/2) > (x2 + w2/2) or
                        (y1 + h1/2) < (y2 - h2/2) or
                        (y1 - h1/2) > (y2 + h2/2)

            if not sep then
                local a_l = x1 - w1/2
                local a_r = x1 + w1/2

                local p_l = x2 - w2/2
                local p_r = x2 + w2/2

                if math.abs(p_r - a_l) < math.abs(p_l - a_r) then
                    local d = (p_r - a_l) + 20
                    self.attackhint:SetScreenOffset(d/2,0)
                    self.playeractionhint:SetScreenOffset(-d/2,0)
                else
                    local d = (a_r - p_l) + 20
                    self.attackhint:SetScreenOffset( -d/2,0)
                    self.playeractionhint:SetScreenOffset(d/2,0)
                end
            end
        end

        -- self:HighlightActionItem(1, true)
        HighlightSceneItem(self.owner.components.playercontroller.controller_target, self.playeractionhint, self.playeractionhint_itemhighlight)
        HighlightSceneItem(self.owner.components.playercontroller.controller_alt_target, self.playeraltactionhint, self.playeraltactionhint_itemhighlight)
        HighlightSceneItem(self.owner.components.playercontroller.controller_attack_target, self.attackhint, self.attackhint_itemhighlight)
    end

    self.OnUpdate = function (self, dt, ...)
        if TheInput:ControllerAttached() then
            return OnUpdate_New(self, dt, ...)
        else
            return OnUpdate_Old(self, dt, ...)
        end
    end
end)