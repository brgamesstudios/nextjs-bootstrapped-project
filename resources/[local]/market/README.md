# Market UI (FiveM NUI)

Lightweight, framework-friendly market UI using NUI.

## Install
- Copy `resources/[local]/market` to your server `resources` folder
- Add `ensure market` to your `server.cfg`
- Ensure you have a framework (optional): ESX supported for money/inventory by default

## Usage
- In-game, run `/market` to open the default shop
- Click Buy to purchase items; ESC or the X button closes the UI

## Config
Edit `shared/config.lua` to tweak items and shops. Only `id`, `label`, and `items` are sent to NUI.

## Notes
- Uses `lua54` and a minimal client/server setup
- If you do not use ESX, purchases will log to server console and not affect inventory/money