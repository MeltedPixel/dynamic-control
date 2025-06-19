local QBCore = exports['qb-core']:GetCoreObject()
local dynamic = exports["legacydmc_dynamic"]
local currentVehicle = nil
local escState = false
local tcsState = false

local systemHandlers = {
    ESC = dynamic.toggleEsc,
    TCS = dynamic.toggleTcs
}

local function getVehicleModel(vehicle)
    return GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()
end

local function supportsSystem(model, system)
    return Config.VehicleSystems[model] and Config.VehicleSystems[model][system]
end

local function toggleSystem(system, state)
    local handler = systemHandlers[system]
    if handler then
        handler(state)
    else
        print(("[WARNING] No toggle function for system: %s"):format(system))
    end
end

local function notifySystem(system, state, prefix)
    local name = system:upper()
    local type = state and "success" or "error"
    local status = state and "Enabled" or "Disabled"
    local msg = string.format("%s%s %s", prefix or "", name, status)
    QBCore.Functions.Notify(msg, type)
end

AddEventHandler("baseevents:enteredVehicle", function(veh, seat, model)
    if seat ~= -1 then return end

    currentVehicle = veh
    local modelName = getVehicleModel(veh)

    if supportsSystem(modelName, "ESC") then
        escState = true
        toggleSystem("ESC", true)
        notifySystem("ESC", true, "(Auto) ")
    else
        escState = false
    end

    if supportsSystem(modelName, "TCS") then
        tcsState = true
        toggleSystem("TCS", true)
        notifySystem("TCS", true, "(Auto) ")
    else
        tcsState = false
    end

    print(("[DEBUG] Vehicle: %s | ESC: %s | TCS: %s"):format(modelName, tostring(escState), tostring(tcsState)))
end)

AddEventHandler("baseevents:leftVehicle", function()
    currentVehicle = nil
end)

RegisterCommand("toggleesc", function()
    if not currentVehicle then return QBCore.Functions.Notify("ESC unavailable (no vehicle)", "error") end

    local modelName = getVehicleModel(currentVehicle)
    if not supportsSystem(modelName, "ESC") then
        return QBCore.Functions.Notify("This vehicle doesn't support ESC.", "error")
    end

    escState = not escState
    toggleSystem("ESC", escState)
    notifySystem("ESC", escState)
end, false)

RegisterKeyMapping("toggleesc", "Toggle ESC", "keyboard", "LBRACKET")

RegisterCommand("toggletcs", function()
    if not currentVehicle then return QBCore.Functions.Notify("TCS unavailable (no vehicle)", "error") end

    local modelName = getVehicleModel(currentVehicle)
    if not supportsSystem(modelName, "TCS") then
        return QBCore.Functions.Notify("This vehicle doesn't support TCS.", "error")
    end

    tcsState = not tcsState
    toggleSystem("TCS", tcsState)
    notifySystem("TCS", tcsState)
end, false)

RegisterKeyMapping("toggletcs", "Toggle TCS", "keyboard", "RBRACKET")
