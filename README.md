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

- **Rental Locations**: Use `vector3` format to specify coordinates for rental points.
- **Rental Rate**: Set the rental rate per interval and the interval duration.

```lua
Config.BikeRentalPoints = {
    vector3(104.04, -777.23, 30.48),
    vector3(102.25, -776.27, 31.49),
    vector3(96.88, -774.28, 31.49),
    vector3(95.0, -773.6, 31.51)
}

Config.RentalRate = 1 -- Cost per interval
Config.BillingInterval = 5 -- Interval in minutes for billing
Config.AbandonPenalty = 500 -- Penalty for not returning the bike
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

Feel free to reach out if you encounter issues or have questions. Contributions are appreciated!

## Screenshots

soon.tm

