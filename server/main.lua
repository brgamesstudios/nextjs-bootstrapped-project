-- Server-side main script
local Players = {}
local ServerData = {
    startTime = os.time(),
    totalPlayers = 0,
    maxPlayers = 32
}

-- Initialize the server
Citizen.CreateThread(function()
    Utils.Debug('Server script started')
    
    -- Initialize server data
    InitializeServer()
    
    -- Start server threads
    StartServerThreads()
end)

-- Initialize server
function InitializeServer()
    Utils.Debug('Initializing server...')
    
    -- Set server info
    SetGameType(Config.ResourceName)
    SetMapName('Los Santos')
    
    -- Initialize player storage
    Players = {}
    
    Utils.Debug('Server initialized successfully')
end

-- Start server threads
function StartServerThreads()
    -- Player count update thread
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(30000) -- Update every 30 seconds
            UpdatePlayerCount()
        end
    end)
    
    -- Server maintenance thread
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(60000) -- Run every minute
            ServerMaintenance()
        end
    end)
end

-- Update player count
function UpdatePlayerCount()
    local currentPlayers = GetPlayers()
    ServerData.totalPlayers = #currentPlayers
    
    Utils.Debug('Current players: ' .. ServerData.totalPlayers .. '/' .. ServerData.maxPlayers)
end

-- Server maintenance
function ServerMaintenance()
    Utils.Debug('Running server maintenance...')
    
    -- Clean up disconnected players
    for playerId, playerData in pairs(Players) do
        if not GetPlayerName(playerId) then
            Utils.Debug('Removing disconnected player: ' .. playerId)
            Players[playerId] = nil
        end
    end
    
    -- Additional maintenance tasks can be added here
end

-- Player management
function AddPlayer(playerId, playerData)
    local identifier = Utils.GetPlayerIdentifier(playerId)
    local playerName = Utils.GetPlayerName(playerId)
    
    Players[playerId] = {
        id = playerId,
        identifier = identifier,
        name = playerName,
        joined = os.time(),
        money = Config.StartingMoney,
        bank = Config.StartingBank,
        data = playerData or {}
    }
    
    Utils.Debug('Player added: ' .. playerName .. ' (' .. playerId .. ')')
    
    -- Send welcome message
    TriggerClientEvent('base:client:showNotification', playerId, 'Welcome to the server!', 'success')
    
    return Players[playerId]
end

function RemovePlayer(playerId)
    local playerData = Players[playerId]
    if playerData then
        Utils.Debug('Player removed: ' .. playerData.name .. ' (' .. playerId .. ')')
        
        -- Save player data here if needed
        SavePlayerData(playerId, playerData)
        
        Players[playerId] = nil
    end
end

function GetPlayer(playerId)
    return Players[playerId]
end

function GetAllPlayers()
    return Players
end

-- Save player data
function SavePlayerData(playerId, playerData)
    -- Implement your save system here
    -- This could save to a database, file, etc.
    Utils.Debug('Saving data for player: ' .. playerData.name)
end

-- Register commands
RegisterCommand('players', function(source, args, rawCommand)
    local playerCount = Utils.TableLength(Players)
    local message = 'Online players: ' .. playerCount .. '/' .. ServerData.maxPlayers
    
    if source == 0 then
        -- Console command
        Utils.Debug(message)
    else
        -- Player command
        TriggerClientEvent('base:client:showNotification', source, message, 'info')
    end
end, true)

RegisterCommand('kick', function(source, args, rawCommand)
    if source == 0 then
        -- Console command
        local targetId = tonumber(args[1])
        local reason = table.concat(args, ' ', 2) or 'No reason specified'
        
        if targetId and Players[targetId] then
            DropPlayer(targetId, reason)
            Utils.Debug('Kicked player ' .. targetId .. ' for: ' .. reason)
        else
            Utils.Debug('Invalid player ID: ' .. tostring(args[1]))
        end
    else
        -- Player command - check permissions
        TriggerClientEvent('base:client:showNotification', source, 'You do not have permission to use this command', 'error')
    end
end, true)

RegisterCommand('restart', function(source, args, rawCommand)
    if source == 0 then
        -- Console command
        Utils.Debug('Restarting resource...')
        -- Add your restart logic here
    else
        TriggerClientEvent('base:client:showNotification', source, 'You do not have permission to use this command', 'error')
    end
end, true)

-- Event handlers
RegisterNetEvent('base:server:playerJoined')
AddEventHandler('base:server:playerJoined', function(playerData)
    local source = source
    local player = AddPlayer(source, playerData)
    
    Utils.Debug('Player joined event: ' .. player.name)
    
    -- Broadcast to other players
    TriggerClientEvent('base:client:showNotification', -1, player.name .. ' joined the server', 'info')
end)

RegisterNetEvent('base:server:test')
AddEventHandler('base:server:test', function(message)
    local source = source
    local player = GetPlayer(source)
    
    if player then
        Utils.Debug('Test event from ' .. player.name .. ': ' .. message)
        
        -- Echo back to client
        TriggerClientEvent('base:client:test', source, 'Server received: ' .. message)
        
        -- Broadcast to all players
        TriggerClientEvent('base:client:showNotification', -1, player.name .. ' sent: ' .. message, 'info')
    end
end)

RegisterNetEvent('base:server:getMoney')
AddEventHandler('base:server:getMoney', function()
    local source = source
    local player = GetPlayer(source)
    
    if player then
        TriggerClientEvent('base:client:updateMoney', source, player.money, player.bank)
    end
end)

RegisterNetEvent('base:server:quickAction')
AddEventHandler('base:server:quickAction', function()
    local source = source
    local player = GetPlayer(source)
    
    if player then
        Utils.Debug('Quick action from ' .. player.name)
        TriggerClientEvent('base:client:showNotification', source, 'Quick action executed!', 'success')
    end
end)

RegisterNetEvent('base:server:areaEntered')
AddEventHandler('base:server:areaEntered', function(areaName)
    local source = source
    local player = GetPlayer(source)
    
    if player then
        Utils.Debug(player.name .. ' entered area: ' .. areaName)
    end
end)

RegisterNetEvent('base:server:areaExited')
AddEventHandler('base:server:areaExited', function(areaName)
    local source = source
    local player = GetPlayer(source)
    
    if player then
        Utils.Debug(player.name .. ' exited area: ' .. areaName)
    end
end)

RegisterNetEvent('base:server:interaction')
AddEventHandler('base:server:interaction', function(interactionType)
    local source = source
    local player = GetPlayer(source)
    
    if player then
        Utils.Debug(player.name .. ' triggered interaction: ' .. interactionType)
        
        -- Handle different interaction types
        if interactionType == 'test' then
            -- Give player some money as example
            player.money = player.money + 100
            TriggerClientEvent('base:client:updateMoney', source, player.money, player.bank)
        end
    end
end)

-- Player disconnect handler
AddEventHandler('playerDropped', function(reason)
    local source = source
    RemovePlayer(source)
    
    Utils.Debug('Player disconnected: ' .. source .. ' - Reason: ' .. reason)
end)

-- Export functions for other resources
exports('GetPlayer', GetPlayer)
exports('GetAllPlayers', GetAllPlayers)
exports('AddPlayer', AddPlayer)
exports('RemovePlayer', RemovePlayer)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Utils.Debug('Server script stopping')
        
        -- Save all player data
        for playerId, playerData in pairs(Players) do
            SavePlayerData(playerId, playerData)
        end
    end
end)