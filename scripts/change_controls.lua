local FollowText = require "widgets/followtext"
local Text = require "widgets/text"

AddClassPostConstruct("widgets/controls", function(self)
    -- Help Klei Fix Bug: Actived Item Under Backpack Widget
    self.containerroot_side.parent:MoveToBack()

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
            if controller_mode and not self.craftingmenu:IsCraftingOpen() and TheInput:IsControlPressed(CHANGE_CONTROL_LEFT) then
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

        if controller_mode and (CHANGE_IS_USE_DPAD_SELECT_CRAFTING_MENU or not self.craftingmenu:IsCraftingOpen()) and self.owner:IsActionsVisible() and not CHANGE_HIDE_THEWORLD_ITEM_HINT then
            local ground_l, ground_r = self.owner.components.playercontroller:GetGroundUseAction()
            local ground_cmds = {}
            local isplacing = self.owner.components.playercontroller.deployplacer ~= nil or self.owner.components.playercontroller.placer ~= nil
            local A_shown = false
            local Y_shown = false
            local B_shown = false
            local X_shown = false
            local Unlock_shown = false
            local not_force = CHANGE_FORCE_BUTTON and CHANGE_IS_FORCE_PING_RETICULE and not TheInput:IsControlPressed(CHANGE_FORCE_BUTTON)
            local playercontroller_reticule = self.owner.components.playercontroller.reticule
            local is_reticule = playercontroller_reticule ~= nil and playercontroller_reticule.reticule ~= nil and playercontroller_reticule.reticule.entity:IsVisible()
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
                    if ground_r.action ~= ACTIONS.CASTAOE and not (not_force and is_reticule) then
                        table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..ground_r:GetActionString())
                        B_shown = true
                    elseif aoetargeting then
                        table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION).." "..ground_r:GetActionString())
                    end
                end
                if aoetargeting then
                    table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..STRINGS.UI.HUD.CANCEL)
                end
                if #ground_cmds > 0 then
                    self.groundactionhint:Show()
                    if CHANGE_FORCE_BUTTON and CHANGE_IS_FORCE_PING_RETICULE then
                        local playercontroller_reticule = self.owner.components.playercontroller.reticule
                        self.groundactionhint:SetTarget(playercontroller_reticule ~= nil and playercontroller_reticule.reticuleprefab == "reticule" and playercontroller_reticule.reticule or self.owner)
                    else
                        self.groundactionhint:SetTarget(self.owner)
                    end
                    self.groundactionhint.text:SetString(table.concat(ground_cmds, "\n"))
                else
                    self.groundactionhint:Hide()
                end
            end

            local controller_action_from_space = false
            local controller_target = self.owner.components.playercontroller:GetControllerTarget()
            local controller_alt_target = self.owner.components.playercontroller:GetControllerAltTarget()
            local controller_attack_target = self.owner.components.playercontroller:GetControllerAttackTarget()
            local equiped_item = self.owner.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local l, r
            if controller_target ~= nil then
                l, r = self.owner.components.playercontroller:GetSceneItemControllerAction(controller_target)
                if CHANGE_FORCE_BUTTON and CHANGE_IS_FORCE_SPACE_ACTION and TheInput:IsControlPressed(CHANGE_FORCE_BUTTON) and TheInput:IsControlPressed(CHANGE_FORCE_BUTTON_LEVEL2) then
                    l = self.owner.components.playercontroller:GetActionButtonAction()
                    controller_action_from_space = true
                end
            end
            local action_string_from_keyboard = controller_action_from_space and " ("..STRINGS.UI.CONTROLSSCREEN.INPUTS[1][32] ..") " or " "

            local alt_l, alt_r
            if controller_alt_target ~= nil then
                alt_l, alt_r = self.owner.components.playercontroller:GetSceneItemControllerAction(controller_alt_target)
            end

            local atk_l, atk_r
            if controller_attack_target ~= nil then
                atk_l, atk_r = self.owner.components.playercontroller:GetSceneItemControllerAction(controller_attack_target)
            end

            -- Show cooker type container force interaction
            local cooker_type_container = self.owner.components.playercontroller:TryWidgetButtonFunction(false)
            if cooker_type_container ~= nil then
                local widget = cooker_type_container.replica.container:GetWidget()
                local cooker_type_container_widget = self.containers[cooker_type_container]
                if cooker_type_container_widget ~= nil and cooker_type_container_widget.button ~= nil then
                    if CHANGE_FORCE_BUTTON and TheInput:IsControlPressed(CHANGE_FORCE_BUTTON) then
                        B_shown = true
                        cooker_type_container_widget.button:Show()
                        cooker_type_container_widget.button.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION) .. " " .. widget.buttoninfo.text)
                    else
                        cooker_type_container_widget.button:Hide()
                    end
                end
            end

            if not isplacing and l == nil and alt_l == nil and ground_l == nil then
                ground_l = self.owner.components.playercontroller:GetGroundUseSpecialAction(nil, false)
                if ground_l ~= nil then
                    table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION).." "..ground_l:GetActionString())
                    A_shown = true
                    self.groundactionhint:Show()
                    self.groundactionhint:SetTarget(self.owner)
                    self.groundactionhint.text:SetString(table.concat(ground_cmds, "\n"))
                end
            end
            if not isplacing and r == nil and alt_r == nil and ground_r == nil then
                ground_r = self.owner.components.playercontroller:GetGroundUseSpecialAction(nil, true)
                if not B_shown and ground_r ~= nil and not (not_force and is_reticule)then
                    table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..ground_r:GetActionString())
                    B_shown = true
                    self.groundactionhint:Show()
                    if CHANGE_FORCE_BUTTON and CHANGE_IS_FORCE_PING_RETICULE then
                        local playercontroller_reticule = self.owner.components.playercontroller.reticule
                        self.groundactionhint:SetTarget(playercontroller_reticule ~= nil and playercontroller_reticule.reticuleprefab == "reticule" and playercontroller_reticule.reticule or self.owner)
                    else
                        self.groundactionhint:SetTarget(self.owner)
                    end
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
                    local actionstr =
                        CLOSEINSPECTORUTIL.CanCloseInspect(self.owner, controller_target) and
                        STRINGS.ACTIONS.LOOKAT.CLOSEINSPECT or
                        STRINGS.UI.HUD.INSPECT
                    table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT) .. " " .. actionstr)
                    Y_shown = true
                end
                if not X_shown and controller_target == controller_attack_target then
                    if r ~= nil and equiped_item and equiped_item.controller_should_use_attack_target and
                        not (CHANGE_FORCE_BUTTON and TheInput:IsControlPressed(CHANGE_FORCE_BUTTON) and TheInput:IsControlPressed(CHANGE_FORCE_BUTTON_LEVEL2)) then
                        table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. r:GetActionString())
                    else
                        table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. STRINGS.UI.HUD.ATTACK)
                    end
                    X_shown = true
                end
                if not A_shown and l ~= nil then
                    table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION) .. action_string_from_keyboard .. l:GetActionString())
                    A_shown = true
                end
                if not B_shown and r ~= nil and controller_target == controller_alt_target then
                    table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION) .. " " .. r:GetActionString())
                    B_shown = true
                end
                if not Unlock_shown and controller_target == controller_attack_target and self.owner.components.playercontroller:IsControllerTargetLocked() then
                    table.insert(cmds, CHANGE_IS_LOCK_TARGET_QUICKLY
                        and TheInput:GetLocalizedControl(controller_id, CHANGE_FORCE_BUTTON) .."+".. TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.HUD.UNLOCK_TARGET
                        or STRINGS.UI.WORLDRESETDIALOG.BUTTONPROMPT1 .. TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.HUD.UNLOCK_TARGET)
                    Unlock_shown = true
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
                    local actionstr =
                        CLOSEINSPECTORUTIL.CanCloseInspect(self.owner, controller_alt_target) and
                        STRINGS.ACTIONS.LOOKAT.CLOSEINSPECT or
                        STRINGS.UI.HUD.INSPECT
                    table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT) .. " " .. actionstr)
                    Y_shown = true
                end

                if not X_shown and controller_alt_target == controller_attack_target then
                    if alt_r ~= nil and equiped_item and equiped_item.controller_should_use_attack_target and
                        not (CHANGE_FORCE_BUTTON and TheInput:IsControlPressed(CHANGE_FORCE_BUTTON) and TheInput:IsControlPressed(CHANGE_FORCE_BUTTON_LEVEL2)) then
                        table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. alt_r:GetActionString())
                    else
                        table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. STRINGS.UI.HUD.ATTACK)
                    end
                    X_shown = true
                end
                if not B_shown and alt_r ~= nil then
                    table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION) .. " " .. alt_r:GetActionString())
                    B_shown = true
                end
                if not Unlock_shown and controller_alt_target == controller_attack_target and self.owner.components.playercontroller:IsControllerTargetLocked() then
                    table.insert(alt_cmds, CHANGE_IS_LOCK_TARGET_QUICKLY
                        and TheInput:GetLocalizedControl(controller_id, CHANGE_FORCE_BUTTON) .."+".. TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.HUD.UNLOCK_TARGET
                        or STRINGS.UI.WORLDRESETDIALOG.BUTTONPROMPT1 .. TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.HUD.UNLOCK_TARGET)
                    Unlock_shown = true
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

            if not B_shown and not self.groundactionhint.shown then
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
                    local actionstr =
                        CLOSEINSPECTORUTIL.CanCloseInspect(self.owner, controller_attack_target) and
                        STRINGS.ACTIONS.LOOKAT.CLOSEINSPECT or
                        STRINGS.UI.HUD.INSPECT
                    table.insert(attack_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT) .. " " .. actionstr)
                    Y_shown = true
                end
                if not X_shown then
                    if atk_r and equiped_item and equiped_item.controller_should_use_attack_target and
                        not (CHANGE_FORCE_BUTTON and TheInput:IsControlPressed(CHANGE_FORCE_BUTTON) and TheInput:IsControlPressed(CHANGE_FORCE_BUTTON_LEVEL2)) then
                        table.insert(attack_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. atk_r:GetActionString())
                    else
                        table.insert(attack_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. STRINGS.UI.HUD.ATTACK)
                    end
                    X_shown = true
                end
                if not Unlock_shown and self.owner.components.playercontroller:IsControllerTargetLocked() then
                    table.insert(attack_cmds, CHANGE_IS_LOCK_TARGET_QUICKLY
                        and TheInput:GetLocalizedControl(controller_id, CHANGE_FORCE_BUTTON) .."+".. TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.HUD.UNLOCK_TARGET
                        or STRINGS.UI.WORLDRESETDIALOG.BUTTONPROMPT1 .. TheInput:GetLocalizedControl(controller_id, CONTROL_MENU_MISC_2) .. " " .. STRINGS.UI.HUD.UNLOCK_TARGET)
                    Unlock_shown = true
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