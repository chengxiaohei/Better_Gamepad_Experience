
local EquipmentMappingTable = {
    [-1] = EQUIPSLOTS.HANDS,
    [-2] = EQUIPSLOTS.BODY,
    [-3] = EQUIPSLOTS.HEAD,
}

-- local KeyboardMappingTable = {
-- 	["a"] = 97,  ["A"] = 97,
-- 	["b"] = 98,  ["B"] = 98,
-- 	["c"] = 99,  ["C"] = 99,
-- 	["d"] = 100, ["D"] = 100,
-- 	["e"] = 101, ["E"] = 101,
-- 	["f"] = 102, ["F"] = 102,
-- 	["g"] = 103, ["G"] = 103,
-- 	["h"] = 104, ["H"] = 104,
-- 	["i"] = 105, ["I"] = 105,
-- 	["j"] = 106, ["J"] = 106,
-- 	["k"] = 107, ["K"] = 107,
-- 	["l"] = 108, ["L"] = 108,
-- 	["m"] = 109, ["M"] = 109,
-- 	["n"] = 110, ["N"] = 110,
-- 	["o"] = 111, ["O"] = 111,
-- 	["p"] = 112, ["P"] = 112,
-- 	["q"] = 113, ["Q"] = 113,
-- 	["r"] = 114, ["R"] = 114,
-- 	["s"] = 115, ["S"] = 115,
-- 	["t"] = 116, ["T"] = 116,
-- 	["u"] = 117, ["U"] = 117,
-- 	["v"] = 118, ["V"] = 118,
-- 	["w"] = 119, ["W"] = 119,
-- 	["x"] = 120, ["X"] = 120,
-- 	["y"] = 121, ["Y"] = 121,
-- 	["z"] = 122, ["Z"] = 122,
-- }

function TriggerKeyboardMappingKey(key, down, use)
    if down then
        if next(TheInput.onkeydown:GetHandlersForEvent(key)) then
            if use then
                TheInput.onkeydown:HandleEvent(key, IsOtherModEnabled("Gesture Wheel"))
            end
            return true
        end
    else
        if next(TheInput.onkeyup:GetHandlersForEvent(key)) then
            if use then
                TheInput.onkeyup:HandleEvent(key, IsOtherModEnabled("Gesture Wheel"))
            end
            return true
        end
    end
    return false
end

function TryTriggerKeyboardMappingKey(left, right, left_and_right, down, use)
    if left_and_right and left_and_right >= 97 and left_and_right <= 122 and
        TheInput:IsControlPressed(CHANGE_CONTROL_LEFT) and TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
        return TriggerKeyboardMappingKey(left_and_right, down, use)
    end
    local Trigger = false;
    if left and left >= 97 and left <= 122 and TheInput:IsControlPressed(CHANGE_CONTROL_LEFT) then
        Trigger = Trigger or TriggerKeyboardMappingKey(left, down, use)
    end
    if right and right >= 97 and right <= 122 and TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
        Trigger = Trigger or TriggerKeyboardMappingKey(right, down, use)
    end
    return Trigger;
end

function TryTriggerMappingKey(player, left, right, left_and_right, use)
    if left_and_right and left_and_right < 15 and TheInput:IsControlPressed(CHANGE_CONTROL_LEFT) and TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
        local inventory = player.replica.inventory
        if use and inventory ~= nil and inventory:IsVisible() then
            if left_and_right > 0 then
                local item = inventory:GetItemInSlot(left_and_right)
                if item ~= nil then
                    inventory:ControllerUseItemOnSelfFromInvTile(item)
                end
            else
                local equipment = inventory:GetEquippedItem(EquipmentMappingTable[left_and_right])
                if equipment ~= nil then
                    inventory:ControllerUseItemOnSceneFromInvTile(equipment)
                end
            end
        end
        return true
    end
    local Trigger = false
    if left and left < 15 and TheInput:IsControlPressed(CHANGE_CONTROL_LEFT) then
        local inventory = player.replica.inventory
        if use and inventory ~= nil and inventory:IsVisible() then
            if left > 0 then
                local item = inventory:GetItemInSlot(left)
                if item ~= nil then
                    inventory:ControllerUseItemOnSelfFromInvTile(item)
                end
            else
                local equipment = inventory:GetEquippedItem(EquipmentMappingTable[left])
                if equipment ~= nil then
                    inventory:ControllerUseItemOnSceneFromInvTile(equipment)
                end
            end
        end
        Trigger = true
    end
    if right and right < 15 and TheInput:IsControlPressed(CHANGE_CONTROL_RIGHT) then
        local inventory = player.replica.inventory
        if use and inventory ~= nil and inventory:IsVisible() then
            if right > 0 then
                local item = inventory:GetItemInSlot(right)
                if item ~= nil then
                    inventory:ControllerUseItemOnSelfFromInvTile(item)
                end
            else
                local equipment = inventory:GetEquippedItem(EquipmentMappingTable[right])
                if equipment ~= nil then
                    inventory:ControllerUseItemOnSceneFromInvTile(equipment)
                end
            end
        end
        Trigger = true
    end
    return Trigger
end

function GetQuickUseString(inv_slot, act)
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
            slot = not (CHANGE_FORCE_BUTTON == CHANGE_CONTROL_LEFT and CHANGE_IS_FORCE_PAUSE_QUICKLY) and GetModConfigData("MAPPING_LB_START") or false,
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_LEFT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_PAUSE)
        },
        MAPPING_RB_START = {
            slot = not (CHANGE_FORCE_BUTTON == CHANGE_CONTROL_RIGHT and CHANGE_IS_FORCE_PAUSE_QUICKLY) and GetModConfigData("MAPPING_RB_START") or false,
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
        },

        MAPPING_LB_Y = {
            slot = GetModConfigData("MAPPING_LB_Y"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_LEFT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INSPECT)
        },
        MAPPING_RB_Y = {
            slot = GetModConfigData("MAPPING_RB_Y"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_RIGHT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INSPECT)
        },
        MAPPING_LB_RB_Y = {
            slot = GetModConfigData("MAPPING_LB_RB_Y"),
            string = TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_LEFT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CHANGE_CONTROL_RIGHT).."+"..TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_INSPECT)
        }
    }
    local t = {}
    if inv_slot ~= nil and act ~= nil then
        for _, v in pairs(CHANGE_MAPPING_TABLE) do
            if type(inv_slot) == "number" then
                if v.slot == inv_slot then
                    table.insert(t, v.string.." "..STRINGS.UI.COOKBOOK.PERISH_QUICKLY.." "..act:GetActionString())
                end
            else
                if EquipmentMappingTable[v.slot] == inv_slot then
                    table.insert(t, v.string.." "..STRINGS.UI.COOKBOOK.PERISH_QUICKLY.." "..act:GetActionString())
                end
            end
        end
    end
    return table.concat(t, "\n")
end

local ModCompatabilityTable = {
    ["Geometric Placement"] = "workshop-351325790",
    ["Insight (Show Me+)"] = "workshop-2189004162",
    ["Snapping tills"] = "workshop-2302837868",
    ["Hybrid Crafting Menu UI"] = "workshop-2839020127",
    ["Gesture Wheel"] = "workshop-352373173",
}

function IsOtherModEnabled(modname)
    return KnownModIndex:IsModEnabled(ModCompatabilityTable[modname])
end

function GetOtherModConfig(modname, configname)
    return GLOBAL.GetModConfigData(configname, ModCompatabilityTable[modname])
end

function LoadGeometricPlacementCtrlOption()
    if not IsOtherModEnabled("Geometric Placement") then return end
	local config_options = KnownModIndex:LoadModConfigurationOptions(KnownModIndex:GetModActualName("Geometric Placement"), TheNet:GetIsClient())
    -- I don't Know Why, But Below Code is Necessary, Believe me.
    if type(config_options) == "table" then
        for _, v in ipairs(config_options) do
            if v.name == configname then
                return v.saved
            end
        end
    end
end
