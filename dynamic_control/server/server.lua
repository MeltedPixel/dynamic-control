local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent("vehicleSystems:requestState", function(plate, model)
    local src = source
    exports.oxmysql:query('SELECT esc_enabled, tcs_enabled FROM player_vehicles WHERE plate = ?', { plate }, function(result)
        if result[1] then
            local esc = result[1].esc_enabled == true
            local tcs = result[1].tcs_enabled == true
            TriggerClientEvent("vehicleSystems:applyState", src, esc, tcs, true)
        else
            model = model or "unknown"
            local escDefault = Config.ESCVehicles[model]
            local tcsDefault = Config.TCSVehicles[model]

            local esc = escDefault == true
            local tcs = tcsDefault == true

            TriggerClientEvent("vehicleSystems:applyState", src, esc, tcs, false)
        end
    end)
end)

RegisterNetEvent("vehicleSystems:setESC", function(plate, state)
    exports.oxmysql:update('UPDATE player_vehicles SET esc_enabled = ? WHERE plate = ?', { state, plate })
end)

RegisterNetEvent("vehicleSystems:setTCS", function(plate, state)
    exports.oxmysql:update('UPDATE player_vehicles SET tcs_enabled = ? WHERE plate = ?', { state, plate })
end)