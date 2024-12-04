# E-Bike Rental Script for FiveM



This repository contains an E-Bike rental script for FiveM. The script allows players to rent an E-Bike from designated rental spots, track rental duration, and return the bikes. Follow the instructions below to add the script to your FiveM server.

## Features

- Multiple rental locations using `prop_bikerack_2` and `prop_bikerack_1a`
- Time-based rental cost calculation (\$1 per 5 minutes)
- Easy-to-use interaction with the bike for renting and returning
- Dynamic billing from player bank accounts using **qb-banking**
- Supports qb-target and ox-target for interactions
- Automatic removal of bikes left unattended for more than 5 minutes

## Changing the Bike Model

If you would like to use a custom bike model instead of the default `inductor`, you can easily change this in the `main.lua` script. Look for the following line:

```lua
local bikeModelHash = GetHashKey('inductor')
```

Replace `'inductor'` with the name of the bike model you want to use. Make sure that the model name matches the one available in your server resources.

For example, if your custom bike model is named `'custom_bike'`, change it to:

```lua
local bikeModelHash = GetHashKey('custom_bike')
```

This will make the script spawn your custom bike model instead.

## Requirements

This script requires the following dependencies:

- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-target](https://github.com/BerkieBb/qb-target) or [ox-target](https://github.com/overextended/ox_target)
- [qb-banking](https://github.com/qbcore-framework/qb-banking)

## Installation

### 1. Import SQL File

To track rental data, you need to import the SQL file into your MySQL database:

1. Place the SQL file (`ebike-rental.sql`) in the root folder of the resource.
2. Import the SQL file using phpMyAdmin or the MySQL command line.

### 2. Configure Rental Points and Rates

Edit the `config.lua` file to set up rental points and rental rates:

- **Rental Locations**: Use `vector4` format to specify coordinates for rental points.
- **Rental Rate**: Set the rental rate per interval and the interval duration.
- **Billing Interval**: Billing rate 300,000(5 minutes) you're billed $100

```lua
Config = {}

Config.BikeRentalPoints = {
    {model = 'prop_bikerack_1a', coords = vector4(104.04, -777.23, 30.48, 0.0)},
    {model = 'prop_bikerack_1a', coords = vector4(102.25, -776.27, 31.49, 0.0)},
    {model = 'prop_bikerack_1a', coords = vector4(96.88, -774.28, 31.49, 0.0)},
    {model = 'prop_bikerack_1a', coords = vector4(95.0, -773.6, 31.51, 0.0)},
    {model = 'prop_bikerack_1a', coords = vector4(126.98, -1023.12, 29.36, 0.0)},
    {model = 'prop_bikerack_1a', coords = vector4(125.79, -1022.71, 29.36, 0.0)},
    {model = 'prop_bikerack_1a', coords = vector4(129.94, -1024.22, 29.36, 0.0)},
    {model = 'prop_bikerack_1a', coords = vector4(298.8, -608.56, 43.42, 241.32)},
    {model = 'prop_bikerack_1a', coords = vector4(299.73, -605.32, 43.4, 248.07)},
    {model = 'prop_bikerack_1a', coords = vector4(297.49, -611.54, 43.42, 254.73)},
    {model = 'prop_bikerack_1a', coords = vector4(298.31, -609.41, 43.42, 244.78)},
    {model = 'prop_bikerack_1a', coords = vector4(299.25, -606.59, 43.4, 245.63)},
    {model = 'prop_bikerack_1a', coords = vector4(297.14, -612.44, 43.42, 249.86)},
}

Config.RentalRate = 100 -- Cost per interval
Config.BillingInterval = 300000 -- Billing rate 300,000(5 minutes) you're billed $100
Config.UseOxTarget = false -- Set to true if you want to use ox-target instead of qb-target
Config.NotificationSystem = 'qbcore' -- Set to 'custom' if you want to use a different notification system
```

### 3. Configuring Target System

This script supports both **qb-target** and **ox-target**. By default, **qb-target** is used, but you can change this easily by modifying the `config.lua` file. Note that `ox-target` is optional and not required for the script to function with `qb-target`.

Add the following configuration to your `config.lua`:

```lua
Config.UseOxTarget = false -- Set to true if you want to use ox-target instead of qb-target
```

- If `Config.UseOxTarget` is set to `false`, the script will use **qb-target** for interactions.
- If `Config.UseOxTarget` is set to `true`, the script will use **ox-target** for interactions.

The script is written to automatically switch between the two targeting systems based on this configuration, so ensure to set this parameter according to your preference.

### 4. Configuring Notification System

This script uses **QBCore's** default notification system (`QBCore:Notify`), but you can configure it to use a custom notification system if desired.

In `config.lua`, add the following configuration:

```lua
Config.NotificationSystem = 'qbcore' -- Set to 'custom' if you want to use a different notification system
```

- If `Config.NotificationSystem` is set to `'qbcore'`, the script will use QBCore's built-in notification (`QBCore:Notify`).
- If set to `'custom'`, you can replace notification calls in the code with your own custom events.

### Notification System Changes in `server.lua`

In `server.lua`, the notification system is used to notify players of certain events, such as returning the bike or having insufficient funds. The relevant code is structured like this:

```lua
if Config.NotificationSystem == 'custom' then
    TriggerClientEvent('yourCustomNotify', src, 'Your custom message here')
else
    TriggerClientEvent('QBCore:Notify', src, 'Your QBCore message here', 'type')
end
```

- Replace `'yourCustomNotify'` with your custom notification event.
- Replace `'Your custom message here'` with the desired message for your notification system.

### 5. Starting the Script

Add the following line to your `server.cfg` to start the script:

```cfg
ensure TSA-ebikerentals
```

## Bike Locking and Abandonment Handling

### Locking and Unlocking Rental Bikes

Players can now lock and unlock their rental bikes to prevent them from being stolen. To lock or unlock a bike, use the appropriate command or interaction in-game. This feature ensures the player's bike remains secure when left unattended temporarily.

### Handling Abandoned Bikes

To ensure that rental bikes are returned properly, the script includes a feature that will automatically despawn bikes left unattended for at least 5 minutes.&#x20;

- Bikes are checked every minute to determine if they are abandoned.
- If no players are detected nearby for more than 5 minutes, the bike will be despawned.
- To adjust the removal time, modify the relevant section in the script.

## Usage

- Players can rent an E-Bike by interacting with a rental point (`prop_bikerack_2` and `prop_bikerack_1a`).
- The rental cost is calculated based on time used.
- Players can return their bike by interacting with the bike at any bike rack in the city.

## Development

Feel free to contribute to the script. Pull requests are welcome! To make changes:

- Modify the script as needed and create a pull request to contribute.

## Credits

- Original source code adapted from QB-Rental for use with bikes.

## Dependencies

- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-target](https://github.com/BerkieBb/qb-target)
- [ox-target](https://github.com/overextended/ox_target) (optional, if using `Config.UseOxTarget = true`)
- [qb-banking](https://github.com/qbcore-framework/qb-banking)

## Support
no... figure it out!

## Screenshots
![bike5](https://github.com/user-attachments/assets/9e265775-ba7a-4ee1-a721-3593b6667433)
![bike7](https://github.com/user-attachments/assets/973156ad-a240-4431-98e4-d1ee86f48622)
![bike](https://github.com/user-attachments/assets/dc94a27a-3d42-4b92-8fe0-1f381b90e82c)
![bike2](https://github.com/user-attachments/assets/ff53603b-32c1-4fb0-8cd9-cdceb451ed0a)
![bike3](https://github.com/user-attachments/assets/bf98bb87-cd7d-41dd-86ae-78014c15163b)
![bike4](https://github.com/user-attachments/assets/15f1e049-59c0-4475-ab0a-0e706ae584c0)
![bike6](https://github.com/user-attachments/assets/8641c635-c143-4abd-9c76-005c69419384)



