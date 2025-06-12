local FollowText = require "widgets/followtext"
local Text = require "widgets/text"

AddClassPostConstruct("widgets/controls", function(self)
    -- Help Klei Fix Bug: Actived Item Under Backpack Widget
    self.containerroot_side.parent:MoveToBack()

    -- self.playeractionhint
    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
        self.playeractionhint:SetOffset(Vector3(0, 100, 0))
    else
        self.playeractionhint:SetOffset(Vector3(0, 120, 0))
    end

    -- self.playeractionhint_itemhighlight
    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
        self.playeractionhint_itemhighlight:SetOffset(Vector3(0, 100, 0))
    else
        self.playeractionhint_itemhighlight:SetOffset(Vector3(0, 120, 0))
    end
    
    self.playeraltactionhint = self:AddChild(FollowText(TALKINGFONT, 28))
    self.playeraltactionhint:SetHUD(self.owner.HUD.inst)
    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
        self.playeraltactionhint:SetOffset(Vector3(0, 100, 0))
    else
        self.playeraltactionhint:SetOffset(Vector3(0, 120, 0))
    end
    self.playeraltactionhint:Hide()

    self.playeraltactionhint_itemhighlight = self:AddChild(FollowText(TALKINGFONT, 28))
    self.playeraltactionhint_itemhighlight:SetHUD(self.owner.HUD.inst)
    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
        self.playeraltactionhint_itemhighlight:SetOffset(Vector3(0, 100, 0))
    else
        self.playeraltactionhint_itemhighlight:SetOffset(Vector3(0, 120, 0))
    end
    self.playeraltactionhint_itemhighlight:Hide()

    -- self.attackhint
    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
        self.attackhint:SetOffset(Vector3(0, 100, 0))
    else
        self.attackhint:SetOffset(Vector3(0, 120, 0))
    end

    self.attackhint_itemhighlight = self:AddChild(FollowText(TALKINGFONT, 28))
    self.attackhint_itemhighlight:SetHUD(self.owner.HUD.inst)
    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
        self.attackhint_itemhighlight:SetOffset(Vector3(0, 100, 0))
    else
        self.attackhint_itemhighlight:SetOffset(Vector3(0, 120, 0))
    end
    self.attackhint_itemhighlight:Hide()

    -- self.groundactionhint
    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
        self.groundactionhint:SetOffset(Vector3(0, 100, 0))
    else
        self.groundactionhint:SetOffset(Vector3(0, 120, 0))
    end

    -- self.forwardactionhint
    self.forwardactionhint = self:AddChild(FollowText(TALKINGFONT, 28))
    self.forwardactionhint:SetHUD(self.owner.HUD.inst)
    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
        self.forwardactionhint:SetOffset(Vector3(0, 100, 0))
    else
        self.forwardactionhint:SetOffset(Vector3(0, 120, 0))
    end
    self.forwardactionhint:Hide()

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
            self.forwardactionhint:SetTarget(nil)
            return
        end

        local scrnw, scrnh = TheSim:GetScreenSize()
        if scrnw ~= self._scrnw or scrnh ~= self._scrnh then
            self._scrnw, self._scrnh = scrnw, scrnh
            self:SetHUDSize()
        end

        local Language_En = CHANGE_LANGUAGE_ENGLISH
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

        if controller_mode and (CHANGE_IS_USE_DPAD_SELECT_CRAFTING_MENU or not self.craftingmenu:IsCraftingOpen()) and self.owner:IsActionsVisible() and CHANGE_HIDE_THEWORLD_ITEM_HINT ~= "all" then
            local ground_l, ground_r = self.owner.components.playercontroller:GetGroundUseAction()
            local special_l = self.owner.components.playercontroller:GetGroundUseSpecialAction(nil, false)
            local special_r = self.owner.components.playercontroller:GetGroundUseSpecialAction(nil, true)
            local placer_cmds = {}
            local ground_cmds = {}
            local forward_cmds = {}
            local isplacing = self.owner.components.playercontroller.deployplacer ~= nil or self.owner.components.playercontroller.placer ~= nil
            local A_shown = false
            local Y_shown = false
            local B_shown = false
            local X_shown = false
            local Unlock_shown = false
            local Lock_shown = false
            local not_force = CHANGE_FORCE_BUTTON and CHANGE_IS_FORCE_PING_RETICULE and not TheInput:IsControlPressed(CHANGE_FORCE_BUTTON)
            local playercontroller_reticule = self.owner.components.playercontroller.reticule
            local is_reticule = playercontroller_reticule ~= nil and playercontroller_reticule.reticule ~= nil and playercontroller_reticule.reticule.entity:IsVisible()
            if isplacing then
                local placer = self.terraformplacer

                if self.owner.components.playercontroller.deployplacer ~= nil then
                    self.groundactionhint:Show()
                    self.groundactionhint:SetTarget(self.owner.components.playercontroller.deployplacer)

                    if not Y_shown and self.owner.components.playercontroller:IsAxisAlignedPlacement() then
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            table.insert(placer_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_AXISALIGNEDPLACEMENT_CYCLEGRID))
                        else
                            table.insert(placer_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_AXISALIGNEDPLACEMENT_CYCLEGRID).." "..STRINGS.UI.HUD.CYCLE_AXIS_ALIGNED_PLACEMENT)
                        end
                        Y_shown = true
                    end
                    if not A_shown and self.owner.components.playercontroller.deployplacer.components.placer.can_build then
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            table.insert(placer_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION))
                        else
                            table.insert(placer_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION) .. " " .. self.owner.components.playercontroller.deployplacer.components.placer:GetDeployAction():GetActionString())
                        end
                        A_shown = true
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            table.insert(placer_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION))
                        else
                            table.insert(placer_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..STRINGS.UI.HUD.CANCEL)
                        end
                        B_shown = true
                    elseif not B_shown then
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            table.insert(placer_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION))
                        else
                            table.insert(placer_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..STRINGS.UI.HUD.CANCEL)
                        end
                        B_shown = true
                    end

                elseif self.owner.components.playercontroller.placer ~= nil then
                    self.groundactionhint:Show()
                    self.groundactionhint:SetTarget(self.owner.components.playercontroller.placer)

                    if not Y_shown and self.owner.components.playercontroller:IsAxisAlignedPlacement() then
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            table.insert(placer_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_AXISALIGNEDPLACEMENT_CYCLEGRID))
                        else
                            table.insert(placer_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_AXISALIGNEDPLACEMENT_CYCLEGRID).." "..STRINGS.UI.HUD.CYCLE_AXIS_ALIGNED_PLACEMENT)
                        end
                        Y_shown = true
                    end
                    if not A_shown and self.owner.components.playercontroller.placer.components.placer.can_build then
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            table.insert(placer_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION))
                        else
                            table.insert(placer_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION) .. " " .. STRINGS.UI.HUD.BUILD)
                        end
                        A_shown = true
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            table.insert(placer_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION))
                        else
                            table.insert(placer_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION) .. " " .. STRINGS.UI.HUD.CANCEL)
                        end
                        B_shown = true
                    elseif not B_shown then
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            table.insert(placer_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION))
                        else
                            table.insert(placer_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION) .. " " .. STRINGS.UI.HUD.CANCEL)
                        end
                        B_shown = true
                    end
                end
                if #placer_cmds > 0 then
                    self.groundactionhint:Show()
                    self.groundactionhint.text:SetString(table.concat(placer_cmds, CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT and " " or "\n"))
                else
                    self.groundactionhint:Hide()
                end
            else
                local aoetargeting = self.owner.components.playercontroller:IsAOETargeting()
                if ground_r ~= nil then
                    if not B_shown and ground_r.action ~= ACTIONS.CASTAOE and self.owner.replica.inventory:GetActiveItem() == nil and not (not_force and is_reticule) then
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION))
                        else
                            table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..ground_r:GetActionString())
                        end
                        B_shown = true
                    elseif not A_shown and aoetargeting then
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION))
                        else
                            table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION).." "..ground_r:GetActionString())
                        end
                        A_shown = true
                    end
                end
                if not B_shown and aoetargeting then
                    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                        table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION))
                    else
                        table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..STRINGS.UI.HUD.CANCEL)
                    end
                    B_shown = true
                end
                if #ground_cmds > 0 then
                    self.groundactionhint:Show()
                    if CHANGE_FORCE_BUTTON and CHANGE_IS_FORCE_PING_RETICULE then
                        local playercontroller_reticule = self.owner.components.playercontroller.reticule
                        self.groundactionhint:SetTarget(playercontroller_reticule ~= nil and playercontroller_reticule.reticuleprefab == "reticule" and playercontroller_reticule.reticule or self.owner)
                    else
                        self.groundactionhint:SetTarget(self.owner)
                    end
                    self.groundactionhint.text:SetString(table.concat(ground_cmds, CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT and " " or "\n"))
                else
                    self.groundactionhint:Hide()
                end

                if not B_shown and not self.groundactionhint.shown then
                    local rider = self.owner.replica.rider
                    local mount = rider and rider:GetMount() or nil
                    local container = mount and mount.replica.container or nil
                    if container and container:IsOpenedBy(self.owner) then
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            self.groundactionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION))
                        else
                            self.groundactionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..BufferedAction(self.owner, self.owner, ACTIONS.RUMMAGE):GetActionString())
                        end
                        B_shown = true
                        self.groundactionhint:Show()
                        self.groundactionhint:SetTarget(self.owner)
                    elseif self.owner.components.spellbook and self.owner.components.spellbook:CanBeUsedBy(self.owner) and TheInput:IsControlPressed(CHANGE_CONTROL_OPTION) then
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            self.groundactionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION))
                        else
                            self.groundactionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..BufferedAction(self.owner, self.owner, ACTIONS.USESPELLBOOK):GetActionString())
                        end
                        B_shown = true
                        self.groundactionhint:Show()
                        self.groundactionhint:SetTarget(self.owner)
                    elseif mount and TheInput:IsControlPressed(CHANGE_CONTROL_OPTION) then
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            self.groundactionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION))
                        else
                            self.groundactionhint.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..STRINGS.ACTIONS.DISMOUNT)
                        end
                        B_shown = true
                        self.groundactionhint:Show()
                        self.groundactionhint:SetTarget(self.owner)
                    end
                end
            end

            local controller_action_is_step_forward_and_drop = false
            local controller_target = self.owner.components.playercontroller:GetControllerTarget()
            local controller_alt_target = self.owner.components.playercontroller:GetControllerAltTarget()
            local controller_attack_target = self.owner.components.playercontroller:GetControllerAttackTarget()
            local equiped_item = self.owner.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local l, r
            if controller_target ~= nil then
                l, r = self.owner.components.playercontroller:GetSceneItemControllerAction(controller_target)
            end
            if (l == nil or (CHANGE_FORCE_BUTTON and TheInput:IsControlPressed(CHANGE_FORCE_BUTTON))) and self.owner.replica.inventory:GetActiveItem() ~= nil and
                not TheWorld.Map:IsPassableAtPoint(self.owner.components.playercontroller.Change_drop_position:Get()) and
                TheWorld.Map:IsOceanTileAtPoint(self.owner.components.playercontroller.Change_drop_position:Get()) then
                controller_action_is_step_forward_and_drop = true
            end

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
                local isreadonlycontainer = cooker_type_container.replica.container ~= nil and
                                            cooker_type_container.replica.container.IsReadOnlyContainer and
                                            cooker_type_container.replica.container:IsReadOnlyContainer()
                local widget = cooker_type_container.replica.container:GetWidget()
                local cooker_type_container_widget = self.containers[cooker_type_container]
                if not isreadonlycontainer and cooker_type_container_widget ~= nil and cooker_type_container_widget.button ~= nil then
                    if not B_shown and CHANGE_FORCE_BUTTON and TheInput:IsControlPressed(CHANGE_FORCE_BUTTON) then
                        B_shown = true
                        cooker_type_container_widget.button:Show()
                        cooker_type_container_widget.button.text:SetString(TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION) .. " " .. widget.buttoninfo.text)
                    else
                        cooker_type_container_widget.button:Hide()
                    end
                end
            end

            if not isplacing and ((l == nil and alt_l == nil) or (special_l and CHANGE_IS_FORCE_PING_RETICULE and not not_force)) and ground_l == nil then
                ground_l = special_l
                if not A_shown and ground_l ~= nil then
                    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                        table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION))
                    else
                        table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION).." "..ground_l:GetActionString())
                    end
                    A_shown = true
                    self.groundactionhint:Show()
                    self.groundactionhint:SetTarget(self.owner)
                    self.groundactionhint.text:SetString(table.concat(ground_cmds, CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT and " " or "\n"))
                end
            end
            if not isplacing and ((r == nil and alt_r == nil) or (special_r and CHANGE_IS_FORCE_PING_RETICULE and not not_force)) and ground_r == nil then
                ground_r = special_r
                if not B_shown and ground_r ~= nil and self.owner.replica.inventory:GetActiveItem() == nil and not not_force then
                    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                        table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION))
                    else
                        table.insert(ground_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION).." "..ground_r:GetActionString())
                    end
                    B_shown = true
                    self.groundactionhint:Show()
                    if CHANGE_FORCE_BUTTON and CHANGE_IS_FORCE_PING_RETICULE then
                        local playercontroller_reticule = self.owner.components.playercontroller.reticule
                        self.groundactionhint:SetTarget(playercontroller_reticule ~= nil and playercontroller_reticule.reticuleprefab == "reticule" and playercontroller_reticule.reticule or self.owner)
                    else
                        self.groundactionhint:SetTarget(self.owner)
                    end
                    self.groundactionhint.text:SetString(table.concat(ground_cmds, CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT and " " or "\n"))
                end
            end
            
            if not A_shown and controller_action_is_step_forward_and_drop then
                local active_item = self.owner.replica.inventory:GetActiveItem()
                if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                    table.insert(forward_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION))
                else
                    if active_item.replica.stackable ~= nil and active_item.replica.stackable:IsStack() and TheInput:IsControlPressed(CHANGE_CONTROL_LEFT) then
                        table.insert(forward_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION).." "..STRINGS.ACTIONS.DROP.GENERIC..(Language_En and " into Sea" or "进大海")..(Language_En and " (One)" or " (一个)"))
                    else
                        table.insert(forward_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION).." "..STRINGS.ACTIONS.DROP.GENERIC..(Language_En and " into Sea" or "进大海"))
                    end
                end
                A_shown = true
                self.forwardactionhint:Show()
                self.forwardactionhint:SetTarget(self.owner)
                self.forwardactionhint.text:SetString(table.concat(forward_cmds, CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT and " " or "\n"))
            else
                self.forwardactionhint:Hide()
                self.forwardactionhint:SetTarget(nil)
            end

            if controller_target ~= nil then
                local cmds = {}

                local adjective = controller_target:GetAdjective()
                table.insert(cmds, adjective ~= nil and (adjective.." "..controller_target:GetDisplayName() .. "\n") or (controller_target:GetDisplayName() .. "\n"))

                if not Y_shown and (self.owner.CanExamine == nil or self.owner:CanExamine()) and
                    --V2C: Closing the avatar popup takes priority
                    not self.owner.HUD:IsPlayerAvatarPopUpOpen() and
                    (self.owner.sg == nil or self.owner.sg:HasStateTag("moving") or self.owner.sg:HasStateTag("idle")
                        or self.owner.sg:HasStateTag("attack") or self.owner.sg:HasStateTag("doing") or self.owner.sg:HasStateTag("working") or self.owner.sg:HasStateTag("channeling")) and
                    (self.owner:HasTag("moving") or self.owner:HasTag("idle")
                        or self.owner:HasTag("attack") or self.owner:HasTag("doing") or self.owner:HasTag("working") or self.owner:HasTag("channeling")) and
                    controller_target:HasTag("inspectable") then
                    local actionstr =
                        CLOSEINSPECTORUTIL.CanCloseInspect(self.owner, controller_target) and
                        STRINGS.ACTIONS.LOOKAT.CLOSEINSPECT or
                        STRINGS.UI.HUD.INSPECT
                    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                        table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT))
                    else
                        table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT) .. " " .. actionstr)
                    end
                    Y_shown = true
                end
                if not X_shown and controller_target == controller_attack_target then
                    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                        table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK))
                    else
                        if r ~= nil and equiped_item and equiped_item.controller_should_use_attack_target and TheInput:IsControlPressed(CHANGE_CONTROL_OPTION) and not IsOtherModEnabled("Snapping tills") then
                            table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. r:GetActionString())
                        else
                            table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. STRINGS.UI.HUD.ATTACK)
                        end
                    end
                    X_shown = true
                end
                if not A_shown and l ~= nil then
                    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                        table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION))
                    else
                        table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ACTION) .. " " .. l:GetActionString())
                    end
                    A_shown = true
                end
                if not B_shown and r ~= nil and controller_target == controller_alt_target then
                    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                        table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION))
                    else
                        table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION) .. " " .. r:GetActionString())
                    end
                    B_shown = true
                end
                if (not Lock_shown or not Unlock_shown) and controller_target == controller_attack_target and self.owner.components.playercontroller:CanLockTargets() then
                    if not Unlock_shown and self.owner.components.playercontroller:IsControllerTargetLocked() then
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_TARGET_LOCK))
                        else
                            table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_TARGET_LOCK) .. " " .. STRINGS.UI.HUD.UNLOCK_TARGET)
                        end
                        Unlock_shown = true
                    elseif not Lock_shown then
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_TARGET_LOCK))
                        else
                            table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_TARGET_LOCK) .. " " .. STRINGS.UI.HUD.LOCK_TARGET)
                        end
                        Lock_shown = true
                    end
                end
                if not Lock_shown and controller_target ~= controller_attack_target and self.owner.components.playercontroller:IsTargetCanBeLock(controller_target) then
                    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                        table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_TARGET_LOCK))
                    else
                        table.insert(cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_TARGET_LOCK) .. " " .. STRINGS.UI.HUD.LOCK_TARGET)
                    end
                    Lock_shown = true
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
                    self.playeractionhint.text:SetString(table.concat(cmds, CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT and " " or "\n"))
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
                table.insert(alt_cmds, adjective ~= nil and (adjective .. controller_alt_target:GetDisplayName() .. "\n") or (controller_alt_target:GetDisplayName() .. "\n"))

                if not Y_shown and (self.owner.CanExamine == nil or self.owner:CanExamine()) and
                    --V2C: Closing the avatar popup takes priority
                    not self.owner.HUD:IsPlayerAvatarPopUpOpen() and
                    (self.owner.sg == nil or self.owner.sg:HasStateTag("moving") or self.owner.sg:HasStateTag("idle")
                        or self.owner.sg:HasStateTag("attack") or self.owner.sg:HasStateTag("doing") or self.owner.sg:HasStateTag("working") or self.owner.sg:HasStateTag("channeling")) and
                    (self.owner:HasTag("moving") or self.owner:HasTag("idle")
                        or self.owner:HasTag("attack") or self.owner:HasTag("doing") or self.owner:HasTag("working") or self.owner:HasTag("channeling")) and
                    controller_alt_target:HasTag("inspectable") then
                    local actionstr =
                        CLOSEINSPECTORUTIL.CanCloseInspect(self.owner, controller_alt_target) and
                        STRINGS.ACTIONS.LOOKAT.CLOSEINSPECT or
                        STRINGS.UI.HUD.INSPECT
                    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                        table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT))
                    else
                        table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT) .. " " .. actionstr)
                    end
                    Y_shown = true
                end

                if not X_shown and controller_alt_target == controller_attack_target then
                    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                        table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK))
                    else
                        if alt_r ~= nil and equiped_item and equiped_item.controller_should_use_attack_target and TheInput:IsControlPressed(CHANGE_CONTROL_OPTION) and not IsOtherModEnabled("Snapping tills") then
                            table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. alt_r:GetActionString())
                        else
                            table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. STRINGS.UI.HUD.ATTACK)
                        end
                    end
                    X_shown = true
                end
                if not B_shown and alt_r ~= nil then
                    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                        table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION))
                    else
                        table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION) .. " " .. alt_r:GetActionString())
                    end
                    B_shown = true
                end
                if (not Lock_shown or not Unlock_shown) and controller_alt_target == controller_attack_target and self.owner.components.playercontroller:CanLockTargets() then
                    if not Unlock_shown and self.owner.components.playercontroller:IsControllerTargetLocked() then
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_TARGET_LOCK))
                        else
                            table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_TARGET_LOCK) .. " " .. STRINGS.UI.HUD.UNLOCK_TARGET)
                        end
                        Unlock_shown = true
                    elseif not Lock_shown then
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_TARGET_LOCK))
                        else
                            table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_TARGET_LOCK) .. " " .. STRINGS.UI.HUD.LOCK_TARGET)
                        end
                        Lock_shown = true
                    end
                end
                if not Lock_shown and controller_alt_target ~= controller_attack_target and self.owner.components.playercontroller:IsTargetCanBeLock(controller_alt_target) then
                    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                        table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_TARGET_LOCK))
                    else
                        table.insert(alt_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_TARGET_LOCK) .. " " .. STRINGS.UI.HUD.LOCK_TARGET)
                    end
                    Lock_shown = true
                end

                if #alt_cmds > 1 then
                    self.playeraltactionhint:Show()
                    self.playeraltactionhint:SetTarget(controller_alt_target)
                    self.playeraltactionhint.text:SetString(table.concat(alt_cmds, CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT and " " or "\n"))
                else
                    self.playeraltactionhint:Hide()
                    self.playeraltactionhint:SetTarget(nil)
                end
            else
                self.playeraltactionhint:Hide()
                self.playeraltactionhint:SetTarget(nil)
            end

            if controller_attack_target ~= nil then
                local attack_cmds = {}

                local adjective = controller_attack_target:GetAdjective()
                table.insert(attack_cmds, adjective ~= nil and (adjective .. controller_attack_target:GetDisplayName() .. "\n") or (controller_attack_target:GetDisplayName() .. "\n"))

                if not Y_shown and (self.owner.CanExamine == nil or self.owner:CanExamine()) and
                    --V2C: Closing the avatar popup takes priority
                    not self.owner.HUD:IsPlayerAvatarPopUpOpen() and
                    (self.owner.sg == nil or self.owner.sg:HasStateTag("moving") or self.owner.sg:HasStateTag("idle")
                        or self.owner.sg:HasStateTag("attack") or self.owner.sg:HasStateTag("doing") or self.owner.sg:HasStateTag("working") or self.owner.sg:HasStateTag("channeling")) and
                    (self.owner:HasTag("moving") or self.owner:HasTag("idle")
                        or self.owner:HasTag("attack") or self.owner:HasTag("doing") or self.owner:HasTag("working") or self.owner:HasTag("channeling")) and
                    controller_attack_target:HasTag("inspectable") then
                    local actionstr =
                        CLOSEINSPECTORUTIL.CanCloseInspect(self.owner, controller_attack_target) and
                        STRINGS.ACTIONS.LOOKAT.CLOSEINSPECT or
                        STRINGS.UI.HUD.INSPECT
                    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                        table.insert(attack_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT))
                    else
                        table.insert(attack_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_INSPECT) .. " " .. actionstr)
                    end
                    Y_shown = true
                end
                if not X_shown then
                    if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                        table.insert(attack_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK))
                    else
                        if atk_r and equiped_item and equiped_item.controller_should_use_attack_target and TheInput:IsControlPressed(CHANGE_CONTROL_OPTION) and not IsOtherModEnabled("Snapping tills") then
                            table.insert(attack_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. atk_r:GetActionString())
                        else
                            table.insert(attack_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ATTACK) .. " " .. STRINGS.UI.HUD.ATTACK)
                        end
                    end
                    X_shown = true
                end
                if (not Lock_shown or not Unlock_shown) and self.owner.components.playercontroller:CanLockTargets() then
                    if not Unlock_shown and self.owner.components.playercontroller:IsControllerTargetLocked() then
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            table.insert(attack_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_TARGET_LOCK))
                        else
                            table.insert(attack_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_TARGET_LOCK) .. " " .. STRINGS.UI.HUD.UNLOCK_TARGET)
                        end
                        Unlock_shown = true
                    elseif not Lock_shown and not self.owner.components.playercontroller:IsControllerTargetLocked() then
                        if CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT then
                            table.insert(attack_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_TARGET_LOCK))
                        else
                            table.insert(attack_cmds, TheInput:GetLocalizedControl(controller_id, CONTROL_TARGET_LOCK) .. " " .. STRINGS.UI.HUD.LOCK_TARGET)
                        end
                        Lock_shown = true
                    end
                end

                if #attack_cmds > 1 then
                    self.attackhint:Show()
                    self.attackhint:SetTarget(controller_attack_target)
                    self.attackhint.text:SetString(table.concat(attack_cmds, CHANGE_THEWORLD_ITEM_HINT_REMOVE_ACTION_TEXT and " " or "\n"))
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

            self.forwardactionhint:Hide()
            self.forwardactionhint:SetTarget(nil)
        end

        --default offsets
        self.playeractionhint:SetScreenOffset(0,0)
        self.playeraltactionhint:SetScreenOffset(0,0)
        self.attackhint:SetScreenOffset(0,0)
        self.groundactionhint:SetScreenOffset(0,0)
        self.forwardactionhint:SetScreenOffset(0,0)

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

        AdjustLocation(true, self.playeractionhint, self.forwardactionhint)
        AdjustLocation(true, self.playeraltactionhint, self.forwardactionhint)
        AdjustLocation(true, self.attackhint, self.forwardactionhint)
        AdjustLocation(true, self.groundactionhint, self.forwardactionhint)

        if IsOtherModEnabled("Insight (Show Me+)") then
            if self.owner.components.playercontroller.controller_target and self.playeractionhint.text.string ~= nil then
                self.HighlightActionItem(self, true, true)
            else
                if self.primaryInsightText then
                    self.primaryInsightText:Hide()
                    self.primaryInsightText:SetTarget(nil)
                end
                if self.primaryInsightText2 then
                    self.primaryInsightText2:Hide()
                    self.primaryInsightText2:SetTarget(nil)
                end
            end
        end
        HighlightSceneItem(self.owner.components.playercontroller.controller_target, self.playeractionhint, self.playeractionhint_itemhighlight)
        HighlightSceneItem(self.owner.components.playercontroller.controller_alt_target, self.playeraltactionhint, self.playeraltactionhint_itemhighlight)
        HighlightSceneItem(self.owner.components.playercontroller.controller_attack_target, self.attackhint, self.attackhint_itemhighlight)

        -- Compatible with "GestureWheel"
        if TheInput:IsControlPressed(CONTROL_MENU_MISC_3) and self.gesturewheel then
            self.gesturewheel:OnUpdate()
        end
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

            self.forwardactionhint:Hide()
            self.forwardactionhint:SetTarget(nil)
            return OnUpdate_Old(self, dt, ...)
        end
    end

end)