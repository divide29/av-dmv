local Framework = exports[Config.frameworkExport]:GetCoreObject()
local PlayerData = {}
local accessZones = {}
local drivingSchools = {}
local accessListener = false
local isInPractice = false
local maxErrorPoints = 3
local errorPoints = 0
local lastPointReached = false
local blips = {}

local function debugPrint(...)
    if Config.activateDebug then
        print(...)
    end
end
local function createBlip(blipName, coords, sprite, scale, color, text, shortRange)
    blipName = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blipName, sprite)
    SetBlipScale(blipName, scale)
    SetBlipColour(blipName, color)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blipName)

    SetBlipAsShortRange(blipName, shortRange)
end

local function listener(object)
    accessListener = true
    CreateThread(function()
        while accessListener do
            if IsControlJustReleased(0, 38) then
                local playerCoords = GetEntityCoords(PlayerPedId())
                for _, v in pairs(drivingSchools) do
                    local dist = #(playerCoords - vector3(v.coords.x, v.coords.y, v.coords.z))
                    if dist < 5.0 then
                        debugPrint(v.name)
                        TriggerEvent("av-dmv:client:handleNui", 1, v.name)
                    end
                end
                break
            end
            Wait(0)
        end
    end)
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    Wait(100)
    PlayerData = Framework.Functions.GetPlayerData()

    for id, school in pairs(Config.Locations) do
        createBlip(school.blip["name"], school.blip["coords"], school.blip["sprite"], school.blip["scale"],
            school.blip["color"], school.blip["text"], school.blip["shortRange"])

        debugPrint("Added Blip ID " .. id .. " with the name: " .. school.blip["name"])

        accessZones[#accessZones + 1] = BoxZone:Create(school["coords"], school.BoxZone["length"],
            school.BoxZone["width"],
            {
                name = school.BoxZone["name"],
                offset = school.BoxZone["offset"],
                scale = school.BoxZone["scale"],
                debugPoly = school.BoxZone["debugPoly"],
                heading = school["coords"].w,
            })

        drivingSchools[#drivingSchools + 1] = {
            ["name"] = school.name,
            ["coords"] = school.coords,
        }
    end

    local accessComboZone = ComboZone:Create(accessZones, { name = "accessComboZone", debugPoly = false })
    accessComboZone:onPlayerInOut(function(isPointInside)
        if isPointInside then
            exports[Config.frameworkExport]:DrawText(Lang:t("other.draw_open"), 'left')
            listener("nui")
        else
            exports[Config.frameworkExport]:HideText()
            accessListener = false
        end
    end)

    print('avellon | [INFO] The resource was started successfully.')
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    print('avellon | [INFO] The resource was successfully stopped.')
end)

AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = Framework.Functions.GetPlayerData()
end)

function GetVehicleSpawnPointsByName(name)
    local vehicleSpawnPoints = {}

    for _, location in ipairs(Config.Locations) do
        if location.name == name then
            for license, spawnPoints in pairs(location.vehicleSpawnPoints) do
                vehicleSpawnPoints[license] = vehicleSpawnPoints[license] or {}
                for _, spawnPoint in ipairs(spawnPoints) do
                    table.insert(vehicleSpawnPoints[license], spawnPoint)
                end
            end
            break
        end
    end

    return vehicleSpawnPoints
end

RegisterNetEvent('av-dmv:client:handleNui', function(handle, name)
    if handle == 1 then
        if isInPractice then
            Framework.Functions.Notify(Lang:t('error.already_in_test'), 'error', 7500)
            return
        end

        local possibleLicenses = {}
        for _, location in ipairs(Config.Locations) do
            if location.name == name then
                for key, licenseClass in ipairs(location.possibleLicenses) do
                    local license = Config.Licenses[key]
                    if license and license.class == licenseClass then
                        table.insert(possibleLicenses, license)
                    end
                end
                break
            end
        end

        local vehicleSpawnPoints = GetVehicleSpawnPointsByName(name)
        PlayerData = Framework.Functions.GetPlayerData()

        local hasTheoryLicenses = {}
        local hasPracticeLicenses = {}
        for k, v in pairs(PlayerData.metadata["licences"]) do
            if string.match(k, "_theory") then
                if v == true then
                    hasTheoryLicenses[#hasTheoryLicenses + 1] = k
                end
            end
            if string.match(k, "_practice") then
                if v == true then
                    hasPracticeLicenses[#hasPracticeLicenses + 1] = k
                end
            end
        end

        SetNuiFocus(true, true)
        SendNUIMessage({
            display = true,
            activateDebug = Config.activateDebug,
            activateRightAnswersHint = Config.activateRightAnswersHint,
            activatePossibleErrorPointsHint = Config.activatePossibleErrorPointsHint,
            possibleLicenses = possibleLicenses,
            hasTheoryLicenses = hasTheoryLicenses,
            hasPracticeLicenses = hasPracticeLicenses,
            questions = Config.TheoryTest,
            possibleSpawnPoints = vehicleSpawnPoints,
            locales = Lang.phrases,
        })

        debugPrint("[avellon] DMV: handle is 1")
    elseif handle == 0 then
        SetNuiFocus(false, false)
        SendNUIMessage({
            display = false,
        })
        debugPrint("[avellon] DMV: handle is 0")
    else
        debugPrint("[avellon] DMV: handle is not 0 or 1")
    end
end)

RegisterNetEvent('av-dmv:client:startTheoryTest', function()
    debugPrint("[avellon] DMV: start theory test")
    SendNUIMessage({
        display = true,
        activateDebug = Config.activateDebug,
        theoryTest = Config.TheoryTest,
    })
end)

local function findLicenseData(license)
    for _, v in pairs(Config.Licenses) do
        if v.class == license then
            return v
        end
    end
    return nil
end

local function findVehicle(license)
    return Config.Vehicles[license]
end

local function findLicensePlate(license)
    for _, v in ipairs(Config.LicensePlates) do
        if table.contains(v.forLicenses, license) then
            return v.plate .. math.random(v.addedRandomMin, v.addedRandomMax)
        end
    end
    return nil
end

RegisterNetEvent('av-dmv:client:startPracticeTest', function(license, possibleSpawnPoints)
    local licenseData = findLicenseData(license)
    local fee = licenseData and licenseData.praticeFee or nil

    local vehicle = findVehicle(license)

    local licensePlate = findLicensePlate(license)
    debugPrint("selected license plate: " .. licensePlate)

    PlayerData = Framework.Functions.GetPlayerData()
    debugPrint("[avellon] DMV: start practice test with license: " .. license)

    local possibleSpawnPointsFinished = possibleSpawnPoints[license] or {}
    local spawnPoint = possibleSpawnPointsFinished[math.random(#possibleSpawnPointsFinished)]

    if not spawnPoint then
        debugPrint("[avellon] DMV: no valid spawn point found")
        Framework.Functions.Notify(Lang:t("error.spawnpoint_blocked"), "error")
        return
    end

    debugPrint("selected spawnpoint: " ..
        tostring(spawnPoint) .. " X: " .. spawnPoint.x .. " Y: " .. spawnPoint.y .. " Z: " .. spawnPoint.z)

    while IsAnyVehicleNearPoint(spawnPoint.x, spawnPoint.y, spawnPoint.z, 3.0) do
        spawnPoint = possibleSpawnPointsFinished[math.random(#possibleSpawnPointsFinished)]
        debugPrint("selected spawnpoint: " ..
            tostring(spawnPoint) .. " X: " .. spawnPoint.x .. " Y: " .. spawnPoint.y .. " Z: " .. spawnPoint.z)
    end

    if fee ~= nil then
        if PlayerData.money.cash >= fee then
            TriggerServerEvent("av-dmv:server:money", "remove", fee)
            local payMessage = Lang:t("success.pay",
                {
                    first = Config.Currency.beforeAmount and Config.Currency.symbol or fee,
                    second = Config.Currency.beforeAmount and fee or Config.Currency.symbol
                })
            Framework.Functions.Notify(payMessage, "success")
        else
            Framework.Functions.Notify(Lang:t("error.not_enough_money"), "error")
            return
        end
    end

    Framework.Functions.SpawnVehicle(vehicle, function(veh)
        SetVehicleNumberPlateText(veh, licensePlate)
        SetEntityHeading(veh, spawnPoint.w)
        exports['LegacyFuel']:SetFuel(veh, 100.0)
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        TriggerEvent("vehiclekeys:client:SetOwner", Framework.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true, false)
    end, spawnPoint, true)

    isInPractice = true
    TriggerEvent("av-dmv:client:createRoute", license)
end)

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

local function findRoute(license)
    for _, v in ipairs(Config.DrivingRoutes) do
        if table.contains(v.forLicenses, license) then
            return v.route
        end
    end
    return nil
end

local function removeAllBlips()
    for _, blip in ipairs(blips) do
        RemoveBlip(blip)
    end
    blips = {}
end

local function createRouteBlips(route)
    for _, point in ipairs(route) do
        local blip = AddBlipForCoord(point.coords.x, point.coords.y, point.coords.z)
        SetBlipSprite(blip, 1)
        SetBlipColour(blip, 5)
        SetBlipScale(blip, 0.8)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Lang:t("other.blipRouteName"))
        EndTextCommandSetBlipName(blip)
        table.insert(blips, blip)
        SetBlipDisplay(blip, 0) -- Hide blip initially
    end
    SetBlipDisplay(blips[1], 8) -- Show the first blip
    SetBlipRoute(blips[1], true)
end

local function has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function checkPracticeTestConditions(license)
    local routeIndex = 0
    for i, route in ipairs(Config.DrivingRoutes) do
        if has_value(route.forLicenses, license) then
            routeIndex = i
            break
        end
    end

    local k = 1
    local currentPoint = Config.DrivingRoutes[routeIndex].route[k]

    while isInPractice do
        Citizen.Wait(1)
        local playerPos = GetEntityCoords(PlayerPedId())

        DrawMarker(Config.Marker.type, currentPoint.coords.x, currentPoint.coords.y, currentPoint.coords.z, 0, 0, 0,
            0, 0, 0, Config.Marker.scale.x,
            Config.Marker.scale.y, Config.Marker.scale.z, Config.Marker.color.r, Config.Marker.color.g,
            Config.Marker.color.b, Config.Marker.color.a, false, true, 2, false, nil, nil, false)

        if GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, currentPoint.coords.x, currentPoint.coords.y, currentPoint.coords.z, true) < 5.0 then
            RemoveBlip(blips[1])
            table.remove(blips, 1)

            k = k + 1

            if k <= #Config.DrivingRoutes[routeIndex].route then
                currentPoint = Config.DrivingRoutes[routeIndex].route[k]
                removeAllBlips()
                local nextBlip = AddBlipForCoord(currentPoint.coords.x, currentPoint.coords.y, currentPoint.coords.z)
                SetBlipSprite(nextBlip, 1)
                SetBlipColour(nextBlip, 5)
                SetBlipScale(nextBlip, 0.8)
                SetBlipAsShortRange(nextBlip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(Lang:t("info.blipRouteName"))
                EndTextCommandSetBlipName(nextBlip)
                SetBlipRoute(nextBlip, true)
                SetBlipRouteColour(nextBlip, 5)
                table.insert(blips, nextBlip)
            else
                isInPractice = false
                TriggerEvent("av-dmv:client:finishPracticeTest", true, license)
                break
            end
        end

        local speed = GetEntitySpeed(GetVehiclePedIsIn(PlayerPedId(), false)) * 3.6
        local speedLimit = Config.SpeedLimits[currentPoint.speedLimit]
        if speed > speedLimit then
            errorPoints = errorPoints + 1
            Framework.Functions.Notify(Lang:t("error.get_error_pratice") .. errorPoints .. " / " .. maxErrorPoints,
                "error")
            Citizen.Wait(1000)
        end

        if errorPoints >= maxErrorPoints then
            lastPointReached = false
            local routeIndex = 0
            for i, route in ipairs(Config.DrivingRoutes) do
                if has_value(route.forLicenses, license) then
                    routeIndex = i
                    break
                end
            end
            local lastPoint = Config.DrivingRoutes[routeIndex].route[#Config.DrivingRoutes[routeIndex].route]
            removeAllBlips()
            local blip = AddBlipForCoord(lastPoint.coords.x, lastPoint.coords.y, lastPoint.coords.z)
            SetBlipSprite(blip, 1)
            SetBlipColour(blip, 1)
            SetBlipScale(blip, 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Lang:t("other.last_blip"))
            EndTextCommandSetBlipName(blip)
            SetBlipRoute(blip, true)
            SetBlipRouteColour(blip, 1)



            while not lastPointReached do
                Citizen.Wait(1)
                local playerPos = GetEntityCoords(PlayerPedId())
                DrawMarker(Config.Marker.type, lastPoint.coords.x, lastPoint.coords.y, lastPoint.coords.z, 0, 0, 0,
                    0, 0, 0, Config.Marker.scale.x,
                    Config.Marker.scale.y, Config.Marker.scale.z, Config.Marker.color.r, Config.Marker.color.g,
                    Config.Marker.color.b, Config.Marker.color.a, false, true, 2, false, nil, nil, false)
                if GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, lastPoint.coords.x, lastPoint.coords.y, lastPoint.coords.z, true) < 5.0 then
                    lastPointReached = true
                    RemoveBlip(blip)

                    TriggerEvent("av-dmv:client:finishPracticeTest", false, license)
                end
            end
        end
    end
end

RegisterNetEvent('av-dmv:client:createRoute', function(license)
    debugPrint("[avellon] DMV: create route for license " .. license)

    local route = findRoute(license)

    if not route then
        debugPrint("[avellon] DMV: no route found")
        Framework.Functions.Notify(Lang:t("no_route_found"), "error")
        return
    end

    debugPrint("[avellon] DMV: create route with license: " .. license)
    createRouteBlips(route)
    checkPracticeTestConditions(license)
end)

RegisterNetEvent('av-dmv:client:finishPracticeTest', function(succeeded, license)
    debugPrint("[avellon] DMV: finish practice test with license: " .. license)

    removeAllBlips()
    lastPointReached = false

    if succeeded then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle ~= nil then
            SetEntityAsMissionEntity(vehicle, true, true)
            DeleteVehicle(vehicle)
        end
        isInPractice = false
        license = license .. "_practice"
        PlayerData.metadata["licences"][license] = true
        TriggerServerEvent("av-dmv:server:addLicense", license)
        Framework.Functions.Notify(Lang:t("success.done"), "success")
    else
        -- delete vehicle ped is in
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle ~= nil then
            SetEntityAsMissionEntity(vehicle, true, true)
            DeleteVehicle(vehicle)
        end
        isInPractice = false
        Framework.Functions.Notify(Lang:t("error.failed"), "error")
    end
end)

RegisterNUICallback('handleNui', function(data)
    debugPrint("[avellon] DMV: close nui")
    TriggerEvent("av-dmv:client:handleNui", data.handle)
end)

RegisterNUICallback('startPracticeTest', function(data)
    debugPrint("[avellon] DMV: practice test started with license: " .. data.license)

    for k, _ in pairs(data.possibleSpawnPoints) do
        debugPrint(k)
    end

    local license = data.license:gsub("av_dmv_list_practice_", "")
    TriggerEvent("av-dmv:client:startPracticeTest", license, data.possibleSpawnPoints)
end)

RegisterNUICallback('finishTheoryTest', function(data)
    debugPrint("[avellon] DMV: finish theory test with license: " .. data.license)

    -- add _theory to data.license
    local license = data.license .. "_theory"
    PlayerData.metadata["licences"][license] = true
    TriggerServerEvent("av-dmv:server:addLicense", license)
end)

RegisterNUICallback('startTheoryTest', function(data, cb)
    if data.fee ~= nil and PlayerData.money.cash >= data.fee then
        TriggerServerEvent("av-dmv:server:money", "remove", data.fee)
        Framework.Functions.Notify(
            Lang:t("success.pay", {
                first = Config.Currency.beforeAmount and Config.Currency.symbol or data.fee,
                second = Config.Currency.beforeAmount and data.fee or Config.Currency.symbol
            }),
            "success"
        )
        cb(true)
    else
        if data.fee ~= nil then
            Framework.Functions.Notify(Lang:t("error.not_enough_money"), "error")
        end
        cb(false)
    end
end)
