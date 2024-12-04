local QBCore = exports['qb-core']:GetCoreObject()
local rentedBikes = {}

local bikeRentalTargets = Config.BikeRentalPoints
local bikeModelHash = GetHashKey('inductor')

local function ensureModelLoaded(modelHash)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end
end

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
    SetVehicleDoorsLocked(bike, 10) -- prevents bike from being usable if lockpicked

    return bike
end

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

RegisterNetEvent('bikeRental:client:toggleLock', function(data)
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

        local currentLockState = GetVehicleDoorLockStatus(bike)
        local newLockState = (currentLockState == 1) and 10 or 1
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

local function returnBikeToRack(bike, originalCoords, originalHeading)
    if DoesEntityExist(bike) then
        SetEntityCoords(bike, originalCoords.x, originalCoords.y, originalCoords.z)
        SetEntityHeading(bike, originalHeading)
        FreezeEntityPosition(bike, true)
        SetVehicleDoorsLocked(bike, 10)
    end
end

CreateThread(function()
    ensureModelLoaded(bikeModelHash)

    for _, target in pairs(bikeRentalTargets) do
        if target.model and target.coords then
            local bike = spawnBike(target)
            setupBikeInteractions(bike, target.coords)
        end
    end
end)

RegisterNetEvent('bikeRental:client:rentBike', function(data)
    local playerPed = PlayerPedId()
    local bike = data.entity
    local plate = GetVehicleNumberPlateText(bike)

    FreezeEntityPosition(bike, false)
    SetVehicleDoorsLocked(bike, 1)
    SetPedIntoVehicle(playerPed, bike, -1)

    rentedBikes[plate] = {
        owner = GetPlayerServerId(PlayerId()),
        startTime = GetGameTimer(),
        originalCoords = GetEntityCoords(bike),
        originalHeading = GetEntityHeading(bike)
    }
    QBCore.Functions.Notify('You have rented an E-Bike. Enjoy your ride!', 'success')
end)

RegisterNetEvent('bikeRental:client:returnBike', function(data)
    local bike = data.entity
    local plate = GetVehicleNumberPlateText(bike)
    local rentalData = rentedBikes[plate]
    local totalCharge = math.max(Config.RentalRate or 1, math.floor((GetGameTimer() - rentalData.startTime) / (Config.BillingInterval or 5)) * (Config.RentalRate or 1))

    returnBikeToRack(bike, rentalData.originalCoords, rentalData.originalHeading)
    rentedBikes[plate] = nil
    TriggerServerEvent('bikeRental:server:returnBike', plate, totalCharge)
    QBCore.Functions.Notify('E-Bike returned. Total charge: $' .. totalCharge, 'success')
end)

CreateThread(function()
    while true do
        Wait(300000)
        for plate, rentalData in pairs(rentedBikes) do
            if not IsAnyPlayerNearCoords(rentalData.originalCoords, 20.0) then
                returnBikeToRack(GetVehiclePedIsIn(PlayerPedId(), false), rentalData.originalCoords, rentalData.originalHeading)
                rentedBikes[plate] = nil
            end
        end
    end
end)
