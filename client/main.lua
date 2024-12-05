local QBCore = exports['qb-core']:GetCoreObject()
local rentedBikes = {}

local bikeRentalTargets = Config.BikeRentalPoints
local bikeModelHash = GetHashKey('inductor')

-- Load a model into memory
local function ensureModelLoaded(modelHash)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end
end

-- Spawn a bike
local function spawnBike(target)
    local groundZ = target.coords.z
    local success, adjustedZ = GetGroundZFor_3dCoord(target.coords.x, target.coords.y, target.coords.z + 10.0, false)
    if success then
        groundZ = adjustedZ
    end

    local bike = CreateVehicle(bikeModelHash, target.coords.x, target.coords.y, groundZ, target.coords.w, true, false)
    SetEntityHeading(bike, target.coords.w)
    FreezeEntityPosition(bike, true)
    SetEntityAsMissionEntity(bike, true, true)
    SetVehicleDoorsLocked(bike, 10) -- Lock bike with level 10

    return bike
end

-- Add interaction options
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

-- Cleanup Event Handlers on Resource Stop
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        RemoveEventHandler('bikeRental:client:rentBike')
        RemoveEventHandler('bikeRental:client:returnBike')
        RemoveEventHandler('bikeRental:client:toggleLock')
    end
end)

-- Toggle Lock
RegisterNetEvent('bikeRental:client:toggleLock', function(data)
    local bike = data.entity
    local plate = GetVehicleNumberPlateText(bike)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local bikeCoords = GetEntityCoords(bike)

    -- Ensure the player is near the bike
    if #(playerCoords - bikeCoords) > 2.5 then
        QBCore.Functions.Notify("You must be near the bike to perform this action.", "error")
        return
    end

    -- Ensure the player owns the bike
    if rentedBikes[plate] and rentedBikes[plate].owner == GetPlayerServerId(PlayerId()) then
        -- Turn player to face the bike
        TaskTurnPedToFaceEntity(playerPed, bike, 1000)
        Wait(1000) -- Wait for player to face bike

        -- Play emote
        ExecuteCommand('e mechanic3')
        Wait(3000) -- Wait for emote to complete

        -- Toggle lock state
        local currentLockState = GetVehicleDoorLockStatus(bike)
        local newLockState = (currentLockState == 1) and 10 or 1
        SetVehicleDoorsLocked(bike, newLockState)

        -- Notify player
        QBCore.Functions.Notify(
            newLockState == 10 and "Bike Lock Successfully Added" or "Bike Lock Successfully Removed",
            "success"
        )

        -- Cancel emote
        Wait(1000)
        ExecuteCommand('e c')
    else
        QBCore.Functions.Notify("You do not own this bike.", "error")
    end
end)

-- Return Bike to Rack
local function returnBikeToRack(bike, originalCoords, originalHeading)
    if DoesEntityExist(bike) then
        SetEntityCoords(bike, originalCoords.x, originalCoords.y, originalCoords.z)
        SetEntityHeading(bike, originalHeading)
        FreezeEntityPosition(bike, true)
        SetVehicleDoorsLocked(bike, 10) -- Lock bike
    end
end

-- Rental Setup
CreateThread(function()
    ensureModelLoaded(bikeModelHash)

    for _, target in pairs(bikeRentalTargets) do
        if target.model and target.coords then
            local bike = spawnBike(target)
            setupBikeInteractions(bike, target.coords)
        end
    end
end)

-- Rent Bike
RegisterNetEvent('bikeRental:client:rentBike', function(data)
    local playerPed = PlayerPedId()
    local bike = data.entity
    local plate = GetVehicleNumberPlateText(bike)
    local bikeModel = GetEntityModel(bike)

    -- Prevent duplicate rentals
    if rentedBikes[plate] then return end

    -- Unlock and set player into bike
    FreezeEntityPosition(bike, false)
    SetVehicleDoorsLocked(bike, 1)
    SetPedIntoVehicle(playerPed, bike, -1)

    -- Register bike details
    rentedBikes[plate] = {
        owner = GetPlayerServerId(PlayerId()),
        startTime = GetGameTimer(),
        originalCoords = GetEntityCoords(bike),
        originalHeading = GetEntityHeading(bike)
    }

    -- Notify server and player
    TriggerServerEvent('bikeRental:server:rentBike', plate, bikeModel)
    QBCore.Functions.Notify("You have rented an E-Bike. Enjoy your ride!", "success")
end)

-- Return Bike
RegisterNetEvent('bikeRental:client:returnBike', function(data)
    local bike = data.entity
    local plate = GetVehicleNumberPlateText(bike)

    -- Prevent duplicate returns
    if not rentedBikes[plate] then return end

    local rentalData = rentedBikes[plate]
    local rentalRate = Config.RentalRate or 1
    local billingInterval = Config.BillingInterval or 5
    local totalCharge = math.max(rentalRate, math.floor((GetGameTimer() - rentalData.startTime) / (billingInterval * 60000)) * rentalRate)

    -- Return bike and clear data
    returnBikeToRack(bike, rentalData.originalCoords, rentalData.originalHeading)
    TriggerServerEvent('bikeRental:server:returnBike', plate)
    rentedBikes[plate] = nil

    -- Notify player
    QBCore.Functions.Notify("E-Bike returned. Total charge: $" .. totalCharge, "success")
end)
