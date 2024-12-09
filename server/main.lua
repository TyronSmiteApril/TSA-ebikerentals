local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('bikeRental:server:rentBike', function(plate, bikeModel)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then
        print("^1[ERROR]^0 Unable to find player for bike rental.")
        return
    end

    -- Log rental event (if needed)
    print(("[INFO] Player %s rented a bike with plate %s."):format(Player.PlayerData.citizenid, plate))
end)

RegisterNetEvent('bikeRental:server:returnBike', function(plate, charge)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then
        print("^1[ERROR]^0 Unable to find player for bike return.")
        return
    end

    -- Deduct charge from player's bank account
    if Player.Functions.RemoveMoney('bank', charge, 'E-Bike rental charge') then
        TriggerClientEvent('QBCore:Notify', src, "You were charged $" .. charge .. " for your rental.", "success")
        print(("[INFO] Player %s returned bike %s and was charged $%d."):format(Player.PlayerData.citizenid, plate, charge))
    else
        TriggerClientEvent('QBCore:Notify', src, "You don't have enough money to pay the rental fee!", "error")
        print(("[WARNING] Player %s could not afford the charge for bike %s."):format(Player.PlayerData.citizenid, plate))
    end
end)
