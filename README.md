# FiveM Base Script

A comprehensive base script for FiveM servers with modern UI, player management, and extensible architecture.

## Features

- **Modern UI**: Beautiful, responsive web interface with dark theme
- **Player Management**: Complete player tracking and data management
- **Event System**: Robust client-server communication
- **Command System**: Built-in commands with easy customization
- **Area Detection**: Automatic area entry/exit detection
- **Interaction System**: Easy-to-use interaction points
- **Notification System**: Multiple notification types with animations
- **Database Ready**: Prepared for MySQL integration
- **Utility Functions**: Comprehensive utility library
- **Export System**: Functions available for other resources

## Installation

1. **Download** the resource files to your FiveM server's `resources` folder
2. **Rename** the folder to your desired resource name (e.g., `base_script`)
3. **Add** the resource to your `server.cfg`:
   ```
   ensure base_script
   ```
4. **Restart** your server

## File Structure

```
base_script/
├── fxmanifest.lua          # Resource manifest
├── shared/
│   ├── config.lua          # Configuration file
│   └── utils.lua           # Utility functions
├── client/
│   ├── main.lua            # Main client script
│   └── events.lua          # Client events
├── server/
│   ├── main.lua            # Main server script
│   └── events.lua          # Server events
├── html/
│   ├── index.html          # UI HTML
│   ├── style.css           # UI styles
│   └── script.js           # UI JavaScript
└── README.md               # This file
```

## Configuration

### Basic Configuration (`shared/config.lua`)

```lua
Config = {}

-- General settings
Config.Debug = true                    -- Enable debug messages
Config.ResourceName = 'base_script'    -- Resource name

-- Player settings
Config.StartingMoney = 1000            -- Starting money
Config.StartingBank = 5000             -- Starting bank balance

-- Commands
Config.Commands = {
    ['test'] = {
        description = 'Test command',
        usage = '/test [message]'
    }
}
```

### Customization

1. **Modify Commands**: Add new commands in `Config.Commands`
2. **Change Starting Values**: Adjust `Config.StartingMoney` and `Config.StartingBank`
3. **Enable/Disable Features**: Toggle `Config.Debug` and other settings
4. **Custom Events**: Add new events to `Config.Events`

## Usage

### Commands

- `/test [message]` - Test command with optional message
- `/money` - Check your money and bank balance
- `/coords` - Get your current coordinates
- `/players` - Show online player count (admin only)

### Key Bindings

- **F1** - Open help menu
- **F2** - Quick action
- **F3** - Toggle feature
- **ESC** - Close UI

### UI Controls

- Click action buttons to execute commands
- Use the close button or ESC to hide the UI
- Notifications appear automatically and auto-dismiss

## API Reference

### Client Exports

```lua
-- Get player data
local playerData = exports['base_script']:GetPlayerData()

-- Show notification
exports['base_script']:ShowNotification('Message', 'success')

-- Add interaction point
exports['base_script']:AddInteractionPoint('Name', coords, radius, callback)

-- Remove interaction point
exports['base_script']:RemoveInteractionPoint('Name')
```

### Server Exports

```lua
-- Get player data
local player = exports['base_script']:GetPlayer(playerId)

-- Get all players
local allPlayers = exports['base_script']:GetAllPlayers()

-- Add player
exports['base_script']:AddPlayer(playerId, playerData)

-- Remove player
exports['base_script']:RemovePlayer(playerId)
```

### Events

#### Client Events
- `base:client:test` - Test event
- `base:client:showNotification` - Show notification
- `base:client:updateMoney` - Update money display

#### Server Events
- `base:server:playerJoined` - Player joined
- `base:server:test` - Test event
- `base:server:getMoney` - Get player money
- `base:server:quickAction` - Quick action
- `base:server:areaEntered` - Area entered
- `base:server:areaExited` - Area exited
- `base:server:interaction` - Interaction triggered

## Database Integration

The script includes commented database code for MySQL integration. To enable:

1. **Install MySQL Resource**: Add `mysql-async` or `oxmysql` to your server
2. **Uncomment Database Code**: Remove comment blocks in `server/events.lua`
3. **Configure Database**: Set up your MySQL connection
4. **Create Tables**: The script will auto-create required tables

### Database Schema

```sql
CREATE TABLE players (
    identifier VARCHAR(50) PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    money INT DEFAULT 0,
    bank INT DEFAULT 0,
    last_login TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Customization Guide

### Adding New Commands

1. **Add to Config** (`shared/config.lua`):
```lua
Config.Commands['newcommand'] = {
    description = 'New command description',
    usage = '/newcommand [args]'
}
```

2. **Register Command** (`client/main.lua`):
```lua
RegisterCommand('newcommand', function(source, args, rawCommand)
    -- Command logic here
    TriggerServerEvent('base:server:newCommand', args)
end, false)
```

3. **Handle Server-Side** (`server/main.lua`):
```lua
RegisterNetEvent('base:server:newCommand')
AddEventHandler('base:server:newCommand', function(args)
    local source = source
    -- Server logic here
end)
```

### Adding New UI Elements

1. **Update HTML** (`html/index.html`):
```html
<div class="section">
    <h2><i class="fas fa-star"></i> New Section</h2>
    <div class="new-content">
        <!-- Your content here -->
    </div>
</div>
```

2. **Add Styles** (`html/style.css`):
```css
.new-content {
    /* Your styles here */
}
```

3. **Add JavaScript** (`html/script.js`):
```javascript
// Handle new functionality
```

### Adding New Events

1. **Client-Side** (`client/events.lua`):
```lua
RegisterNetEvent('base:client:newEvent')
AddEventHandler('base:client:newEvent', function(data)
    -- Handle event
end)
```

2. **Server-Side** (`server/events.lua`):
```lua
RegisterEventHandler('base:server:newEvent', function(data)
    -- Handle event
end)
```

## Troubleshooting

### Common Issues

1. **Resource Won't Start**
   - Check `fxmanifest.lua` syntax
   - Ensure all files are in correct locations
   - Check server console for errors

2. **UI Not Showing**
   - Verify `ui_page` in `fxmanifest.lua`
   - Check browser console for JavaScript errors
   - Ensure HTML files are properly formatted

3. **Commands Not Working**
   - Check command registration syntax
   - Verify event handlers are properly set up
   - Check server console for errors

4. **Database Issues**
   - Ensure MySQL resource is installed and running
   - Check database connection settings
   - Verify table creation

### Debug Mode

Enable debug mode in `shared/config.lua`:
```lua
Config.Debug = true
```

This will show detailed console messages for troubleshooting.

## Dependencies

- **Optional**: `es_extended` (ESX framework)
- **Optional**: `mysql-async` or `oxmysql` (for database features)

## License

This project is open source and available under the MIT License.

## Support

For support and questions:
1. Check the troubleshooting section
2. Review the code comments
3. Check FiveM documentation
4. Create an issue on the project repository

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Changelog

### Version 1.0.0
- Initial release
- Basic player management
- Modern UI system
- Event system
- Command system
- Area detection
- Interaction system
- Notification system
- Database integration ready
- Utility functions
- Export system