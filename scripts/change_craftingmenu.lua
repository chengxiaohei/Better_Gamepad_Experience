AddClassPostConstruct("widgets/redux/craftingmenu_hud", function(self)
    local OnControl_Old = self.OnControl;
    self.OnControl = function(self, control, down, ...)
        print("****** press", control, down)
        if TheInput:ControllerAttached() then
            if control == CONTROL_MENU_MISC_1 then return false end
            if control == CONTROL_MENU_MISC_2 then return false end
            if control == CONTROL_ACCEPT or control == CONTROL_CONTROLLER_ACTION then return false end
            if control == CONTROL_CANCEL or control == CONTROL_CONTROLLER_ALTACTION then return false end

            if control == CONTROL_INVENTORY_LEFT and Input:IsControlPressed(CHANGE_CONTROL_CAMERA) then return false end
            if control == CONTROL_INVENTORY_RIGHT and Input:IsControlPressed(CHANGE_CONTROL_CAMERA) then return false end
            if control == CONTROL_INVENTORY_UP and Input:IsControlPressed(CHANGE_CONTROL_CAMERA) then return false end
            if control == CONTROL_INVENTORY_DOWN and Input:IsControlPressed(CHANGE_CONTROL_CAMERA) then return false end

            -- change pin and uppin to d-pad up
            if control == CONTROL_INVENTORY_EXAMINE then control = CONTROL_MENU_MISC_1 end
        end

        local result = OnControl_Old(self, control, down, ...)

        if not result and (
            control == CONTROL_MENU_MISC_1 or control == CONTROL_INVENTORY_DROP or
            control == CONTROL_INVENTORY_USEONSELF or control == CONTROL_INVENTORY_USEONSCENE) then
            return true
        end
        return result
    end

    -- remove openhint Method one : A Little bit slow 
    -- local RefreshControllers_OLd = self.RefreshControllers
    -- self.RefreshControllers = function (self, controller_mode, ...)
    --     RefreshControllers_OLd(self, controller_mode, ...)
    --     self.openhint:Hide()
    -- end

    -- remove openhint Method two : Fast but Additional consumption
    local OnUpdate_Old = self.OnUpdate
    self.OnUpdate = function (self, dt)
        OnUpdate_Old(self, dt)
        self.openhint:Hide()
    end

    -- Optimize Algorithm
    local function GetClosestWidget(list, active_widget, dir_x, dir_y)
        local closest = nil
        local closest_score = nil

        if active_widget ~= nil then
            local x, y = active_widget.inst.UITransform:GetWorldPosition()
            for k,v in pairs(list) do
                if v ~= active_widget and v:IsVisible() then
                    local vx, vy = v.inst.UITransform:GetWorldPosition()
                    -- ============================================================================================== --
                    -- local local_dir_x, local_dir_y = vx-x, vy-y
                    local local_dir_x, local_dir_y = (2-1.5*dir_x*dir_x)*(vx-x), (2-1.5*dir_y*dir_y)*(vy-y)
                    -- ============================================================================================== --
                    if VecUtil_Dot(local_dir_x, local_dir_y, dir_x, dir_y) > 0 then
                        local score = local_dir_x * local_dir_x + local_dir_y * local_dir_y
                        if not closest or score < closest_score then
                            closest = v
                            closest_score = score
                        end
                    end
                end
            end
        end

        return closest, closest_score
    end


    -- Use Optimized Algorithm
    self.InvNavToPin = function (self, inv_widget, dir_x, dir_y, ...)
        return GetClosestWidget(self.pinbar.pin_slots, inv_widget, dir_x, dir_y) or self.pinbar.page_spinner
    end
end)


AddClassPostConstruct("widgets/redux/craftingmenu_widget", function(self)
    local OnControl_Old = self.OnControl
    self.OnControl = function(self, control, down, ...)
        if TheInput:ControllerAttached() then
            if control == CONTROL_INVENTORY_DROP then
                control = CONTROL_ACCEPT
            end
        end
        return OnControl_Old(self, control, down, ...)
    end

    local OnCraftingMenuOpen_Old = self.OnCraftingMenuOpen
    self.OnCraftingMenuOpen = function(self, ...)
        local result = OnCraftingMenuOpen_Old(self, ...)
        if TheInput:ControllerAttached() then
            self.search_box:Disable()
        else
            self.search_box:Enable()
        end
        return result
    end

    -- 修改物品制作栏上下滑动的提示图标
    local RefreshControllers_Old = self.RefreshControllers
    self.RefreshControllers = function (self, controller_mode, ...)
        if controller_mode then controller_mode = false end
        RefreshControllers_Old(self, controller_mode, ...)
    end

    self.RefreshCraftingHelpText = function(self, controller_id, ...)
        if self.recipe_grid.focus then
            local hint_text = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_EXAMINE).." "..STRINGS.UI.CRAFTING_MENU.PIN

            -- TODO Favorite
            local recipe_name = self.details_root.data ~= nil and self.details_root.data.recipe.name or nil
            if recipe_name then
                hint_text = hint_text .. "  " .. TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP).." ".. STRINGS.UI.NOTIFICATION.PRESS_CONTROLLER..(TheCraftingMenuProfile:IsFavorite(recipe_name) and STRINGS.UI.CRAFTING_MENU.FAVORITE_REMOVE or STRINGS.UI.CRAFTING_MENU.FAVORITE_ADD)
            end
            return hint_text
        elseif self.filter_panel.focus then
            return TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP).." "..STRINGS.UI.HUD.SELECT
        end
        return ""
    end
end)


AddClassPostConstruct("widgets/redux/craftingmenu_pinbar", function(self)
    local OnControl_Old = self.OnControl;
    self.OnControl = function(self, control, down, ...)
        if TheInput:ControllerAttached() and self.crafting_hud:IsCraftingOpen() then
            if control == CONTROL_INVENTORY_DROP then
                control = CONTROL_ACCEPT
            end
        end
        -- local result = OnControl_Old(self, control, down, ...)
        -- if result then
        --     return result
        -- else
        --     if not down and TheInput:ControllerAttached() then
        --         if control == CONTROL_SCROLLBACK then
        --             self:GoToPrevPage()
        --             return true
        --         elseif control == CONTROL_SCROLLFWD then
        --             self:GoToNextPage()
        --             return true
        --         end
        --     end
        -- end
        -- return result
        return OnControl_Old(self, control, down, ...)
    end

    -- 令光标无法移动到pin_spinner上
    -- for _, pin in ipairs(self.pin_slots) do
    --     local FindPinUp_Old = pin.FindPinUp
    --     pin.FindPinUp = function (_pin)
    --         local result = FindPinUp_Old(_pin)
    --         if result == self.page_spinner then
    --             return pin
    --         end
    --         return result
    --     end
	-- end


    -- 令双箭头在page_spinner上始终显示
    local OnGainFocus_Old = self.OnGainFocus
    self.OnGainFocus = function (self, ...)
        local result = OnGainFocus_Old(self, ...)
        if self.page_spinner ~= nil then
            self.page_spinner.page_left:Show()
            self.page_spinner.page_right:Show()
            self.page_spinner.page_left_control:Hide()
            self.page_spinner.page_right_control:Hide()
        end
        return result
    end

    -- maybe useless
    local OnLoseFocus_Old = self.OnLoseFocus
    self.OnLoseFocus = function (self, ...)
        local result = OnLoseFocus_Old(self, ...)
        if self.page_spinner ~= nil then
            self.page_spinner.page_left:Show()
            self.page_spinner.page_right:Show()
            self.page_spinner.page_left_control:Hide()
            self.page_spinner.page_right_control:Hide()
        end
        return result
    end
end)

AddClassPostConstruct("widgets/redux/craftingmenu_pinslot", function(self)
    local craft_button_OnControl_Old = self.craft_button.OnControl;
    self.craft_button.OnControl = function(_self, control, down, ...)
        local result = craft_button_OnControl_Old(_self, control, down)
        if result then
            return result
        else
            if self.focus and down and not _self.down then
                if TheInput:ControllerAttached() then
                    if not self.craftingmenu:IsCraftingOpen() then
                        if control == CONTROL_INVENTORY_USEONSELF or control == CONTROL_INVENTORY_USEONSCENE then
                            -- if it is selected, pass the controls off to the details panel skin spinner to update the skin, otherwise it will be done here
                            local recipe_name, skin_name = self.craftingmenu:GetCurrentRecipeName()
                            if self.recipe_name ~= nil and self.recipe_name == recipe_name and self.craftingmenu.craftingmenu.details_root.skins_spinner:OnControl(control, down) then 
                                recipe_name, skin_name = self.craftingmenu:GetCurrentRecipeName()
                                self:SetRecipe(recipe_name, skin_name)
                                self.craftingmenu.craftingmenu.details_root:UpdateBuildButton(self)
                                return true 
                            elseif control == CONTROL_INVENTORY_USEONSELF then
                                if self.recipe_name ~= nil then
                                    local new_skin = self:GetPrevSkin(self.skin_name)
                                    if new_skin ~= self.skin_name then
                                        self:SetRecipe(self.recipe_name, new_skin)
                                        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                                    else
                                        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_negative", nil, .1)
                                    end
                                    return true
                                end
                            elseif control == CONTROL_INVENTORY_USEONSCENE then
                                if self.recipe_name ~= nil then
                                    local new_skin = self:GetNextSkin(self.skin_name)
                                    if new_skin ~= self.skin_name then
                                        self:SetRecipe(self.recipe_name, new_skin)
                                        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
                                    else
                                        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_negative", nil, .1)
                                    end
                                    return true
                                end
                            end
                        end
                    end
                end
            end
        end
        return result
    end
    self.RefreshCraftingHelpText = function(self, controller_id, ...)
        local hint_text = ""
        if self.recipe_name ~= nil then
            local recipe_name, skin_name = self.craftingmenu:GetCurrentRecipeName()
            if recipe_name == nil or self.recipe_name ~= recipe_name or self.skin_name ~= skin_name then
                hint_text = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP).." "..STRINGS.UI.HUD.SELECT
            end
        end

        return hint_text
    end
    self.SetUnpinControllerHintString = function(self, ...)
        if self.craftingmenu.is_left_aligned then 
            self.unpin_controllerhint:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_EXAMINE) .. " " .. (self.recipe_name ~= nil and STRINGS.UI.CRAFTING_MENU.UNPIN or STRINGS.UI.CRAFTING_MENU.PIN))
        else
            self.unpin_controllerhint:SetString((self.recipe_name ~= nil and STRINGS.UI.CRAFTING_MENU.UNPIN or STRINGS.UI.CRAFTING_MENU.PIN) .. " " .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_EXAMINE))
        end
    end


    local RefreshControllers_Old = self.RefreshControllers
    self.RefreshControllers = function (self, controller_mode, for_open_crafting_menu, ...)
        local result = RefreshControllers_Old(self, controller_mode, for_open_crafting_menu, ...)
        if controller_mode and not for_open_crafting_menu and not self.craftingmenu:IsCraftingOpen() then
            self.recipe_popup.openhint:SetString("        " .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_DROP) .. " " .. self.craft_button.help_message)
        end
        return result
    end

    -- remove pinslot black help message on the bottom of screen
    self.craft_button.GetHelpText = function (_self, ...)
        return ""
    end
end)


AddClassPostConstruct("widgets/redux/craftingmenu_details", function(self)
    local hint_text =
    {
        ["NEEDSSCIENCEMACHINE"] = "NEEDSCIENCEMACHINE",
        ["NEEDSALCHEMYMACHINE"] = "NEEDALCHEMYENGINE",
        ["NEEDSSHADOWMANIPULATOR"] = "NEEDSHADOWMANIPULATOR",
        ["NEEDSPRESTIHATITATOR"] = "NEEDPRESTIHATITATOR",
        ["NEEDSANCIENTALTAR_HIGH"] = "NEEDSANCIENT_FOUR",
        ["NEEDSSPIDERCRAFT"] = "NEEDSSPIDERFRIENDSHIP",
        ["NEEDSROBOTMODULECRAFT"] = "NEEDSCREATURESCANNING",
        ["NEEDSBOOKCRAFT"] = "NEEDSBOOKSTATION",
        ["NEEDSLUNAR_FORGE"] = "NEEDSLUNARFORGING_TWO",
        ["NEEDSSHADOW_FORGE"] = "NEEDSSHADOWFORGING_TWO",
        ["NEEDSCARPENTRY_STATION"] = "NEEDSCARPENTRY_TWO",
    }

    local UpdateBuildButton_Old = self.UpdateBuildButton
    local UpdateBuildButton_New = function(self, from_pin_slot, ...)
        self.first_sub_ingredient_to_craft = nil

        if self.data == nil then
            return
        end

        local builder = self.owner.replica.builder
        local recipe = self.data.recipe
        local meta = self.data.meta

        local teaser = self.build_button_root.teaser
        local button = self.build_button_root.button

        if meta.build_state == "hint" or meta.build_state == "hide" or self.ingredients.hint_tech_ingredient ~= nil then
            local str
            if self.ingredients.hint_tech_ingredient ~= nil then
                str = STRINGS.UI.CRAFTING.NEEDSTECH[self.ingredients.hint_tech_ingredient]
            elseif not builder:CanLearn(recipe.name) then
                -- If our recipe's builder tag is a skilltree tag, check if we're the skill tree owner,
                -- and choose a string based on that.
                str = (recipe.builder_tag ~= nil and self.owner.prefab == TECH_SKILLTREE_BUILDER_TAG_OWNERS[recipe.builder_tag] and STRINGS.UI.CRAFTING.NEEDSCHARACTERSKILL)
                    or STRINGS.UI.CRAFTING.NEEDSCHARACTER
            else
                local prototyper_tree = self:_GetHintTextForRecipe(self.owner, recipe)
                str = STRINGS.UI.CRAFTING[hint_text[prototyper_tree] or prototyper_tree]
            end
            teaser:SetSize(20)
            teaser:UpdateOriginalSize()
            teaser:SetMultilineTruncatedString(str, 2, (self.panel_width / 2) * 0.8, nil, false, true)

            teaser:Show()
            button:Hide()
        else
            if not meta.can_build and recipe.ingredients ~= nil then
                for i, v in ipairs(self.ingredients.ingredient_widgets) do
                    local data = v.ingredient_recipe
                    if data ~= nil and data.meta.can_build and not v.has_enough then
                        self.first_sub_ingredient_to_craft = data
                        break
                    end
                end
            end

            local buttonstr = (self.first_sub_ingredient_to_craft ~= nil and self.first_sub_ingredient_to_craft.meta.build_state == "prototype") and STRINGS.UI.CRAFTING.PROTOTYPE_INGREDIENT
                                or self.first_sub_ingredient_to_craft ~= nil and STRINGS.UI.CRAFTING.CRAFT_INGREDIENT
                                or meta.build_state == "prototype" and STRINGS.UI.CRAFTING.PROTOTYPE
                                or meta.build_state == "buffered" and STRINGS.UI.CRAFTING.PLACE
                                or recipe.actionstr ~= nil and STRINGS.UI.CRAFTING.RECIPEACTION[recipe.actionstr]
                                or STRINGS.UI.CRAFTING.BUILD

            if TheInput:ControllerAttached() then
                if meta.can_build then
                    if from_pin_slot ~= nil and (from_pin_slot.recipe_name ~= recipe.name or self.skins_spinner:GetItem() ~= from_pin_slot.skin_name) then
                        teaser:Hide()
                    else
                        teaser:SetSize(26)
                        teaser:UpdateOriginalSize()
                        teaser:SetMultilineTruncatedString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_DROP).." "..buttonstr, 2, (self.panel_width / 2) * 0.8, nil, false, true)
                        teaser:Show()
                    end
                else
                    teaser:SetSize(20)
                    teaser:UpdateOriginalSize()
                    teaser:SetMultilineTruncatedString(self.first_sub_ingredient_to_craft ~= nil and (TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_DROP).."  "..buttonstr) 
                                                        or meta.build_state == "prototype" and STRINGS.UI.CRAFTING.NEEDSTUFF_PROTOTYPE
                                                        or STRINGS.UI.CRAFTING.NEEDSTUFF
                                                        , 2, (self.panel_width / 2) * 0.8, nil, false, true)
                    teaser:Show()
                end

                button:Hide()
            else
                button:SetText(buttonstr)
                local w, h = button.text:GetRegionSize()
                button.image:ScaleToSize(Clamp(w + 50, 145, 300), 65)
                if meta.can_build or self.first_sub_ingredient_to_craft then
                    button:Enable()
                else
                    button:Disable()
                end

                button:Show()
                teaser:Hide()
            end
        end
    end
    self.UpdateBuildButton = function (self, from_pin_slot, ...)
        if TheInput:ControllerAttached() then
            return UpdateBuildButton_New(self, from_pin_slot, ...)
        end
        return UpdateBuildButton_Old(self, from_pin_slot, ...)
    end

end)