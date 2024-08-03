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