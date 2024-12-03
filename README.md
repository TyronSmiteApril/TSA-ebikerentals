# E-Bike Rental Script for FiveM

![E-Bike Rental](https://example.com/rental-image.png)

This repository contains an E-Bike rental script for FiveM. The script allows players to rent an E-Bike from designated rental spots, track rental duration, and return the bikes. Follow the instructions below to add the script to your FiveM server.

## Features
- Multiple rental locations using `prop_bikerack_2` and 'prop_bikerack_1a
- Time-based rental cost calculation ($1 per 5 minutes)
- Easy-to-use `/returnbike` command for returning the rental

## Requirements
This script requires the following dependencies:
- [qb-core](https://github.com/qbcore-framework/qb-core)
- [qb-target](https://github.com/BerkieBb/qb-target)

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
   
### 3. Configure Rental Points and Rates
Edit the `config.lua` file to set up rental points and rental rates:

- Use `vector3` format to specify the coordinates for rental points using `prop_bikerack_2` and 'prop_bikerack_1a' models.
- **Rental Rate**: Set the rental rate per time period.

### 4. Starting the Script
Add the following line to your `server.cfg` to start the script:
```cfg
ensure TSA-ebikerentals
```

## Usage
- Players can rent an E-Bike by interacting with a rental point (`prop_bikerack_2` and 'prop_bikerack_1a').
- The rental cost is calculated based on time used.
- Players can return their bike using the `/returnbike` command.

## Development
Feel free to contribute to the script. Pull requests are welcome! To make changes:

## Credits
- Original source code adapted from QB-Rental for use with bikes.
- Dependencies: [qb-core](https://github.com/qbcore-framework/qb-core), [qb-target](https://github.com/BerkieBb/qb-target)

## Support
I may idk....

## Screenshots
soon.tm

