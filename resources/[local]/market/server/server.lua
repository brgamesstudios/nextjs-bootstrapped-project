local ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

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
  local xPlayer = ESX and ESX.GetPlayerFromId(src) or nil
  local shop = getDefaultShop()

  TriggerClientEvent('market:open', src, serializeShop(shop))
end)

RegisterServerEvent('market:buyItem')
AddEventHandler('market:buyItem', function(itemName, quantity)
  local src = source
  local xPlayer = ESX and ESX.GetPlayerFromId(src) or nil
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

  local totalPrice = itemData.price * quantity

  if xPlayer then
    if xPlayer.getMoney() >= totalPrice then
      xPlayer.removeMoney(totalPrice)
      xPlayer.addInventoryItem(itemName, quantity)
      TriggerClientEvent('esx:showNotification', src, ('Purchased %s x%d for %s%d'):format(itemData.label, quantity, Config.Currency, totalPrice))
    else
      TriggerClientEvent('esx:showNotification', src, 'Not enough money')
    end
  else
    print(('Player %d bought %s x%d for %d (no framework bound)'):format(src, itemName, quantity, totalPrice))
  end
end)