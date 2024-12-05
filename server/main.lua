local QBCore = exports['qb-core']:GetCoreObject()

-- Rent a bike: Insert rental record into the database
RegisterNetEvent('bikeRental:server:rentBike', function(plate, bikeModel)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        local citizenid = Player.PlayerData.citizenid

        -- Insert rental into the database
        exports.oxmysql:insert(
            'INSERT INTO rented_bikes (citizenid, bike_model) VALUES (?, ?)',
            {citizenid, bikeModel},
            function(result)
                if result then
                    print('[Bike Rental] Rented bike inserted for CitizenID: ' .. citizenid)
                else
                    print('[Bike Rental] Failed to insert rental for CitizenID: ' .. citizenid)
                end
            end
        )
    end
end)

-- Return a bike: Remove rental record from the database
RegisterNetEvent('bikeRental:server:returnBike', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        local citizenid = Player.PlayerData.citizenid

        -- Remove rental from the database
        exports.oxmysql:execute(
            'DELETE FROM rented_bikes WHERE citizenid = ?',
            {citizenid},
            function(affectedRows)
                if affectedRows > 0 then
                    print('[Bike Rental] Rental cleared for CitizenID: ' .. citizenid)
                else
                    print('[Bike Rental] No rental found to clear for CitizenID: ' .. citizenid)
                end
            end
        )
    end
end)
