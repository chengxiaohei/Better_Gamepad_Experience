AddClassPostConstruct("widgets/redux/craftingmenu_hud", function(self)
    local Double_Click_Gap_Time = GetTime()
    local Status_Announce_Time = GetTime()
    local OnControl_Old = self.OnControl
    self.OnControl = function(self, control, down, ...)
        if down and control == CONTROL_MENU_MISC_2 then
            local DeltaTime = GetTime() - Double_Click_Gap_Time
            local Should_Announce = DeltaTime > 0 and DeltaTime < 0.3 and GetTime() - Status_Announce_Time > 1
            if IsOtherModEnabled("Status Announcements") and Should_Announce and self:IsCraftingOpen() then
                local StatusAnnouncer = require("statusannouncer")()
                local details = self.craftingmenu.details_root
                if StatusAnnouncer and details and details.data and details.data.recipe then
                    StatusAnnouncer:AnnounceRecipe(details.data.recipe)
                    Status_Announce_Time = GetTime()
                end
            end
            Double_Click_Gap_Time = GetTime()
        end

        if TheInput:ControllerAttached() and CHANGE_IS_USE_DPAD_SELECT_CRAFTING_MENU then
            if control == CONTROL_MENU_MISC_1 then return false end
            if control == CONTROL_MENU_MISC_2 then return false end
            if control == CONTROL_ACCEPT or control == CONTROL_CONTROLLER_ACTION then return false end
            if control == CONTROL_CANCEL or control == CONTROL_CONTROLLER_ALTACTION then return false end

            -- change pin and uppin to d-pad up
            if control == CONTROL_INVENTORY_EXAMINE then
                if TryTriggerMappingKey(self.owner, CHANGE_MAPPING_LB_UP, CHANGE_MAPPING_RB_UP, CHANGE_MAPPING_LB_RB_UP, false) then
                    return false
                else
                    control = CONTROL_MENU_MISC_1
                end
            end
            -- change add favorite to right trigger
            if control == CONTROL_OPEN_INVENTORY then
                if TryTriggerMappingKey(self.owner, false, CHANGE_MAPPING_RB_RT, CHANGE_MAPPING_LB_RB_RT, false) then
                    return false
                else
                    control = CONTROL_MENU_MISC_2
                end
            end
        end

        local result = OnControl_Old(self, control, down, ...)

        if not result and CHANGE_IS_USE_DPAD_SELECT_CRAFTING_MENU and (
            control == CONTROL_MENU_MISC_1 or control == CONTROL_INVENTORY_DROP or
            control == CONTROL_INVENTORY_USEONSELF or control == CONTROL_INVENTORY_USEONSCENE) then
            return true
        end
        return result
    end

    -- remove openhint: Fast but Additional consumption
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
					local local_dir_x, local_dir_y = (2-1.5*math.abs(dir_x))*(vx-x), (2-1.5*math.abs(dir_y)) * (vy-y)
                    -- local dot = VecUtil_Dot(local_dir_x, local_dir_y, dir_x, dir_y)
					local dot = VecUtil_Dot(local_dir_x, local_dir_y, dir_x, dir_y) / (VecUtil_Length(local_dir_x, local_dir_y) * VecUtil_Length(dir_x, dir_y))
                    -- if dot > 0 then
                    if dot > 0.2 then  -- 0.2 is a magic number
                    -- ============================================================================================== --
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
        if TheInput:ControllerAttached() and CHANGE_IS_USE_DPAD_SELECT_CRAFTING_MENU then
            if control == CONTROL_INVENTORY_DROP then
                    control = CONTROL_ACCEPT
            end
        end
        return OnControl_Old(self, control, down, ...)
    end


    -- 修改物品制作栏上下滑动的提示图标
    local RefreshControllers_Old = self.RefreshControllers
    self.RefreshControllers = function (self, controller_mode, ...)
        if controller_mode and CHANGE_IS_USE_DPAD_SELECT_CRAFTING_MENU then controller_mode = false end
        RefreshControllers_Old(self, controller_mode, ...)
    end

    local RefreshCraftingHelpText_Old = self.RefreshCraftingHelpText
    local RefreshCraftingHelpText_New = function(self, controller_id, ...)
        if self.recipe_grid.focus then
            local hint_text = TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_EXAMINE).." "..STRINGS.UI.CRAFTING_MENU.PIN

            local recipe_name = self.details_root.data ~= nil and self.details_root.data.recipe.name or nil
            if recipe_name then
                hint_text = hint_text .."  "..TheInput:GetLocalizedControl(controller_id, CONTROL_OPEN_INVENTORY).." "..(TheCraftingMenuProfile:IsFavorite(recipe_name) and STRINGS.UI.CRAFTING_MENU.FAVORITE_REMOVE or STRINGS.UI.CRAFTING_MENU.FAVORITE_ADD)
            end
            return hint_text
        elseif self.filter_panel.focus then
            return TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP).." "..STRINGS.UI.HUD.SELECT
        end
        return ""
    end
    
    self.RefreshCraftingHelpText = function (self, controller_id, ...)
        if TheInput:ControllerAttached() and CHANGE_IS_USE_DPAD_SELECT_CRAFTING_MENU then
            return RefreshCraftingHelpText_New(self, controller_id, ...)
        else
            return RefreshCraftingHelpText_Old(self, controller_id, ...)
        end
    end
end)


AddClassPostConstruct("widgets/redux/craftingmenu_pinbar", function(self)
    local OnControl_Old = self.OnControl;
    self.OnControl = function(self, control, down, ...)
        if TheInput:ControllerAttached() and self.crafting_hud:IsCraftingOpen() then
            if CHANGE_IS_USE_DPAD_SELECT_CRAFTING_MENU then
                if control == CONTROL_INVENTORY_DROP then
                    control = CONTROL_ACCEPT
                end
            end
            if down and control == CONTROL_INVENTORY_USEONSCENE and TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
                self:GoToPrevPage()
                return true
            end
            if down and control == CONTROL_INVENTORY_USEONSELF and TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT)  then
                self:GoToNextPage()
                return true
            end
        end
        return OnControl_Old(self, control, down, ...)
    end


    -- Now you can foucs on page_spinner even if craftingmenu is not open
    for _, pin in ipairs(self.pin_slots) do
        local FindPinUp_Old = pin.FindPinUp
        pin.FindPinUp = function (_pin)
            local result = FindPinUp_Old(_pin)
            if result == nil then
                return self.page_spinner
            end
            return result
        end
	end

    -- Do Not move focus down while GoToPrevPage or GoToNextPage
    -- stupid but works
    self.GoToNextPage = function (self, silent)
        TheCraftingMenuProfile:NextPage()
        self:RefreshPinnedRecipes()

        if TheInput:ControllerAttached() then
        -- ============================================================================== --
        -- if self.page_spinner.focus then
		-- 	self.owner.HUD.controls.inv:PinBarNav(self.page_spinner:FindPinDown())
		-- else
            if not self.page_spinner.focus then
        -- ============================================================================== --
                local cur_slot = self:GetFocusSlot()
                if cur_slot ~= nil and not cur_slot:IsVisible() then
                    self.owner.HUD.controls.inv:PinBarNav(cur_slot:FindPinDown() or cur_slot:FindPinUp() or self.page_spinner)
                end
            end
        end

        if not silent then
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        end

        if not self.crafting_hud:IsCraftingOpen() then
            TheCraftingMenuProfile:Save()
        end
    end

    -- stupid but works
    self.GoToPrevPage = function (self, silent)
        TheCraftingMenuProfile:PrevPage()
        self:RefreshPinnedRecipes()

        if TheInput:ControllerAttached() then
        -- ============================================================================== --
        -- if self.page_spinner.focus then
		-- 	self.owner.HUD.controls.inv:PinBarNav(self.page_spinner:FindPinDown())
		-- else
            if not self.page_spinner.focus then
        -- ============================================================================== --
                local cur_slot = self:GetFocusSlot()
                if cur_slot ~= nil and not cur_slot:IsVisible() then
                    self.owner.HUD.controls.inv:PinBarNav(cur_slot:FindPinDown() or cur_slot:FindPinUp() or self.page_spinner)
                end
            end
        end

        if not silent then
            TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        end

        if not self.crafting_hud:IsCraftingOpen() then
            TheCraftingMenuProfile:Save()
        end
    end

    -- forbid Pinbar change page_spinner icons while gain or lose focus
    local OnGainFocus_Old = self.OnGainFocus
    self.OnGainFocus = function (self, ...)
        if not TheInput:ControllerAttached() then
            OnGainFocus_Old(self, ...)
        end
    end
    local OnLoseFocus_Old = self.OnLoseFocus
    self.OnLoseFocus = function (self, ...)
        if not TheInput:ControllerAttached() then
            OnLoseFocus_Old(self, ...)
        end
    end

    -- make page_spinner change itself icons correctly
    local page_spinner_ongainfocusfn_Old = self.page_spinner.ongainfocusfn
    self.page_spinner.ongainfocusfn = function ()
        page_spinner_ongainfocusfn_Old()
        if TheInput:ControllerAttached() then
            self.page_spinner.page_left:Hide()
            self.page_spinner.page_right:Hide()
            self.page_spinner.page_left_control:Show()
            self.page_spinner.page_right_control:Show()
        end
    end

    local page_spinner_onlosefocusfn_Old = self.page_spinner.onlosefocusfn
    self.page_spinner.onlosefocusfn = function ()
        page_spinner_onlosefocusfn_Old()
        if TheInput:ControllerAttached() then
            self.page_spinner.page_left_control:Hide()
            self.page_spinner.page_right_control:Hide()
            self.page_spinner.page_left:Show()
            self.page_spinner.page_right:Show()
        end
    end

    self.page_spinner.RefreshCraftingHelpText = function (self, controller_id, ...)
        local t = {}
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE).." "..STRINGS.UI.HELP.PREVPAGE)
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF).." "..STRINGS.UI.HELP.NEXTPAGE)
        return table.concat(t, " ")
    end

    local RefreshCraftingHelpText_Old = self.RefreshCraftingHelpText
    self.RefreshCraftingHelpText = function (self, controller_id, ...)
        local slot_help_text = RefreshCraftingHelpText_Old(self, controller_id, ...)
        if slot_help_text == "" and self.page_spinner.focus and self.page_spinner.RefreshCraftingHelpText then
            slot_help_text = slot_help_text .. self.page_spinner:RefreshCraftingHelpText(controller_id, ...)
        end
        return slot_help_text
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
                            elseif control == CONTROL_INVENTORY_USEONSELF and not TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
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
                            elseif control == CONTROL_INVENTORY_USEONSCENE and not TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
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

    local RefreshCraftingHelpText_Old = self.RefreshCraftingHelpText
    local RefreshCraftingHelpText_New = function(self, controller_id, ...)
        local t = {}
        if self.recipe_name ~= nil and not TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
            local prev_skin = self:GetPrevSkin(self.skin_name)
            if prev_skin ~= self.skin_name then
                table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE).." "..TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF).." "..STRINGS.UI.HELP.TOGGLE.." "..STRINGS.UI.LOBBYSCREEN.SKINS)
            end
        elseif TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
            table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE).." "..STRINGS.UI.HELP.PREVPAGE)
            table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF).." "..STRINGS.UI.HELP.NEXTPAGE)
        end

        if self.recipe_name ~= nil then
            local recipe_name, skin_name = self.craftingmenu:GetCurrentRecipeName()
            if recipe_name == nil or self.recipe_name ~= recipe_name or self.skin_name ~= skin_name then
                table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_DROP).." "..STRINGS.UI.HUD.SELECT)
            end
        end

        return table.concat(t, " ")
    end
    self.RefreshCraftingHelpText = function(self, controller_id, ...)
        if TheInput:ControllerAttached() and CHANGE_IS_USE_DPAD_SELECT_CRAFTING_MENU then
            return RefreshCraftingHelpText_New(self, controller_id, ...)
        else
            local t = {}
            if self.recipe_name ~= nil and not TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
                local prev_skin = self:GetPrevSkin(self.skin_name)
                if prev_skin ~= self.skin_name then
                    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE).." "..TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF).." "..STRINGS.UI.HELP.TOGGLE.." "..STRINGS.UI.LOBBYSCREEN.SKINS)
                end
            elseif TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
                table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSCENE).." "..STRINGS.UI.HELP.PREVPAGE)
                table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_INVENTORY_USEONSELF).." "..STRINGS.UI.HELP.NEXTPAGE)
            end
            return table.concat(t, " ") .. RefreshCraftingHelpText_Old(self, controller_id, ...)
        end
    end

    local SetUnpinControllerHintString_Old = self.SetUnpinControllerHintString
    local SetUnpinControllerHintString_New = function(self, ...)
        if self.craftingmenu.is_left_aligned then 
            self.unpin_controllerhint:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_EXAMINE) .. " " .. (self.recipe_name ~= nil and STRINGS.UI.CRAFTING_MENU.UNPIN or STRINGS.UI.CRAFTING_MENU.PIN))
        else
            self.unpin_controllerhint:SetString((self.recipe_name ~= nil and STRINGS.UI.CRAFTING_MENU.UNPIN or STRINGS.UI.CRAFTING_MENU.PIN) .. " " .. TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_EXAMINE))
        end
    end
    self.SetUnpinControllerHintString = function (self, ...)
        if TheInput:ControllerAttached() and CHANGE_IS_USE_DPAD_SELECT_CRAFTING_MENU then
            SetUnpinControllerHintString_New(self, ...)
        else
            SetUnpinControllerHintString_Old(self, ...)
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
        ["NEEDSCARPENTRY_STATION_STONE"] = "NEEDSCARPENTRY_THREE",
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
                str = (recipe.builder_skill ~= nil and self.owner.components.skilltreeupdater:IsValidSkill(recipe.builder_skill)) and STRINGS.UI.CRAFTING.NEEDSCHARACTERSKILL
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
        if TheInput:ControllerAttached() and CHANGE_IS_USE_DPAD_SELECT_CRAFTING_MENU then
            return UpdateBuildButton_New(self, from_pin_slot, ...)
        end
        return UpdateBuildButton_Old(self, from_pin_slot, ...)
    end

end)
