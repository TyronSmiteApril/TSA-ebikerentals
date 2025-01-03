Config = {}

Config.BikeRentalPoints = {
    {model = 'prop_bikerack_1a', coords = vector4(104.04, -777.23, 30.48, 0.0)},
    {model = 'prop_bikerack_1a', coords = vector4(102.25, -776.27, 31.49, 0.0)},
    {model = 'prop_bikerack_1a', coords = vector4(96.88, -774.28, 31.49, 0.0)},
    {model = 'prop_bikerack_1a', coords = vector4(95.0, -773.6, 31.51, 0.0)},
    {model = 'prop_bikerack_1a', coords = vector4(126.98, -1023.12, 29.36, 0.0)},
    {model = 'prop_bikerack_1a', coords = vector4(125.79, -1022.71, 29.36, 0.0)},
    {model = 'prop_bikerack_1a', coords = vector4(129.94, -1024.22, 29.36, 0.0)},
    {model = 'prop_bikerack_2', coords = vector4(298.8, -608.56, 43.42, 241.32)},
    {model = 'prop_bikerack_2', coords = vector4(299.73, -605.32, 43.4, 248.07)},
    {model = 'prop_bikerack_2', coords = vector4(297.49, -611.54, 43.42, 254.73)},
    {model = 'prop_bikerack_2', coords = vector4(298.31, -609.41, 43.42, 244.78)},
    {model = 'prop_bikerack_2', coords = vector4(299.25, -606.59, 43.4, 245.63)},
    {model = 'prop_bikerack_2', coords = vector4(297.14, -612.44, 43.42, 249.86)},
    {model = 'prop_bikerack_1a', coords = vector4(31.64, -164.59, 55.54, 337.09)},
    {model = 'prop_bikerack_1a', coords = vector4(32.92, -165.17, 55.5, 341.47)},
    {model = 'prop_bikerack_1a', coords = vector4(30.4, -164.19, 55.58, 343.45)},
}

Config.BikeModel = 'inductor' -- Default bike model
Config.RentalRate = 100 -- Cost per interval
Config.BillingInterval = 300000 -- Billing rate 300,000(5 minutes) you're billed $100
Config.UseOxTarget = false -- Set to true if you want to use ox-target instead of qb-target
Config.NotificationSystem = 'qbcore' -- Set to 'custom' if you want to use a different notification system

-- Example for custom intervals
-- Config.BillingInterval = 60000 -- 1 minute
-- Config.RentalRate = 50 -- Charge $50 per minute

--[[

    To use other models for the bike racks, replace 'prop_bikerack_2' or 'prop_bikerack_1a'
    with the desired model name. For example:
    {model = 'desired_model_name', coords = vector4(x, y, z, heading)}
]]
