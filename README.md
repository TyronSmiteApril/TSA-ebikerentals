# E-Bike Rental Script for FiveM

![E-Bike Rental](https://example.com/rental-image.png)

This repository contains an E-Bike rental script for FiveM. The script allows players to rent an E-Bike from designated rental spots, track rental duration, and return the bikes. Follow the instructions below to add the script to your FiveM server.

## Features
- Multiple rental locations using `prop_bikerack_2` and `prop_bikerack_1a`
- Time-based rental cost calculation ($1 per 5 minutes)
- Easy-to-use `/returnbike` command for returning the rental

## Requirements
This script requires the following dependencies:
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-target](https://github.com/BerkieBb/qb-target) or [ox-target](https://github.com/overextended/ox_target)

## Installation

### 1. Add Items to `qb-core`
You need to add the rental papers item to your server's `qb-core/shared/items.lua` file. Add the following code:

```lua
["rentalpapers"] = {"name" = "rentalpapers", "label" = "Rental Papers", "weight" = 50, "type" = "item", "image" = "rentalpapers.png", "unique" = true, "useable" = false, "shouldClose" = false, "combinable" = nil, "description" = "Rental paperwork, Yea its mine."},
```

### 2. Import SQL File
To track rental data, you need to import the SQL file into your MySQL database:

1. Place the SQL file (e.g., `ebike_rental.sql`) in the root folder of the resource.
2. Import the SQL file using phpMyAdmin or the MySQL command line.

### 3. **Rental Rate and Billing Interval**: In `config.lua`, you can adjust the rental rate by modifying `Config.RentalRate`. You can also change the time interval for billing by setting `Config.BillingInterval`. For example:

```lua
Config.RentalRate = 1 -- Cost per interval
Config.BillingInterval = 5 -- Interval in minutes for billing
```

This means players will be charged $1 for every 5 minutes they have the bike rented.

### 4. Configuring Target System
This script supports both **qb-target** and **ox-target**. By default, **qb-target** is used, but you can change this easily by modifying the `config.lua` file.

Add the following configuration to your `config.lua`:

```lua
Config.UseOxTarget = false -- Set to true if you want to use ox-target instead of qb-target
```

- If `Config.UseOxTarget` is set to `false`, the script will use **qb-target** for interactions.
- If `Config.UseOxTarget` is set to `true`, the script will use **ox-target** for interactions.

The script is written to automatically switch between the two targeting systems based on this configuration, so ensure to set this parameter according to your preference.

### 5. Configuring Notification System
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

### 6. Starting the Script
Add the following line to your `server.cfg` to start the script:
```cfg
ensure TSA-ebikerentals
```

## Usage
- Players can rent an E-Bike by interacting with a rental point (`prop_bikerack_2` and `prop_bikerack_1a`).
- The rental cost is calculated based on time used.
- Players can return their bike using the `/returnbike` command.

## Development
Feel free to contribute to the script. Pull requests are welcome! To make changes:

## Credits
- Original source code adapted from QB-Rental for use with bikes.

## Dependencies
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-target](https://github.com/BerkieBb/qb-target)
- [ox-target](https://github.com/overextended/ox_target)

## Support
I may idk....

## Screenshots
soon.tm
