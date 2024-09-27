AddPrefabPostInit("telestaff", function (inst)
    inst.controller_use_attack_distance = ACTIONS.CASTSPELL.distance
    inst.controller_should_use_attack_target = true
end)
