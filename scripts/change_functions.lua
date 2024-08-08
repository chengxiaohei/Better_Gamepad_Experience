function TryTriggerMappingKey(player, left, right, left_and_right, use)
    if left_and_right and TheInput:IsControlPressed(CHANGE_CONTROL_LEFT) and TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
        local inventory = player.replica.inventory
        if use and inventory ~= nil and inventory:IsVisible() then
            local item = inventory:GetItemInSlot(left_and_right)
            if item ~= nil then
                inventory:ControllerUseItemOnSelfFromInvTile(item)
            end
        end
        return true
    end
    local Trigger = false
    if left and TheInput:IsControlPressed(CHANGE_CONTROL_LEFT) then
        local inventory = player.replica.inventory
        if use and inventory ~= nil and inventory:IsVisible() then
            local item = inventory:GetItemInSlot(left)
            if item ~= nil then
                inventory:ControllerUseItemOnSelfFromInvTile(item)
            end
        end
        Trigger = true
    end
    if right and TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
        local inventory = player.replica.inventory
        if use and inventory ~= nil and inventory:IsVisible() then
            local item = inventory:GetItemInSlot(right)
            if item ~= nil then
                inventory:ControllerUseItemOnSelfFromInvTile(item)
            end
        end
        Trigger = true
    end
    return Trigger
end

function GetQuickUseString(player, inv_slot_num)
    local CHANGE_MAPPING_TABLE = {

        MAPPING_LB_LT = {
            slot = GetModConfigData("MAPPING_LB_LT"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_LEFT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_OPEN_CRAFTING)
        },
        MAPPING_RB_LT = {
            slot = GetModConfigData("MAPPING_RB_LT"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_RIGHT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_OPEN_CRAFTING)
        },
        MAPPING_LB_RB_LT = {
            slot = GetModConfigData("MAPPING_LB_RB_LT"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_LEFT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_RIGHT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_OPEN_CRAFTING)
        },

        MAPPING_RB_RT = {
            slot = GetModConfigData("MAPPING_RB_RT"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_RIGHT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_OPEN_INVENTORY)
        },
        MAPPING_LB_RB_RT = {
            slot = GetModConfigData("MAPPING_LB_RB_RT"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_LEFT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_RIGHT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_OPEN_INVENTORY)
        },

        MAPPING_LB_BACK = {
            slot = GetModConfigData("MAPPING_LB_BACK"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_LEFT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_MAP)
        },
        MAPPING_RB_BACK = {
            slot = GetModConfigData("MAPPING_RB_BACK"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_RIGHT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_MAP)
        },
        MAPPING_LB_RB_BACK = {
            slot = GetModConfigData("MAPPING_LB_RB_BACK"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_LEFT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_RIGHT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_MAP)
        },

        MAPPING_LB_START = {
            slot = GetModConfigData("MAPPING_LB_START"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_LEFT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PAUSE)
        },
        MAPPING_RB_START = {
            slot = GetModConfigData("MAPPING_RB_START"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_RIGHT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PAUSE)
        },
        MAPPING_LB_RB_START = {
            slot = GetModConfigData("MAPPING_LB_RB_START"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_LEFT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_RIGHT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PAUSE)
        },

        MAPPING_LB_LSTICK = {
            slot = GetModConfigData("MAPPING_LB_LSTICK"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_LEFT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_MENU_MISC_3)
        },
        MAPPING_RB_LSTICK = {
            slot = GetModConfigData("MAPPING_RB_LSTICK"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_RIGHT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_MENU_MISC_3)
        },
        MAPPING_LB_RB_LSTICK = {
            slot = GetModConfigData("MAPPING_LB_RB_LSTICK"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_LEFT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_RIGHT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_MENU_MISC_3)
        },

        MAPPING_LB_RSTICK = {
            slot = GetModConfigData("MAPPING_LB_RSTICK"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_LEFT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_MENU_MISC_4)
        },
        MAPPING_RB_RSTICK = {
            slot = GetModConfigData("MAPPING_RB_RSTICK"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_RIGHT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_MENU_MISC_4)
        },
        MAPPING_LB_RB_RSTICK = {
            slot = GetModConfigData("MAPPING_LB_RB_RSTICK"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_LEFT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_RIGHT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_MENU_MISC_4)
        },

        MAPPING_LB_UP = {
            slot = GetModConfigData("MAPPING_LB_UP"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_LEFT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_EXAMINE)
        },
        MAPPING_RB_UP = {
            slot = GetModConfigData("MAPPING_RB_UP"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_RIGHT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_EXAMINE)
        },
        MAPPING_LB_RB_UP = {
            slot = GetModConfigData("MAPPING_LB_RB_UP"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_LEFT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_RIGHT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INVENTORY_EXAMINE)
        }
    }

    local item = player.replica.inventory:GetItemInSlot(inv_slot_num)
    local action = player.components.playercontroller:GetItemSelfAction(item)
    local t = {}
    if action ~= nil then
        for _,v in pairs(CHANGE_MAPPING_TABLE) do
            if v.slot == inv_slot_num then
                table.insert(t, v.string.." "..STRINGS.UI.COOKBOOK.PERISH_QUICKLY.." "..STRINGS.ACTIONS.USEITEM)
            end
        end
    end
    return table.concat(t, "\n")
end
