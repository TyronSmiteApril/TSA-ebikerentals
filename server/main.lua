local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('bikeRental:server:rentBike', function(plate, playerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then
        print("[ERROR] Player not found for rentBike event")
        return
    end

    -- Logging the rental
    print(('[E-Bike Rental] Player %s (ID: %s) rented a bike with plate %s'):format(Player.PlayerData.citizenid, src, plate))
end)

RegisterNetEvent('bikeRental:server:returnBike', function(plate, rentalStartTime)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then
        print("[ERROR] Player not found for returnBike event")
        return
    end

    -- Calculate rental time and charges
    local rentalDuration = (GetGameTimer() / 1000 - rentalStartTime) / 60 -- Time in minutes
    local rentalRate = Config.RentalRate or 100
    local billingInterval = (Config.BillingInterval or 300000) / 60000 -- Convert milliseconds to minutes
    local charge = math.ceil(rentalDuration / billingInterval) * rentalRate

    -- Deduct money from the player's bank account
    local bankBalance = Player.Functions.GetMoney('bank')
    if bankBalance >= charge then
        Player.Functions.RemoveMoney('bank', charge, 'E-Bike Rental Fee')
        TriggerClientEvent('QBCore:Notify', src, ('You were charged $%d for renting the bike.'):format(charge), 'success')
        print(('[E-Bike Rental] Player %s (ID: %s) returned bike with plate %s and was charged $%d'):format(Player.PlayerData.citizenid, src, plate, charge))
    else
        TriggerClientEvent('QBCore:Notify', src, 'You do not have enough money to pay the rental fee!', 'error')
        print(('[E-Bike Rental] Player %s (ID: %s) attempted to return bike with plate %s but did not have enough money'):format(Player.PlayerData.citizenid, src, plate))
    end
end)

-- Logging for debugging purposes
print("[E-Bike Rental] Server script loaded successfully.")

