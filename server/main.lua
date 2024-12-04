local QBCore = exports['qb-core']:GetCoreObject()

local rentedBikes = {}

RegisterNetEvent('bikeRental:server:rentBike', function(plate, playerId)
    local src = source
    rentedBikes[plate] = {renter = playerId, rentTime = os.time()}
end)

RegisterNetEvent('bikeRental:server:returnBike', function(plate, totalCharge)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        local accountName = 'bank'
        if totalCharge > 0 then
            local success = Player.Functions.RemoveMoney(accountName, totalCharge, 'E-Bike Rental Fee')
            if success then
                TriggerClientEvent('QBCore:Notify', src, 'You have been charged $' .. totalCharge .. ' for your rental.', 'success')
            else
                TriggerClientEvent('QBCore:Notify', src, 'Unable to deduct money from your account. Please ensure you have enough funds.', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'No charge for the rental as the duration was too short.', 'success')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'An error occurred while returning the bike. Please try again.', 'error')
    end
    rentedBikes[plate] = nil
end)
