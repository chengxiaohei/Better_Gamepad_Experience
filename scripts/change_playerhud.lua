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
                if self.controls.votedialog:CheckControl(control, down) then
                    return true
                end
                -- if self:IsVisible() and
                --     self:IsPlayerInfoPopUpOpen() and
                --     self.owner.components.playercontroller:IsEnabled() then
                --     self:TogglePlayerInfoPopup()
                --     return true
                -- elseif self.controls.votedialog:CheckControl(control, down) then
                --     return true
                -- elseif self.owner.components.playercontroller:GetControllerTarget() == nil
                --     and self:InspectSelf() then
                --     return true
                -- end
            elseif control == CONTROL_INSPECT_SELF and self:InspectSelf() then
                return true
            end
        elseif control == CONTROL_PAUSE then
            if TheInput:ControllerAttached() then
                self.owner.components.playercontroller:CancelAOETargeting()
                self:CloseCrafting()
                self:CloseSpellWheel()
                if self:IsControllerInventoryOpen() then
                    self:CloseControllerInventory()
                end
                TheFrontEnd:PushScreen(PauseScreen())
            else
                local closed = false
                if self.owner.components.playercontroller:IsAOETargeting() then
                    self.owner.components.playercontroller:CancelAOETargeting()
                    closed = true
                end
                if self:IsCraftingOpen() then
                    self:CloseCrafting()
                    closed = true
                end
                if self:IsSpellWheelOpen() then
                    self:CloseSpellWheel()
                    closed = true
                end
                if self:IsPlayerInfoPopUpOpen() and
                    self:TogglePlayerInfoPopup() then
                    closed = true
                end
                if not closed then
                    TheFrontEnd:PushScreen(PauseScreen())
                end
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
                if not self:IsMapScreenOpen() then
                    self:CloseCrafting()
                    self:CloseSpellWheel()
                    if self:IsControllerInventoryOpen() then
                        self:CloseControllerInventory()
                    end
                end
                self.controls:ToggleMap()
                return true
            -- elseif control == CONTROL_CANCEL and TheInput:ControllerAttached() then
                -- if self:IsCraftingOpen() then
                --     self:CloseCrafting()
                --     return true
                -- elseif self:IsSpellWheelOpen() then
                --     self:CloseSpellWheel()
                --     return true
                -- elseif self:IsControllerInventoryOpen() then
                --     self:CloseControllerInventory()
                --     return true
                -- end
                -- if self:IsSpellWheelOpen() then
                --     self:CloseSpellWheel()
                --     return true
                -- end
            elseif control == CONTROL_TOGGLE_PLAYER_STATUS then
                self:ShowPlayerStatusScreen(true)
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
            end
        elseif control == CONTROL_SHOW_PLAYER_STATUS then
            if not self:IsPlayerAvatarPopUpOpen() or self.playeravatarpopup.settled then
                self:ShowPlayerStatusScreen()
            end
            return true
        elseif control == CONTROL_OPEN_CRAFTING then
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
        elseif control == CONTROL_OPEN_INVENTORY then
            if self:IsControllerInventoryOpen() then
                self:CloseControllerInventory()
                return true
            end
            local inventory = self.owner.replica.inventory
            if inventory ~= nil and inventory:IsVisible() and inventory:GetNumSlots() > 0 then
                self:OpenControllerInventory()
                return true
            end
        elseif control >= CONTROL_INV_1 and control <= CONTROL_INV_10 then
            --inventory hotkeys
            local inventory = self.owner.replica.inventory
            if inventory ~= nil and inventory:IsVisible() then
                local hot_key_num = control - CONTROL_INV_1 + 1

                if TheInput:IsControlPressed(CONTROL_CRAFTING_MODIFIER) then
                    self.controls.craftingmenu:SelectPin(hot_key_num)
                else
                    local item = inventory:GetItemInSlot(hot_key_num)
                    if item ~= nil then
                        self.owner.replica.inventory:UseItemFromInvTile(item)
                    end
                end
                return true
            end
        elseif control >= CONTROL_INV_11 and control <= CONTROL_INV_15 then
            -- Inventory hotkeys part two.
            local inventory = self.owner.replica.inventory
            if inventory ~= nil and inventory:IsVisible() then
                local hot_key_num = control - CONTROL_INV_11 + 11

                -- No crafting menu pins!
                local item = inventory:GetItemInSlot(hot_key_num)
                if item ~= nil then
                    self.owner.replica.inventory:UseItemFromInvTile(item)
                end
                return true
            end
        end
    end

    self.OnControl = function (self, control, down, ...)
        if TheInput:ControllerAttached() then
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
	self.OpenContainer = function (self, container, side, ...)
        if container == nil then
            return
        elseif TheInput:ControllerAttached() and side and container.replica.container.inst:HasTag("backpack") and 
                CHANGE_ADD_EXTRAL_BACKPACK_INTEGRATE_SETTING and not CHANGE_INTEGRATE_BACKPACK then
            OpenContainerWidget(self, container, side)
        end
		OpenContainer_Old(self, container, side, ...)
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
	self.CloseContainer = function (self, container, side, ...)
        if container == nil then
            return
        elseif TheInput:ControllerAttached() and side and container.replica.container.inst:HasTag("backpack") and
                CHANGE_ADD_EXTRAL_BACKPACK_INTEGRATE_SETTING and not CHANGE_INTEGRATE_BACKPACK then
            CloseContainerWidget(self, container, side)
        end
		CloseContainer_Old(self, container, side, ...)
	end
end)