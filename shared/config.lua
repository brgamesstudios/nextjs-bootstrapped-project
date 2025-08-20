Config = {}

-- General settings
Config.Debug = true
Config.ResourceName = 'base_script'

-- Player settings
Config.StartingMoney = 1000
Config.StartingBank = 5000

-- Commands
Config.Commands = {
    ['test'] = {
        description = 'Test command',
        usage = '/test [message]'
    },
    ['money'] = {
        description = 'Check money',
        usage = '/money'
    }
}

-- Events
Config.Events = {
    Client = {
        'base:client:test',
        'base:client:showNotification'
    },
    Server = {
        'base:server:test',
        'base:server:updateMoney'
    }
}

-- Notifications
Config.Notifications = {
    Success = {
        color = '#00ff00',
        icon = 'fas fa-check'
    },
    Error = {
        color = '#ff0000',
        icon = 'fas fa-times'
    },
    Info = {
        color = '#0099ff',
        icon = 'fas fa-info'
    }
}