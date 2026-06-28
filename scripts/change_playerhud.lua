local PlayerHud = require "screens/playerhud"
local PauseScreen = require "screens/pausescreen"
local ContainerWidget = require("widgets/containerwidget")

AddClassPostConstruct("screens/playerhud", function(self)
    local OnControl_Old = self.OnControl
    self.OnControl = function (self, control, down, ...)
        if control == CONTROL_OPEN_INVENTORY then
            return
        end
        if down and control == CONTROL_OPEN_CRAFTING then
            if self:IsControllerCraftingOpen() then
                self:CloseControllerCrafting()
            elseif not self.owner:HasTag("beaver") then
                self.controls.crafttabs:OpenTab(1)
            end
            return
        end
        return OnControl_Old(self, control, down, ...)
    end

    local function OpenContainerWidget(self, container, side)
        if container then
            local containerwidget = nil
            if side then
                containerwidget = self.controls.containerroot_side:AddChild(ContainerWidget(self.owner))
            else
                containerwidget = self.controls.containerroot:AddChild(ContainerWidget(self.owner))
            end
            containerwidget:Open(container, self.owner)
            
            for k,v in pairs(self.controls.containers) do
                if v.container then
                    if v.container.prefab == container.prefab or v.container.components.container.type == container.components.container.type then
                        v:Close()
                    end
                else
                    self.controls.containers[k] = nil
                end
            end
            
            self.controls.containers[container] = containerwidget
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
    local function CloseContainerWidget(self, container, side, dont_close_container)
        for k, v in pairs(self.controls.containers) do
            if v.container == container then
                v:Close(dont_close_container)
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

    self.RefreshControllers = function (self) -- this is really the event handler for "continuefrompause"
        local controller_mode = TheInput:ControllerAttached()
        if controller_mode then
            TheFrontEnd:StopTrackingMouse()
        end

        -- =============================================================================== --
        -- local integrated_backpack = controller_mode or Profile:GetIntegratedBackpack()
        local integrated_backpack = Profile:GetIntegratedBackpack()
        -- =============================================================================== --
        -- =============================================================================== --
        -- if self.controls.inv.controller_build ~= controller_mode or self.controls.inv.integrated_backpack ~= integrated_backpack then
        if self.controls.inv.integrated_backpack ~= integrated_backpack then
        -- =============================================================================== --
            self.controls.inv.rebuild_pending = true
            local overflow = self.owner.components.inventory.overflow
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
                CloseContainerWidget(self, overflow, overflow.components.container.side_widget, true)
            elseif overflow.components.container:IsOpenedBy(self.owner) then
                --switching to mouse with backpack
                --reopen backpack if it was opened
                OpenContainerWidget(self, overflow, overflow.components.container.side_widget)
            end
        end
    end

end)