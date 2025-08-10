# Market UI (FiveM NUI)

Lightweight, QBCore-compatible market UI using NUI.

## Install
- Copy `resources/[local]/market` to your server `resources` folder
- Add `ensure market` to your `server.cfg`
- Ensure `qb-core` is started before this resource

## Usage
- In-game, run `/market` to open the default shop
- Click Buy to purchase items; ESC or the X button closes the UI

## Config
Edit `shared/config.lua` to tweak items and currency. Only `id`, `label`, `currency`, and `items` are sent to NUI.

## Notes
- Uses `lua54` and QBCore for money/inventory and notifications
- If you prefer another framework, adapt `server/server.lua` purchase logic accordingly