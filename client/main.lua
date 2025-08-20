-- Client-side main script
local PlayerData = {}
local isLoggedIn = false

-- Initialize the script
Citizen.CreateThread(function()
    Utils.Debug('Client script started')
    
    -- Wait for player to load
    while not NetworkIsPlayerActive(PlayerId()) do
        Citizen.Wait(100)
    end
    
    -- Initialize player data
    InitializePlayer()
end)

-- Initialize player data
function InitializePlayer()
    local playerId = PlayerId()
    local playerPed = PlayerPedId()
    
    PlayerData = {
        id = playerId,
        ped = playerPed,
        coords = GetEntityCoords(playerPed),
        heading = GetEntityHeading(playerPed),
        health = GetEntityHealth(playerPed),
        armor = GetPedArmour(playerPed)
    }
    
    Utils.Debug('Player initialized: ' .. GetPlayerName(playerId))
    isLoggedIn = true
    
    -- Trigger server event to notify player joined
    TriggerServerEvent('base:server:playerJoined', PlayerData)
end

-- Main thread for continuous updates
Citizen.CreateThread(function()
    while true do
        if isLoggedIn then
            UpdatePlayerData()
        end
        Citizen.Wait(1000) -- Update every second
    end
end)

-- Update player data
function UpdatePlayerData()
    local playerPed = PlayerPedId()
    
    PlayerData.ped = playerPed
    PlayerData.coords = GetEntityCoords(playerPed)
    PlayerData.heading = GetEntityHeading(playerPed)
    PlayerData.health = GetEntityHealth(playerPed)
    PlayerData.armor = GetPedArmour(playerPed)
end

-- Register commands
RegisterCommand('test', function(source, args, rawCommand)
    local message = table.concat(args, ' ') or 'Hello from client!'
    Utils.Debug('Test command executed: ' .. message)
    
    -- Trigger server event
    TriggerServerEvent('base:server:test', message)
    
    -- Show notification
    ShowNotification('Test command executed!', 'success')
end, false)

RegisterCommand('money', function(source, args, rawCommand)
    TriggerServerEvent('base:server:getMoney')
end, false)

RegisterCommand('coords', function(source, args, rawCommand)
    local coords = GetEntityCoords(PlayerPedId())
    local message = string.format('Coords: %.2f, %.2f, %.2f', coords.x, coords.y, coords.z)
    Utils.Debug(message)
    ShowNotification(message, 'info')
end, false)

-- Event handlers
RegisterNetEvent('base:client:test')
AddEventHandler('base:client:test', function(data)
    Utils.Debug('Received test event from server: ' .. tostring(data))
    ShowNotification('Server test event received!', 'success')
end)

RegisterNetEvent('base:client:showNotification')
AddEventHandler('base:client:showNotification', function(message, type)
    ShowNotification(message, type or 'info')
end)

RegisterNetEvent('base:client:updateMoney')
AddEventHandler('base:client:updateMoney', function(money, bank)
    PlayerData.money = money
    PlayerData.bank = bank
    ShowNotification(string.format('Money: $%d | Bank: $%d', money, bank), 'info')
end)

-- Notification function
function ShowNotification(message, type)
    local notification = Config.Notifications[type] or Config.Notifications.Info
    
    -- You can customize this based on your notification system
    -- For now, we'll use a simple print
    Utils.Debug('Notification (' .. type .. '): ' .. message)
    
    -- Example with SetNotificationTextEntry (if using native notifications)
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, false)
end

-- Export functions for other resources
exports('GetPlayerData', function()
    return PlayerData
end)

exports('ShowNotification', ShowNotification)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Utils.Debug('Client script stopping')
        -- Cleanup code here
    end
end)