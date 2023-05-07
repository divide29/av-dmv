Config = {} -- don't touch this

-- * general settings
Config.activateDebug = false                  -- true = debug mode, false = normal mode
Config.frameworkExport = 'qb-core'            -- default: qb-core
Config.UseKMH = true                          -- true = KMH, false = MPH
Config.LegacyFuel = false                     -- true = LegacyFuel, false = standard fivem
Config.OpenMenuKey = 38                       -- default: E, https://docs.fivem.net/docs/game-references/controls/
Config.MaxDrivingErrors = 3                   -- maximum of error points in the driving practical test
Config.BlockDetectionRadius = 3               -- the radius of checking the spawnpoint to detect blocking things
Config.Cooldown = 60                          -- time in seconds before starting the test again after failing it.
Config.activateRightAnswersHint = true        -- show the amount of right answers in the theory test
Config.activatePossibleErrorPointsHint = true -- show the amount of possible error points in the theory test
Config.Currency = {
    symbol = '€',                           -- symbol of the currency, e.g. $, €, £, etc.
    beforeAmount = false                      -- true = $ 100 | false = 100 $
}

Config.Marker = {
    type = 2,                                   -- marker type, more at https://docs.fivem.net/docs/game-references/markers/
    scale = { x = 1.0, y = 1.0, z = 1.0 },      -- marker scale
    color = { r = 0, g = 255, b = 0, a = 100 }, -- marker color
}

Config.Locations = {
    {
        name = "DMV",                                                                         -- must be unique
        coords = vector4(240.37, -1379.96, 33.74, 312.44),                                    -- coords of the BoxZone / DMV
        possibleLicenses = { 'bike_license', 'car_license', 'truck_license', 'bus_license' }, -- possible licenses to get at this location
        BoxZone = {
            length = 3.0,                                                                     -- box zone length https://github.com/mkafrin/PolyZone/wiki/BoxZone#options-for-a-boxzone
            width = 5.0,                                                                      -- box zone width
            name = "normal_drivingschool_box",                                                -- must be unique
            offset = { 0.0, 0.0, 0.0 },                                                       -- box zone offset
            scale = { 1.0, 1.0, 1.0 },                                                        -- box zone scale
            debugPoly = false,                                                                -- debug box zone
        },
        blip = {
            name = "normal_drivingschool",             -- must be unique
            coords = vector3(236.96, -1383.71, 32.91), -- cords of the blip
            sprite = 227,                              -- blip sprite, more at https://docs.fivem.net/docs/game-references/blips/
            scale = 1.0,                               -- blip size
            color = 0,                                 -- blip color https://docs.fivem.net/docs/game-references/blips/#blip-colors
            text = "DMV Los Santos",                   -- blip display name
            shortRange = false,                        -- blip should be displayed only when player is close
        },
        vehicleSpawnPoints = {
            ['bike_license'] = { -- here are all spawn points which are used for specific licenses
                [1] = vector4(219.14, -1384.42, 30.57, 266.88),
                [2] = vector4(219.04, -1384.61, 30.57, 265.47),
                [3] = vector4(222.11, -1387.85, 30.55, 269.92),
                [4] = vector4(237.4, -1412.18, 30.58, 320.66),
                [5] = vector4(239.67, -1414.7, 30.58, 326.59),
                [6] = vector4(243.52, -1415.9, 30.59, 319.2),
            },
            ['car_license'] = {
                [1] = vector4(219.14, -1384.42, 30.57, 266.88),
                [2] = vector4(219.04, -1384.61, 30.57, 265.47),
                [3] = vector4(222.11, -1387.85, 30.55, 269.92),
                [4] = vector4(237.4, -1412.18, 30.58, 320.66),
                [5] = vector4(239.67, -1414.7, 30.58, 326.59),
                [6] = vector4(243.52, -1415.9, 30.59, 319.2),
            },
            ['truck_license'] = {
                [1] = vector4(279.26, -1356.59, 31.94, 137.28),
                [2] = vector4(276.04, -1355.34, 31.94, 134.91),
            },
            ['bus_license'] = {
                [1] = vector4(279.26, -1356.59, 31.94, 137.28),
                [2] = vector4(276.04, -1355.34, 31.94, 134.91),
            }
        }
    }
}

Config.Licenses = {
    {
        class = "bike_license",  -- framework name
        name = "Class A (bike)", -- display name
        theoryFee = 500,         -- theory test fee
        praticeFee = 500,        -- practical test fee
    },
    {
        class = "car_license",
        name = "Class B (car)",
        theoryFee = 500,
        praticeFee = 250,
    },
    {
        class = "truck_license",
        name = "Class C (motorcycle)",
        theoryFee = 2000,
        praticeFee = 500,
    },
    {
        class = "bus_license",
        name = "Class D (bus/truck)",
        theoryFee = 3000,
        praticeFee = 200,
    }
}

Config.Vehicles = {
    bike_license = 'bati', -- model name
    car_license = '206',
    truck_license = 'pounder',
    bus_license = 'bus',
}

Config.SpeedLimits = {
    town = 70, -- speed limit in town
    freeway = 140
}

-- * practical test settings
Config.LicensePlates = {
    {
        plate = "AC FS",                   -- plate prefix
        addedRandomMin = 001,              -- random number min
        addedRandomMax = 499,              -- random number max
        forLicenses = {
            'bike_license', 'car_license', -- licenses which can use this plate
        }
    },
    {
        plate = "AC FS",
        addedRandomMin = 500,
        addedRandomMax = 999,
        forLicenses = {
            'truck_license', 'bus_license',
        }
    }
}
