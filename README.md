# E-Bike Rental Script for FiveM

## [TSA E-Bike Rental]

This repository contains an E-Bike rental script for FiveM. The script allows players to rent an E-Bike from designated rental spots, track rental duration, and return the bikes. Follow the instructions below to add the script to your FiveM server.

## Features
- Multiple rental locations using `prop_bikerack_2` and `prop_bikerack_1a`
- Time-based rental cost calculation ($1 per 5 minutes)
- - Supports both **qb-target** and **ox-target** for interactions
- Dynamic billing from player bank accounts using **qb-banking**

## Requirements
This script requires the following dependencies:
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-target](https://github.com/BerkieBb/qb-target) or [ox-target](https://github.com/overextended/ox_target)
- [qb-banking](https://github.com/qbcore-framework/qb-banking)

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
   
- **Rental Rate and Billing Interval**: In `config.lua`, you can adjust the rental rate by modifying `Config.RentalRate`. You can also change the time interval for billing by setting `Config.BillingInterval`. For example:

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

### 5. Starting the Script
Add the following line to your `server.cfg` to start the script:
```cfg
ensure TSA-ebikerentals
```

## Usage
- Players can rent an E-Bike by interacting with a rental point (`prop_bikerack_2` and `prop_bikerack_1a`).
- The rental cost is calculated based on time used and deducted from the player's **bank** account when the bike is returned.
- Players can return their bike by interacting with any bike rack in the city (the `/returnbike` command has been removed).

## Configurations for Notification and Banking System
- You can configure the notification system to use either the default `QBCore:Notify` or your own custom notification event.
- In the `server/main.lua`, locate the notification code and modify it as follows to use your own notification system:

```lua
if Config.NotificationSystem == 'custom' then
    TriggerClientEvent('yourCustomNotify', src, 'You have returned the bike. You were charged $' .. totalCharge)
else
    TriggerClientEvent('QBCore:Notify', src, 'You have returned the bike. You were charged $' .. totalCharge, 'success')
end
```

- You can also change the banking system to suit your preference if you do not want to use `qb-banking`. To use a different system, locate the code in `server/main.lua` where money is removed, and modify it accordingly. Example:

```lua
if Config.BankingSystem == 'custom' then
    -- Replace with your custom banking function
    exports['your-banking-system']:RemoveMoney(accountName, totalCharge, 'E-Bike Rental Fee')
else
    Player.Functions.RemoveMoney(accountName, totalCharge, 'E-Bike Rental Fee')
end
```


### Development
Feel free to contribute to the script. Pull requests are welcome! To make changes:
- Modify the script as needed and create a pull request to contribute.

### Credits
- Original source code adapted from QB-Rental for use with bikes.

### Dependencies
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-target](https://github.com/BerkieBb/qb-target)
- [ox-target](https://github.com/overextended/ox_target)
- [qb-banking](https://github.com/qbcore-framework/qb-banking)

### Support
I may idk....

### Screenshots
soon.tm
