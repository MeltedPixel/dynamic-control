local dynamic = exports["legacydmc_dynamic"]
local QBCore = exports['qb-core']:GetCoreObject()

local DEBUG = true
local lastVehicle = nil
local escOverrideByPlate = {}
local tcsOverrideByPlate = {}
local isOwnedVehicle = false

local function debugPrint(msg)
    if DEBUG then print("[ESC/TCS] " .. msg) end
end

local function getPlate(veh)
    return string.gsub(GetVehicleNumberPlateText(veh), "%s+", "")
end

local function notifyESC(state)
    local msg = state and "ESC Enabled" or "ESC Disabled"
    local type = state and "success" or "error"
    QBCore.Functions.Notify(msg, type)
end

local function notifyTCS(state)
    local msg = state and "TCS Enabled" or "TCS Disabled"
    local type = state and "success" or "error"
    QBCore.Functions.Notify(msg, type)
end

AddEventHandler("onClientResourceStart", function(resource)
    if resource == "legacydmc_dynamic" then
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)
            local plate = getPlate(veh)
            local model = GetDisplayNameFromVehicleModel(GetEntityModel(veh)):lower()
            debugPrint("[Restart Detected] Re-requesting ESC/TCS state for: " .. plate)
            TriggerServerEvent("vehicleSystems:requestState", plate, model)
        end
    end
end)

RegisterNetEvent("vehicleSystems:applyState", function(esc, tcs, owned)
    isOwnedVehicle = owned
    debugPrint("Server sent ESC: " .. tostring(esc) .. ", TCS: " .. tostring(tcs) .. ", Owned: " .. tostring(owned))

    if esc then dynamic:toggleEsc() end
    if tcs then dynamic:toggleTcs() end
end)

CreateThread(function()
    debugPrint("Vehicle monitor thread started.")

    while true do
        Wait(500)

        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)

            if veh ~= lastVehicle then
                lastVehicle = veh
                local plate = getPlate(veh)

                debugPrint("Entered vehicle with plate: " .. plate)
                local model = GetDisplayNameFromVehicleModel(GetEntityModel(veh)):lower()
                TriggerServerEvent("vehicleSystems:requestState", plate, model)
            end
        else
            if lastVehicle then debugPrint("Exited vehicle.") end
            lastVehicle = nil
        end
    end
end)

RegisterCommand("esc", function()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then return end

    local veh = GetVehiclePedIsIn(ped, false)
    local plate = getPlate(veh)

    local newState = dynamic:toggleEsc()
    escOverrideByPlate[plate] = newState
    notifyESC(newState)

    if isOwnedVehicle then
        TriggerServerEvent("vehicleSystems:setESC", plate, newState)
    end
end, false)
RegisterKeyMapping('esc', 'Toggle ESC', 'keyboard', 'LBRACKET')

RegisterCommand("tcs", function()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then return end

    local veh = GetVehiclePedIsIn(ped, false)
    local plate = getPlate(veh)

    local newState = dynamic:toggleTcs()
    tcsOverrideByPlate[plate] = newState
    notifyTCS(newState)

    if isOwnedVehicle then
        TriggerServerEvent("vehicleSystems:setTCS", plate, newState)
    end
end, false)
RegisterKeyMapping('tcs', 'Toggle TCS', 'keyboard', 'RBRACKET')
