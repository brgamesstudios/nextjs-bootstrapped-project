-- Server events handler
local eventQueue = {}
local eventHandlers = {}

-- Register event handler
function RegisterEventHandler(eventName, handler)
    eventHandlers[eventName] = handler
    RegisterNetEvent(eventName)
    AddEventHandler(eventName, handler)
end

-- Event queue system
function QueueEvent(eventName, data, delay)
    delay = delay or 0
    
    table.insert(eventQueue, {
        name = eventName,
        data = data,
        executeAt = os.time() + delay
    })
end

-- Process event queue
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Check every second
        
        local currentTime = os.time()
        local eventsToProcess = {}
        
        -- Find events ready to process
        for i, event in ipairs(eventQueue) do
            if currentTime >= event.executeAt then
                table.insert(eventsToProcess, {index = i, event = event})
            end
        end
        
        -- Process events (in reverse order to avoid index issues)
        for i = #eventsToProcess, 1, -1 do
            local eventInfo = eventsToProcess[i]
            local event = eventInfo.event
            
            -- Process the event
            if eventHandlers[event.name] then
                eventHandlers[event.name](event.data)
            end
            
            -- Remove from queue
            table.remove(eventQueue, eventInfo.index)
        end
    end
end)

-- Database operations (example with MySQL)
local function InitializeDatabase()
    -- This is an example - you'll need to implement your own database connection
    Utils.Debug('Initializing database connection...')
    
    -- Example MySQL connection (requires mysql-async or oxmysql)
    --[[
    MySQL.ready(function()
        Utils.Debug('Database connection established')
        
        -- Create tables if they don't exist
        MySQL.Async.execute([[
            CREATE TABLE IF NOT EXISTS players (
                identifier VARCHAR(50) PRIMARY KEY,
                name VARCHAR(50) NOT NULL,
                money INT DEFAULT 0,
                bank INT DEFAULT 0,
                last_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ]], {})
    end)
    --]]
end

-- Player data operations
function SavePlayerToDatabase(playerData)
    -- Example database save operation
    --[[
    MySQL.Async.execute([[
        INSERT INTO players (identifier, name, money, bank, last_login)
        VALUES (@identifier, @name, @money, @bank, NOW())
        ON DUPLICATE KEY UPDATE
        name = @name,
        money = @money,
        bank = @bank,
        last_login = NOW()
    ]], {
        ['@identifier'] = playerData.identifier,
        ['@name'] = playerData.name,
        ['@money'] = playerData.money,
        ['@bank'] = playerData.bank
    })
    --]]
    
    Utils.Debug('Player data saved to database: ' .. playerData.name)
end

function LoadPlayerFromDatabase(identifier)
    -- Example database load operation
    --[[
    MySQL.Async.fetchAll([[
        SELECT * FROM players WHERE identifier = @identifier
    ]], {
        ['@identifier'] = identifier
    }, function(result)
        if result[1] then
            return result[1]
        else
            return nil
        end
    end)
    --]]
    
    -- For now, return default data
    return {
        money = Config.StartingMoney,
        bank = Config.StartingBank
    }
end

-- Advanced event handlers
RegisterEventHandler('base:server:savePlayer', function(playerId)
    local player = GetPlayer(playerId)
    if player then
        SavePlayerToDatabase(player)
    end
end)

RegisterEventHandler('base:server:loadPlayer', function(playerId)
    local player = GetPlayer(playerId)
    if player then
        local dbData = LoadPlayerFromDatabase(player.identifier)
        if dbData then
            player.money = dbData.money
            player.bank = dbData.bank
            TriggerClientEvent('base:client:updateMoney', playerId, player.money, player.bank)
        end
    end
end)

-- Scheduled events
function ScheduleEvent(eventName, data, delay)
    QueueEvent(eventName, data, delay)
end

-- Example scheduled events
Citizen.CreateThread(function()
    Citizen.Wait(5000) -- Wait 5 seconds after resource start
    
    -- Schedule a periodic event
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(300000) -- Every 5 minutes
            
            -- Auto-save all players
            for playerId, playerData in pairs(GetAllPlayers()) do
                QueueEvent('base:server:savePlayer', playerId, 0)
            end
            
            Utils.Debug('Auto-save completed for all players')
        end
    end)
end)

-- Broadcast system
function BroadcastToPlayers(message, excludePlayer)
    for playerId, playerData in pairs(GetAllPlayers()) do
        if playerId ~= excludePlayer then
            TriggerClientEvent('base:client:showNotification', playerId, message, 'info')
        end
    end
end

function BroadcastToAdmins(message)
    -- Example admin broadcast (you'll need to implement admin detection)
    for playerId, playerData in pairs(GetAllPlayers()) do
        -- Check if player is admin (implement your admin system)
        if IsPlayerAdmin(playerId) then
            TriggerClientEvent('base:client:showNotification', playerId, '[ADMIN] ' .. message, 'error')
        end
    end
end

-- Admin system (example)
function IsPlayerAdmin(playerId)
    -- Implement your admin detection logic here
    -- This could check against a database, ACE permissions, etc.
    return false -- Default to false
end

-- Logging system
function LogEvent(eventType, playerId, data)
    local timestamp = Utils.FormatTime(os.time())
    local playerName = playerId and GetPlayer(playerId) and GetPlayer(playerId).name or 'Unknown'
    
    local logEntry = string.format('[%s] %s - Player: %s - Data: %s', 
        timestamp, eventType, playerName, json.encode(data or {}))
    
    Utils.Debug(logEntry)
    
    -- You could also write to a log file here
    --[[
    local logFile = io.open('logs/events.log', 'a')
    if logFile then
        logFile:write(logEntry .. '\n')
        logFile:close()
    end
    --]]
end

-- Register logging for important events
RegisterEventHandler('base:server:playerJoined', function(playerData)
    LogEvent('PLAYER_JOINED', source, playerData)
end)

RegisterEventHandler('base:server:test', function(message)
    LogEvent('TEST_COMMAND', source, {message = message})
end)

-- Export functions
exports('QueueEvent', QueueEvent)
exports('ScheduleEvent', ScheduleEvent)
exports('BroadcastToPlayers', BroadcastToPlayers)
exports('BroadcastToAdmins', BroadcastToAdmins)
exports('LogEvent', LogEvent)
exports('RegisterEventHandler', RegisterEventHandler)