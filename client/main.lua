local QBCore = exports['qb-core']:GetCoreObject()

local rentedBikes = {}
local cooldowns = {} -- Table to store cooldowns for plates

-- Load bike rental targets from config
local bikeRentalTargets = Config.BikeRentalPoints 

local bikeModelHash = GetHashKey(Config.BikeModel or 'inductor')

CreateThread(function()
    if not Config.BikeRentalPoints or #Config.BikeRentalPoints == 0 then
        print("^1[ERROR] No rental points found in Config.BikeRentalPoints!^0")
        return
    end

    for _, point in pairs(Config.BikeRentalPoints) do
        local x, y, z, heading = point.coords.x, point.coords.y, point.coords.z, point.coords.w

        -- Ensure the bike model is loaded
        if not HasModelLoaded(bikeModelHash) then
            RequestModel(bikeModelHash)
            while not HasModelLoaded(bikeModelHash) do
                Wait(10)
            end
        end

        -- Find the ground Z coordinate
        local groundZ = z
        local attempts = 0
        while attempts < 10 do -- Try up to 10 times to find the ground Z
            local foundGround, groundZValue = GetGroundZFor_3dCoord(x, y, z + 10.0, false)
            if foundGround then
                groundZ = groundZValue
                break
            end
            Wait(100) -- Wait before retrying
            attempts = attempts + 1
        end

        -- Spawn the bike at the rental point
        local bike = CreateVehicle(bikeModelHash, x, y, groundZ, heading, true, false)
        SetEntityHeading(bike, heading)
        FreezeEntityPosition(bike, true) -- Keep the bike stationary until rented
        SetEntityAsMissionEntity(bike, true, true)
        SetVehicleDoorsLocked(bike, 10) -- Lock the bike set as 10 so if lockpicked before rented CANT be driven other otions here https://docs.fivem.net/natives/?_0xB664292EAECF7FA6

        -- Add qb-target interaction to the bike
        exports['qb-target']:AddTargetEntity(bike, {
            options = {
                {
                    type = "client",
                    event = "bikeRental:client:rentBike",
                    icon = "fas fa-bicycle",
                    label = "Rent this E-Bike",
                    canInteract = function(entity)
                        local plate = GetVehicleNumberPlateText(entity)
                        return not rentedBikes[plate] -- Only allow rent if the bike is not rented
                    end
                },
                {
                    type = "client",
                    event = "bikeRental:client:returnBike",
                    icon = "fas fa-undo",
                    label = "Return this E-Bike",
                    canInteract = function(entity)
                        local plate = GetVehicleNumberPlateText(entity)
                        return rentedBikes[plate] ~= nil and rentedBikes[plate].playerId == GetPlayerServerId(PlayerId()) -- Only allow return if it's the player's rented bike
                    end
                },
                {
                    type = "client",
                    event = "bikeRental:client:toggleLock",
                    icon = "fas fa-lock",
                    label = "Toggle Lock",
                    canInteract = function(entity)
                        local plate = GetVehicleNumberPlateText(entity)
                        return rentedBikes[plate] ~= nil and rentedBikes[plate].playerId == GetPlayerServerId(PlayerId()) -- Only allow lock/unlock if it's the player's rented bike
                    end
                }
            },
            distance = 2.5
        })
    end
end)

RegisterNetEvent('bikeRental:client:rentBike', function(data)
    local bike = data.entity
    local plate = GetVehicleNumberPlateText(bike)
    local coords = GetEntityCoords(bike)
    local heading = GetEntityHeading(bike)

    -- Cooldown Check
    if cooldowns[plate] and (GetGameTimer() - cooldowns[plate]) < 3000 then
        QBCore.Functions.Notify("Action is on cooldown.", "error")
        return
    end
    cooldowns[plate] = GetGameTimer() -- Set cooldown timer

    -- Ensure bike exists and is not already rented
    if not DoesEntityExist(bike) or rentedBikes[plate] then
        QBCore.Functions.Notify("This bike is not available for rent.", "error")
        return
    end

    -- Register the bike as rented
    rentedBikes[plate] = {
        playerId = GetPlayerServerId(PlayerId()),
        startTime = GetGameTimer() / 1000,
        originalPosition = {x = coords.x, y = coords.y, z = coords.z, heading = heading} -- Store original position
    }

    -- Unlock and allow the player to ride the bike
    FreezeEntityPosition(bike, false)
    SetVehicleDoorsLocked(bike, 1) -- Unlock bike
    SetPedIntoVehicle(PlayerPedId(), bike, -1)

    -- Notify the player
    QBCore.Functions.Notify("You have rented this bike. Enjoy your ride!", "success")

    -- Trigger the server to track the rental
    TriggerServerEvent('bikeRental:server:rentBike', plate, GetPlayerServerId(PlayerId()))
end)

RegisterNetEvent('bikeRental:client:returnBike', function(data)
    local bike = data.entity
    local plate = GetVehicleNumberPlateText(bike)

    -- Cooldown Check
    if cooldowns[plate] and (GetGameTimer() - cooldowns[plate]) < 3000 then
        QBCore.Functions.Notify("Action is on cooldown.", "error")
        return
    end
    cooldowns[plate] = GetGameTimer() -- Set cooldown timer

    -- Return Logic
    if not rentedBikes[plate] or rentedBikes[plate].playerId ~= GetPlayerServerId(PlayerId()) then
        QBCore.Functions.Notify("This is not your rental bike.", "error")
        return
    end

    -- Move bike back to its original position
    local originalPosition = rentedBikes[plate].originalPosition
    SetEntityCoords(bike, originalPosition.x, originalPosition.y, originalPosition.z, false, false, false, true)
    SetEntityHeading(bike, originalPosition.heading)
    FreezeEntityPosition(bike, true) -- Keep the bike stationary
    SetVehicleDoorsLocked(bike, 10) -- Lock the bike set as 10 so if lockpicked before rented CANT be driven other otions here https://docs.fivem.net/natives/?_0xB664292EAECF7FA6

    -- Process return
    TriggerServerEvent('bikeRental:server:returnBike', plate, rentedBikes[plate].startTime)
    rentedBikes[plate] = nil
    QBCore.Functions.Notify("Bike returned successfully.", "success")
end)

RegisterCommand('cancelEmoteTest', function()
    ClearPedTasksImmediately(PlayerPedId())
end, false)

RegisterNetEvent('bikeRental:client:toggleLock', function(data)
    local bike = data.entity
    local plate = GetVehicleNumberPlateText(bike)
    local playerPed = PlayerPedId()
    local bikeCoords = GetEntityCoords(bike)

    -- Ensure the player owns the bike
    if not rentedBikes[plate] or rentedBikes[plate].playerId ~= GetPlayerServerId(PlayerId()) then
        QBCore.Functions.Notify("You do not own this bike.", "error")
        return
    end

    -- Move the player to the bike
    TaskGoToCoordAnyMeans(playerPed, bikeCoords.x, bikeCoords.y, bikeCoords.z, 1.0, 0, 0, 786603, 0.0)
    local timeout = 5000 -- 5 seconds to walk to the bike
    local startTime = GetGameTimer()

    -- Wait until the player is near the bike or timeout occurs
    while #(GetEntityCoords(playerPed) - bikeCoords) > 1.5 do
        Wait(100)
        if GetGameTimer() - startTime > timeout then
            QBCore.Functions.Notify("Could not reach the bike.", "error")
            return
        end
    end

    -- Make the player face the bike
    TaskTurnPedToFaceEntity(playerPed, bike, 1000)
    Wait(1000) -- Allow time for the player to face the bike

    -- Trigger the mechanic3 emote
    ExecuteCommand('e mechanic3') -- Trigger the custom emote system
    Wait(3000) -- Wait for the emote duration

    -- Toggle lock state
    local currentLockState = GetVehicleDoorLockStatus(bike)
    local newLockState = (currentLockState == 1) and 10 or 1 -- Toggle between unlocked (1) and locked (10)
    SetVehicleDoorsLocked(bike, newLockState)

    -- Notify the player
    QBCore.Functions.Notify(
        newLockState == 10 and "Bike locked." or "Bike unlocked.",
        "success"
    )

    -- Cancel the emote
    ExecuteCommand('e c') -- Cancel the custom emote system
    Wait(500) -- Small delay to ensure /e c processes
    ClearPedTasksImmediately(playerPed) -- Backup to force clear animations
end)
