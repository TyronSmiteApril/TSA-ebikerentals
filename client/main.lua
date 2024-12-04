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
    SetVehicleDoorsLocked(bike, 10) -- set to 10 so if you LOCKPICK the bike you cant drive it without renting

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
        },
        distance = 2.5,
    })
end

local function returnBikeToRack(bike, originalCoords, originalHeading)
    SetEntityCoords(bike, originalCoords.x, originalCoords.y, originalCoords.z)
    SetEntityHeading(bike, originalHeading)
    FreezeEntityPosition(bike, true)
    SetVehicleDoorsLocked(bike, 10)
end

CreateThread(function()
    if not bikeRentalTargets or type(bikeRentalTargets) ~= "table" then
        print("^1Error: Config.BikeRentalPoints is invalid. Please define rental locations in config.lua.^0")
        return
    end

    ensureModelLoaded(bikeModelHash)

    for _, target in pairs(bikeRentalTargets) do
        if target.model and target.coords then
            local bike = spawnBike(target)
            setupBikeInteractions(bike, target.coords)
        else
            print("^1Error: Skipping invalid target. Each entry must have 'model' and 'coords'.^0")
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
    TriggerServerEvent('bikeRental:server:rentBike', plate)
    QBCore.Functions.Notify('You have rented an E-Bike. Enjoy your ride!', 'success')
end)

RegisterNetEvent('bikeRental:client:returnBike', function(data)
    local bike = data.entity
    local plate = GetVehicleNumberPlateText(bike)
    local rentalRate = Config.RentalRate or 1
    local billingInterval = Config.BillingInterval or 5

    if not rentedBikes[plate] then
        QBCore.Functions.Notify('This bike has already been returned or is invalid.', 'error')
        return
    end

    local rentalData = rentedBikes[plate]
    local rentalDuration = (GetGameTimer() - rentalData.startTime) / 60000 
    local totalCharge = math.max(rentalRate, math.floor(rentalDuration / billingInterval) * rentalRate)

    returnBikeToRack(bike, rentalData.originalCoords, rentalData.originalHeading)

    rentedBikes[plate] = nil

    TriggerServerEvent('bikeRental:server:returnBike', plate, totalCharge)
    QBCore.Functions.Notify('E-Bike returned.')
end)

CreateThread(function()
    while true do
        Wait(300000)
        for plate, rentalData in pairs(rentedBikes) do
            local bike = GetVehiclePedIsIn(PlayerPedId(), false) 
            if DoesEntityExist(bike) then
                local bikeCoords = GetEntityCoords(bike)
                local playersNearby = false

                for _, playerId in ipairs(GetActivePlayers()) do
                    local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
                    if #(playerCoords - bikeCoords) < 20.0 then
                        playersNearby = true
                        break
                    end
                end

                if not playersNearby and (GetGameTimer() - rentalData.startTime) / 60000 > 5 then

                    returnBikeToRack(bike, rentalData.originalCoords, rentalData.originalHeading)
                    rentedBikes[plate] = nil
                    print("[E-Bike Rental] Returned unattended bike to rack: " .. plate)
                end
            else
                rentedBikes[plate] = nil
            end
        end
    end
end)
