local QBCore = exports['qb-core']:GetCoreObject()

local function getDefaultShop()
  local shop = Config.Shops[1]
  return shop
end

local function serializeShop(shop)
  if not shop then return nil end
  local items = {}
  for _, it in ipairs(shop.items or {}) do
    items[#items + 1] = { name = it.name, label = it.label, price = it.price }
  end
  return {
    id = shop.id,
    label = shop.label,
    currency = Config.Currency or '$',
    items = items
  }
end

RegisterServerEvent('market:getShop')
AddEventHandler('market:getShop', function()
  local src = source
  local shop = getDefaultShop()
  TriggerClientEvent('market:open', src, serializeShop(shop))
end)

local function notify(src, message, ntype)
  TriggerClientEvent('QBCore:Notify', src, message, ntype or 'primary')
end

RegisterServerEvent('market:buyItem')
AddEventHandler('market:buyItem', function(itemName, quantity)
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
      notify(src, ('%s x%d satin alindi (%s%d)'):format(itemData.label, quantity, Config.Currency or '$', totalPrice), 'success')
    else
      Player.Functions.AddMoney('cash', totalPrice, ('market_refund:%s x%d'):format(itemName, quantity))
      notify(src, 'Envanter dolu', 'error')
    end
  else
    notify(src, 'Yetersiz bakiye', 'error')
  end
end)