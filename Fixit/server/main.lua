RegisterNetEvent("nd_tow:requestTow", function(coords)
    TriggerClientEvent("nd_tow:newTow", -1, coords)
end)

RegisterNetEvent("nd_tow:requestRepair", function(coords)
    TriggerClientEvent("nd_tow:newRepair", -1, coords)
end)
