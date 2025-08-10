local QBCore = exports['qb-core']:GetCoreObject()

local function getDefaultShop()
  local shop
  if type(Config) == 'table' and type(Config.Shops) == 'table' and Config.Shops[1] then
    shop = Config.Shops[1]
  end
  if not shop then
    shop = { id = 'default', label = 'Market', items = {} }
  end
  if type(shop.items) ~= 'table' or #shop.items == 0 then
    shop.items = {
      { name = 'water', label = 'Water', price = 5 },
      { name = 'sandwich', label = 'Sandwich', price = 10 },
      { name = 'phone', label = 'Phone', price = 250 }
    }
  end
  return shop
end

local function serializeShop(shop)
  if not shop then return nil end
  local items = {}
  for _, it in ipairs(shop.items or {}) do
    items[#items + 1] = { name = it.name, label = it.label, price = it.price }
  end
  local payload = {
    id = shop.id,
    label = shop.label,
    currency = (Config and Config.Currency) or '$',
    items = items
  }
  print(('[market_ui] serializeShop -> id=%s label=%s items=%d'):format(payload.id or 'nil', payload.label or 'nil', #payload.items))
  return payload
end

RegisterServerEvent('market_ui:getShop')
AddEventHandler('market_ui:getShop', function()
  local src = source
  local shop = getDefaultShop()
  local payload = serializeShop(shop)
  if not payload or #payload.items == 0 then
    print('[market_ui] Warning: shop has no items. Check shared/config.lua -> Config.Shops[1].items')
  end
  TriggerClientEvent('market_ui:open', src, payload)
end)

local function notify(src, message, ntype)
  TriggerClientEvent('QBCore:Notify', src, message, ntype or 'primary')
end

RegisterServerEvent('market_ui:buyItem')
AddEventHandler('market_ui:buyItem', function(itemName, quantity)
  local src = source
  local Player = QBCore.Functions.GetPlayer(src)
  quantity = tonumber(quantity) or 1

  local shop = getDefaultShop()
  local itemData = nil
  for _, item in ipairs(shop.items) do
    if item.name == itemName then
      itemData = item
      break
    end
  end
  if not itemData then return end
  if not Player then
    print(('Player %d attempted purchase but QBCore player not found'):format(src))
    return
  end

  local totalPrice = itemData.price * quantity
  local cash = Player.Functions.GetMoney('cash')

  if cash >= totalPrice then
    Player.Functions.RemoveMoney('cash', totalPrice, ('market_purchase:%s x%d'):format(itemName, quantity))
    local added = Player.Functions.AddItem(itemName, quantity)
    if added then
      notify(src, ('%s x%d satin alindi (%s%d)'):format(itemData.label, quantity, (Config and Config.Currency) or '$', totalPrice), 'success')
    else
      Player.Functions.AddMoney('cash', totalPrice, ('market_refund:%s x%d'):format(itemName, quantity))
      notify(src, 'Envanter dolu', 'error')
    end
  else
    notify(src, 'Yetersiz bakiye', 'error')
  end
end)