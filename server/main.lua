-- variables
local Framework = exports[Config.frameworkExport]:GetCoreObject()

-- * events
RegisterServerEvent('av-dmv:server:money', function(state, money)
  local src = source
  local Player = Framework.Functions.GetPlayer(src)
  if state == 'add' then
    Player.Functions.AddMoney('cash', money)
  elseif state == 'remove' then
    Player.Functions.RemoveMoney('cash', money)
  end
end)

RegisterNetEvent('av-dmv:server:addLicense', function(license)
  local src = source
  local Player = Framework.Functions.GetPlayer(src)

  Player.PlayerData.metadata["licences"][license] = true
  Player.Functions.SetMetaData("licences", Player.PlayerData.metadata["licences"])
  if Config.activateDebug == true then print("avellon | [INFO] license added successfully: " .. license) end
end)