local QBCore = exports['qb-core']:GetCoreObject()
local rentedBikes = {}
local bikeRentalTargets = Config.BikeRentalPoints
local bikeModelHash = GetHashKey('inductor')

-- Event handler storage
local eventHandlers = {}

-- Ensure the model is loaded
local function ensureModelLoaded(modelHash)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end
end

-- Spawn a bike
local function spawnBike(target)
    local groundZ = target.coords.z
    local maxRetries = 10 -- Retry up to 10 times to find the ground height
    local success, adjustedZ

    -- Wait for the world to fully load before trying to calculate ground height
    Wait(5000) -- Delay for 5 seconds after resource start

    for i = 1, maxRetries do
        success, adjustedZ = GetGroundZFor_3dCoord(target.coords.x, target.coords.y, target.coords.z + 10.0, false)
        if success then
            groundZ = adjustedZ
            break
        else
            Wait(100) -- Wait before retrying
        end
    end

    -- Create the bike at the calculated or default height
    local bike = CreateVehicle(bikeModelHash, target.coords.x, target.coords.y, groundZ, target.coords.w, true, false)
    SetEntityHeading(bike, target.coords.w)
    FreezeEntityPosition(bike, true)
    SetEntityAsMissionEntity(bike, true, true)
    SetVehicleDoorsLocked(bike, 10) -- Lock bike with level 10

    return bike
end

-- Setup interactions for bikes
local function setupBikeInteractions(bike, targetCoords)
    exports['qb-target']:AddTargetEntity(bike, {
        options = {
            {
                type = "client",
                event = "bikeRental:client:rentBike",
                icon = "fas fa-bicycle",
                label = "Rent an E-Bike",
                canInteract = function(entity)
                    local plate = GetVehicleNumberPlateText(entity)
                    return rentedBikes[plate] == nil
                end,
            },
            {
                type = "client",
                event = "bikeRental:client:returnBike",
                icon = "fas fa-undo",
                label = "Return E-Bike",
                canInteract = function(entity)
                    local plate = GetVehicleNumberPlateText(entity)
                    return rentedBikes[plate] ~= nil and rentedBikes[plate].owner == GetPlayerServerId(PlayerId())
                end,
            },
            {
                type = "client",
                event = "bikeRental:client:toggleLock",
                icon = "fas fa-lock",
                label = "Add/Remove Bike Lock",
                canInteract = function(entity)
                    local plate = GetVehicleNumberPlateText(entity)
                    return rentedBikes[plate] ~= nil and rentedBikes[plate].owner == GetPlayerServerId(PlayerId())
                end,
            },
        },
        distance = 2.5,
    })
end

-- Clean up event handlers
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, handlerId in pairs(eventHandlers) do
            if handlerId then
                RemoveEventHandler(handlerId)
            end
        end
    end
end)

-- Register events and store handler IDs
local function registerEvent(eventName, callback)
    local handlerId = AddEventHandler(eventName, callback)
    eventHandlers[eventName] = handlerId
end

-- Toggle bike lock
registerEvent('bikeRental:client:toggleLock', function(data)
    local bike = data.entity
    local plate = GetVehicleNumberPlateText(bike)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local bikeCoords = GetEntityCoords(bike)

    if #(playerCoords - bikeCoords) > 2.5 then
        QBCore.Functions.Notify("You must be near the bike to perform this action.", "error")
        return
    end

    if rentedBikes[plate] and rentedBikes[plate].owner == GetPlayerServerId(PlayerId()) then
        TaskTurnPedToFaceEntity(playerPed, bike, 1000)
        Wait(1000)
        ExecuteCommand('e mechanic3')
        Wait(3000)

        local lockState = GetVehicleDoorLockStatus(bike)
        local newLockState = (lockState == 1) and 10 or 1
        SetVehicleDoorsLocked(bike, newLockState)
        QBCore.Functions.Notify(
            newLockState == 10 and "Bike Lock Successfully Added" or "Bike Lock Successfully Removed",
            "success"
        )

        Wait(1000)
        ExecuteCommand('e c')
    else
        QBCore.Functions.Notify("You do not own this bike.", "error")
    end
end)

-- Rent a bike
registerEvent('bikeRental:client:rentBike', function(data)
    local playerPed = PlayerPedId()
    local bike = data.entity
    local plate = GetVehicleNumberPlateText(bike)
    local bikeModel = GetEntityModel(bike)

    if rentedBikes[plate] then return end

    FreezeEntityPosition(bike, false)
    SetVehicleDoorsLocked(bike, 1)
    SetPedIntoVehicle(playerPed, bike, -1)

    rentedBikes[plate] = {
        owner = GetPlayerServerId(PlayerId()),
        startTime = GetGameTimer(),
        originalCoords = GetEntityCoords(bike),
        originalHeading = GetEntityHeading(bike),
    }

    TriggerServerEvent('bikeRental:server:rentBike', plate, bikeModel)
    QBCore.Functions.Notify("You have rented an E-Bike. Enjoy your ride!", "success")
end)

-- Return a bike
registerEvent('bikeRental:client:returnBike', function(data)
    local bike = data.entity
    local plate = GetVehicleNumberPlateText(bike)

    if not rentedBikes[plate] then return end

    local rental = rentedBikes[plate]
    local rate = Config.RentalRate or 100
    local interval = Config.BillingInterval or 5
    local rentalDuration = (GetGameTimer() - rental.startTime) / 60000
    local totalCharge = math.max(rate, math.floor(rentalDuration / interval) * rate)

    SetEntityCoords(bike, rental.originalCoords.x, rental.originalCoords.y, rental.originalCoords.z)
    SetEntityHeading(bike, rental.originalHeading)
    FreezeEntityPosition(bike, true)
    SetVehicleDoorsLocked(bike, 10)

    TriggerServerEvent('bikeRental:server:returnBike', plate, totalCharge)
    rentedBikes[plate] = nil
    QBCore.Functions.Notify("E-Bike returned.")
end)

-- Setup bike rental points on startup
CreateThread(function()
    ensureModelLoaded(bikeModelHash)

    for _, target in pairs(bikeRentalTargets) do
        if target.model and target.coords then
            local bike = spawnBike(target)
            setupBikeInteractions(bike, target.coords)
        end
    end
end)
