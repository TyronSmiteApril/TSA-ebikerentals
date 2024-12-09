# E-Bike Rental Script for FiveM

An advanced E-Bike rental system for FiveM, enabling players to rent, lock/unlock, and return bikes with SQL tracking and immersive mechanics.

## Features

- 🚲 **Multiple Rental Locations**: Add customizable bike racks as rental points.
- 💰 **Time-Based Billing**: Dynamically calculates rental costs based on usage.
- 🔐 **Lock/Unlock Functionality**: Players can secure their bikes to prevent theft.
- 📊 **SQL Integration**: Tracks rentals in a MySQL database for persistence.
- 🛠️ **Emote Interaction**: Locking/unlocking bikes includes an immersive emote (`/e mechanic3`).
- 🗺️ **Automatic Cleanup**: Removes abandoned bikes after inactivity (returns to their original rack).
- 🔄 **Targeting System Support**: Works with both `qb-target` and `ox-target`.
- 📢 **Custom Notifications**: Uses `QBCore:Notify` for feedback or your preferred notification system.

---

## 🛠️ Requirements

- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-target](https://github.com/BerkieBb/qb-target) or [ox-target](https://github.com/overextended/ox_target) (optional)
- [qb-banking](https://github.com/qbcore-framework/qb-banking)
- MySQL Database (MariaDB compatible)

---

## 📦 Installation

### 1. **SQL Setup**
Import the following SQL schema into your MySQL database:

```sql
CREATE TABLE `rented_bikes` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) NOT NULL,
    `bike_model` varchar(50) NOT NULL,
    PRIMARY KEY (`id`)
);
```

### 2. Configuration
Rental Points and Rates

Edit the `config.lua` file to define rental locations and billing settings:

```lua
Config = {}

Config.BikeRentalPoints = {
    {model = 'prop_bikerack_1a', coords = vector4(104.04, -777.23, 30.48, 0.0)},
    {model = 'prop_bikerack_2', coords = vector4(102.25, -776.27, 31.49, 0.0)},
    {model = 'prop_bikerack_2', coords = vector4(96.88, -774.28, 31.49, 0.0)},
    {model = 'prop_bikerack_1a', coords = vector4(95.0, -773.6, 31.51, 0.0)},
}

Config.RentalRate = 100 -- Cost per 5 minutes
Config.BillingInterval = 300000 -- Billing interval in milliseconds (5 minutes)
Config.UseOxTarget = false -- Set to true if using ox-target
Config.NotificationSystem = 'qbcore' -- Default QBCore notifications
```

### 3. Add to `server.cfg`

Add the resource to your FiveM server by including it in your server.cfg:
```lua
ensure TSA-ebikerentals
```

### 4. Changing the Bike Model

You can use a custom bike model by editing `main.lua`. Locate this line:
```lua
local bikeModelHash = GetHashKey('inductor')
```

Replace `inductor` with your desired bike model (e.g., `custom_bike`).

## 🎮 Usage

Players can rent a bike by interacting with designated rental points.
Lock and unlock bikes using the targeting system (with emotes for immersive interaction).
Return bikes at any bike rack or let them automatically return to their original spawn point after inactivity.
Costs are automatically deducted from the player's bank account.

## 🔧 Customization
Notification System

If you'd like to use a custom notification system instead of QBCore's, set `Config.NotificationSystem` to `'custom'` in `config.lua`, and replace notification calls in the code with your own events.

## 🤝 Dependencies
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-target](https://github.com/BerkieBb/qb-target)
- [ox-target](https://github.com/overextended/ox_target) (optional, if using `Config.UseOxTarget = true`)
- [qb-banking](https://github.com/qbcore-framework/qb-banking)

## 🧹 Cleanup

Bikes left unattended for more than 5 minutes will automatically despawn and return to their original rack.
SQL records for rentals are cleared when bikes are returned.

## ✨ Credits

Inspired by QB-Rental systems.
Custom enhancements for bike locking, immersive interactions, and SQL tracking.

## 🛠️ Contributing

I welcome contributions! Fork the repository and submit a pull request to propose changes or enhancements.

## 📧 Support
no... figure it out!

## Screenshots
![bike5](https://github.com/user-attachments/assets/9e265775-ba7a-4ee1-a721-3593b6667433)
![bike7](https://github.com/user-attachments/assets/973156ad-a240-4431-98e4-d1ee86f48622)
![bike](https://github.com/user-attachments/assets/dc94a27a-3d42-4b92-8fe0-1f381b90e82c)
![bike2](https://github.com/user-attachments/assets/ff53603b-32c1-4fb0-8cd9-cdceb451ed0a)
![bike3](https://github.com/user-attachments/assets/bf98bb87-cd7d-41dd-86ae-78014c15163b)
![bike4](https://github.com/user-attachments/assets/15f1e049-59c0-4475-ab0a-0e706ae584c0)
![bike6](https://github.com/user-attachments/assets/8641c635-c143-4abd-9c76-005c69419384)



