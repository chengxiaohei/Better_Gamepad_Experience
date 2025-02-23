local PlayerHud = require "screens/playerhud"
local PauseScreen = require "screens/redux/pausescreen"
local ChatInputScreen = require "screens/chatinputscreen"
local ContainerWidget = require("widgets/containerwidget")

AddClassPostConstruct("screens/playerhud", function(self)
    local OnControl_Old = self.OnControl
    local OnControl_New = function (self, control, down, ...)
        if PlayerHud._base.OnControl(self, control, down) then
            return true
        elseif not self.shown then
            if self.serverpaused and down and control == CONTROL_SERVER_PAUSE then
                SetServerPaused(false)
                return true
            end
            return
        end

        if down then
            if control == CONTROL_INSPECT then
                if not TryTriggerMappingKey(self.owner, CHANGE_MAPPING_LB_Y, CHANGE_MAPPING_RB_Y, CHANGE_MAPPING_LB_RB_Y, true) and
                    not TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_Y, CHANGE_MAPPING_RB_Y, CHANGE_MAPPING_LB_RB_Y, down, true) and
                    not TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_Y, CHANGE_MAPPING_RB_Y, CHANGE_MAPPING_LB_RB_Y, not down, false) then
                    if self.controls.votedialog:CheckControl(control, down) then
                        return true
                    end
                    if self:IsVisible() and
                        self:IsPlayerInfoPopUpOpen() and
                        self.owner.components.playercontroller:IsEnabled() then
                        self:TogglePlayerInfoPopup()
                        return true
                    elseif self.controls.votedialog:CheckControl(control, down) then
                        return true
                    elseif (not CHANGE_IS_FORBID_Y_INSPECT_SELF or
                        (self.controls.skilltree_notification ~= nil and self.controls.skilltree_notification.controller_help ~= nil and self.controls.skilltree_notification.controller_help.shown))
                        and self.owner.components.playercontroller:GetControllerTarget() == nil
                        and self.owner.components.playercontroller:GetControllerAltTarget() == nil
                        and self.owner.components.playercontroller:GetControllerAttackTarget() == nil
                        and self:InspectSelf() then
                        return true
                    end
                end
            elseif control == CONTROL_INSPECT_SELF and self:InspectSelf() then
                return true
            elseif control == CONTROL_MAP then
                if not TryTriggerMappingKey(self.owner, CHANGE_MAPPING_LB_BACK, CHANGE_MAPPING_RB_BACK, CHANGE_MAPPING_LB_RB_BACK, true) then
                    TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_BACK, CHANGE_MAPPING_RB_BACK, CHANGE_MAPPING_LB_RB_BACK, down, true)
                end
            elseif control == CONTROL_PAUSE then
                if not TryTriggerMappingKey(self.owner, CHANGE_MAPPING_LB_START, CHANGE_MAPPING_RB_START, CHANGE_MAPPING_LB_RB_START, true) then
                    TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_START, CHANGE_MAPPING_RB_START, CHANGE_MAPPING_LB_RB_START, down, true)
                end
            elseif control == CONTROL_MENU_MISC_3 then
                if not TryTriggerMappingKey(self.owner, CHANGE_MAPPING_LB_LSTICK, CHANGE_MAPPING_RB_LSTICK, CHANGE_MAPPING_LB_RB_LSTICK, true) then
                    TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_LSTICK, CHANGE_MAPPING_RB_LSTICK, CHANGE_MAPPING_LB_RB_LSTICK, down, true)
                end
            elseif control == CONTROL_MENU_MISC_4 then
                if not TryTriggerMappingKey(self.owner, CHANGE_MAPPING_LB_RSTICK, false, CHANGE_MAPPING_LB_RB_RSTICK, true) and
                    not TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_RSTICK, false, CHANGE_MAPPING_LB_RB_RSTICK, down, true) and
                    not TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_RSTICK, false, CHANGE_MAPPING_LB_RB_RSTICK, not down, false) then
                    if TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
                        if self.owner.components.playercontroller.reticule then
                            self.owner.components.playercontroller.reticule.clear_memory_flag = true
                            self.owner.components.playercontroller.reticule.twinstickx_mode1 = nil
                            self.owner.components.playercontroller.reticule.twinstickz_mode1 = nil
                            self.owner.components.playercontroller.reticule.twinstickoverride_mode1 = nil
                        end
                    end
                end
            elseif control == CONTROL_INVENTORY_EXAMINE then
                if not TryTriggerMappingKey(self.owner, CHANGE_MAPPING_LB_UP, CHANGE_MAPPING_RB_UP, CHANGE_MAPPING_LB_RB_UP, true) then
                    TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_UP, CHANGE_MAPPING_RB_UP, CHANGE_MAPPING_LB_RB_UP, down, true)
                end
            elseif control == CONTROL_OPEN_INVENTORY then
                if not TryTriggerMappingKey(self.owner, false, CHANGE_MAPPING_RB_RT, CHANGE_MAPPING_LB_RB_RT, true) then
                    TryTriggerKeyboardMappingKey(false, CHANGE_MAPPING_RB_RT, CHANGE_MAPPING_LB_RB_RT, down, true)
                end
            end
        elseif control == CONTROL_PAUSE then
            if not TryTriggerMappingKey(self.owner, CHANGE_MAPPING_LB_START, CHANGE_MAPPING_RB_START, CHANGE_MAPPING_LB_RB_START, false) and
                not TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_START, CHANGE_MAPPING_RB_START, CHANGE_MAPPING_LB_RB_START, not down, false) and
                not TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_START, CHANGE_MAPPING_RB_START, CHANGE_MAPPING_LB_RB_START, down, true) then
                -- Do things below at the moment we release CONTROL_PAUSE button if no mapping key triggered while press down CONTROL_PAUSE button
                self.owner.components.playercontroller:CancelAOETargeting()
                self:CloseCrafting()
                self:CloseSpellWheel()
                if self:IsControllerInventoryOpen() then
                    self:CloseControllerInventory()
                end
                TheFrontEnd:PushScreen(PauseScreen())
            end
            return true
        elseif control == CONTROL_CRAFTING_PINLEFT then
            if self.controls ~= nil and self.controls.craftingmenu ~= nil and self.controls.craftingmenu.pinbar ~= nil then
                self.controls.craftingmenu.pinbar:GoToPrevPage()
                return true
            end
        elseif control == CONTROL_CRAFTING_PINRIGHT then
            if self.controls ~= nil and self.controls.craftingmenu ~= nil and self.controls.craftingmenu.pinbar ~= nil then
                self.controls.craftingmenu.pinbar:GoToNextPage()
                return true
            end
        elseif control == CONTROL_SERVER_PAUSE then
            SetServerPaused()
            return true
        elseif control == CONTROL_INSPECT then
            return TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_Y, CHANGE_MAPPING_RB_Y, CHANGE_MAPPING_LB_RB_Y, down, true)
        elseif control == CONTROL_OPEN_INVENTORY then
            return TryTriggerKeyboardMappingKey(false, CHANGE_MAPPING_RB_RT, CHANGE_MAPPING_LB_RB_RT, down, true)
        elseif control == CONTROL_MENU_MISC_3 then
            return TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_LSTICK, CHANGE_MAPPING_RB_LSTICK, CHANGE_MAPPING_LB_RB_LSTICK, down, true)
        elseif control == CONTROL_INVENTORY_EXAMINE then
            return TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_UP, CHANGE_MAPPING_RB_UP, CHANGE_MAPPING_LB_RB_UP, down, true)
        end

        --V2C: This kinda hax? Cuz we don't rly want to set focus to it I guess?
        local resurrectbutton = self.controls.status:GetResurrectButton()
        if resurrectbutton ~= nil and resurrectbutton:CheckControl(control, down) then
            return true
        elseif self.controls.item_notification:CheckControl(control, down) then
            return true
        elseif self.controls.skilltree_notification:CheckControl(control, down) then
            return true        
        elseif not down then
            if control == CONTROL_MAP then
                if not TryTriggerMappingKey(self.owner, CHANGE_MAPPING_LB_BACK, CHANGE_MAPPING_RB_BACK, CHANGE_MAPPING_LB_RB_BACK, false) and
                    not TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_BACK, CHANGE_MAPPING_RB_BACK, CHANGE_MAPPING_LB_RB_BACK, not down, false) and
                    not TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_BACK, CHANGE_MAPPING_RB_BACK, CHANGE_MAPPING_LB_RB_BACK, down, true) then
                    -- Do things below at the moment we release CONTROL_PAUSE button if no mapping key triggered while press down CONTROL_PAUSE button
                    if not self:IsMapScreenOpen() then
                        self:CloseCrafting()
                        self:CloseSpellWheel()
                        if self:IsControllerInventoryOpen() then
                            self:CloseControllerInventory()
                        end
                    end
                    self.controls:ToggleMap()
                end
                return true
            elseif control == CONTROL_CANCEL and TheInput:ControllerAttached() then
                if self:IsCraftingOpen() and not CHANGE_IS_USE_DPAD_SELECT_CRAFTING_MENU then
                    self:CloseCrafting()
                    return true
                elseif self:IsSpellWheelOpen() and not CHANGE_IS_USE_DPAD_SELECT_SPELLWHEEL_ITEM then
                    self:CloseSpellWheel()
                    return true
                elseif self:IsControllerInventoryOpen() then
                    self:CloseControllerInventory()
                    return true
                end
            elseif control == CONTROL_TOGGLE_PLAYER_STATUS then
                if not TryTriggerMappingKey(self.owner, CHANGE_MAPPING_LB_RSTICK, false, CHANGE_MAPPING_LB_RB_RSTICK, false) and
                    not TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_RSTICK, false, CHANGE_MAPPING_LB_RB_RSTICK, not down, false) and
                    not TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_RSTICK, false, CHANGE_MAPPING_LB_RB_RSTICK, down, true) then
                    -- Do things below at the moment we release CONTROL_PAUSE button if no mapping key triggered while press down CONTROL_PAUSE button
                    if not self.owner.components.playercontroller.reticule or
                        not self.owner.components.playercontroller.reticule.clear_memory_flag then
                        self:ShowPlayerStatusScreen(true)
                    end
                end
                -- Re-Enable reticule control
                if self.owner.components.playercontroller.reticule then
                    self.owner.components.playercontroller.reticule.clear_memory_flag = false
                end
                return true
            elseif control == CONTROL_TOGGLE_SAY then
                TheFrontEnd:PushScreen(ChatInputScreen(false))
                return true
            elseif control == CONTROL_TOGGLE_WHISPER then
                TheFrontEnd:PushScreen(ChatInputScreen(true))
                return true
            elseif control == CONTROL_TOGGLE_SLASH_COMMAND then
                local chat_input_screen = ChatInputScreen(false)
                chat_input_screen.chat_edit:SetString("/")
                TheFrontEnd:PushScreen(chat_input_screen)
                return true
            elseif control == CONTROL_START_EMOJI then
                local chat_input_screen = ChatInputScreen(false)
                chat_input_screen.chat_edit:SetString(":")
                TheFrontEnd:PushScreen(chat_input_screen)
                return true
            elseif control == CONTROL_OPEN_CRAFTING then
                return TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_LT, CHANGE_MAPPING_RB_LT, CHANGE_MAPPING_LB_RB_LT, down, true)
            end
        elseif control == CONTROL_SHOW_PLAYER_STATUS then
            if not self:IsPlayerAvatarPopUpOpen() or self.playeravatarpopup.settled then
                self:ShowPlayerStatusScreen()
            end
            return true
        elseif control == CONTROL_OPEN_CRAFTING then
            if not TryTriggerMappingKey(self.owner, CHANGE_MAPPING_LB_LT, CHANGE_MAPPING_RB_LT, CHANGE_MAPPING_LB_RB_LT, true) and
                not TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_LT, CHANGE_MAPPING_RB_LT, CHANGE_MAPPING_LB_RB_LT, down, true) and
                not TryTriggerKeyboardMappingKey(CHANGE_MAPPING_LB_LT, CHANGE_MAPPING_RB_LT, CHANGE_MAPPING_LB_RB_LT, not down, false) then
                if self:IsCraftingOpen() then
                    if TheInput:IsControlPressed(CONTROL_CRAFTING_MODIFIER) then
                        self.controls.craftingmenu.craftingmenu:StartSearching(true)
                    else
                        self:CloseCrafting()
                    end
                    return true
                elseif not GetGameModeProperty("no_crafting") then
                    local inventory = self.owner.replica.inventory
                    if inventory ~= nil and inventory:IsVisible() then
                        self:OpenCrafting(TheInput:IsControlPressed(CONTROL_CRAFTING_MODIFIER))
                        return true
                    end
                end
            end
        end
    end

    self.OnControl = function (self, control, down, ...)
        if TheInput:ControllerAttached() then
            if control == CONTROL_PAUSE and CHANGE_FORCE_BUTTON and CHANGE_IS_FORCE_PAUSE_QUICKLY and TheInput:IsControlPressed(CHANGE_FORCE_BUTTON) and not TheInput:IsControlPressed(CHANGE_FORCE_BUTTON_LEVEL2) then
                control = CONTROL_SERVER_PAUSE
            end
            return OnControl_New(self, control, down, ...)
        end
        return OnControl_Old(self, control, down, ...)
    end

    -- Not Changed
    local function OpenContainerWidget(self, container, side)
        local containerwidget = ContainerWidget(self.owner)
        local parent = side and self.controls.containerroot_side
                        or (container.replica.container ~= nil and container.replica.container.type == "hand_inv") and self.controls.inv.hand_inv
                        or (container.replica.container ~= nil and container.replica.container.type == "side_inv") and self.controls.secondary_status.side_inv
                        or (container.replica.container ~= nil and container.replica.container.type == "side_inv_behind") and self.controls.containerroot_side_behind
                        or self.controls.containerroot
        parent:AddChild(containerwidget)

        --self.controls[side and "containerroot_side" or "containerroot"]:AddChild(containerwidget)
        --self.controls.bottom_root:AddChild(containerwidget)
        --self.controls.inv.hand_inv:AddChild(containerwidget)

        containerwidget:MoveToBack()
        containerwidget:Open(container, self.owner)
        self.controls.containers[container] = containerwidget

        if parent == self.controls.containerroot then
            self:CloseSpellWheel()
        end
    end

	local OpenContainer_Old = self.OpenContainer
    local OpenContainer_New = function (self, container, side)
        if container == nil then
            return
        elseif side and Profile:GetIntegratedBackpack() then
            self.controls.inv.rebuild_pending = true
        else
            OpenContainerWidget(self, container, side)
        end
    end

    self.OpenContainer = function (self, container, side, ...)
        if TheInput:ControllerAttached() then
            OpenContainer_New(self, container, side)
        else
            OpenContainer_Old(self, container, side, ...)
        end
    end

    -- Not Changed
    local function CloseContainerWidget(self, container, side)
        for k, v in pairs(self.controls.containers) do
            if v.container == container then
                v:Close()
            end
        end
    end

	local CloseContainer_Old = self.CloseContainer
    local CloseContainer_New = function (self, container, side)
        if container == nil then
            return
        elseif side and Profile:GetIntegratedBackpack() then
            self.controls.inv.rebuild_pending = true
        else
            CloseContainerWidget(self, container, side)
        end
    end

    self.CloseContainer = function (self, container, side, ...)
        if TheInput:ControllerAttached() then
            CloseContainer_New(self, container, side)
        else
            CloseContainer_Old(self, container, side, ...)
        end
    end

    -- Make it work right while change form switch between separated and integrated
    -- Make it work right while change controller from gamepad to keyboard 
    local RefreshControllers_Old = self.RefreshControllers
    local RefreshControllers_New = function (self)
        local controller_mode = TheInput:ControllerAttached()
        if controller_mode then
            TheFrontEnd:StopTrackingMouse()
        end

        TheFrontEnd:UpdateRepeatDelays()

        -- =============================================================================== --
        -- local integrated_backpack = controller_mode or Profile:GetIntegratedBackpack()
        local integrated_backpack = Profile:GetIntegratedBackpack()
        -- =============================================================================== --
        -- ============================================================================================================================== --
        -- if self.controls.inv.controller_build ~= controller_mode or self.controls.inv.integrated_backpack ~= integrated_backpack then
        if self.controls.inv.integrated_backpack ~= integrated_backpack then
        -- ============================================================================================================================== --
            self.controls.inv.rebuild_pending = true
            local overflow = self.owner.replica.inventory:GetOverflowContainer()
            if overflow == nil then
                --switching to controller inv with no backpack
                --don't animate out from the backpack position
                self.controls.inv.rebuild_snapping = true
            
            -- =============================================================================== --
            -- elseif controller_mode or integrated_backpack then
            elseif integrated_backpack then
            -- =============================================================================== --
                --switching to controller with backpack
                --close mouse backpack container widget
                CloseContainerWidget(self, overflow.inst, overflow:IsSideWidget())
            elseif overflow:IsOpenedBy(self.owner) then
                --switching to mouse with backpack
                --reopen backpack if it was opened
                OpenContainerWidget(self, overflow.inst, overflow:IsSideWidget())
            end
        end

        self.controls.craftingmenu:RefreshControllers(controller_mode)

        if self._CraftingHintAllRecipesEnabled ~= Profile:GetCraftingHintAllRecipesEnabled() then
            self.owner:PushEvent("refreshcrafting")
            self._CraftingHintAllRecipesEnabled = Profile:GetCraftingHintAllRecipesEnabled()
        end

    end

    self.RefreshControllers = function (self, ...)
        RefreshControllers_New(self)
    end
end)