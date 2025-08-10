local isUiOpen = false

RegisterCommand('market', function()
  ToggleMarket(true)
end)

RegisterNUICallback('close', function(_, cb)
  ToggleMarket(false)
  cb(1)
end)

RegisterNUICallback('buyItem', function(data, cb)
  TriggerServerEvent('market:buyItem', data.name, data.quantity or 1)
  cb(1)
end)

RegisterNetEvent('market:open')
AddEventHandler('market:open', function(shop)
  SendNUIMessage({ action = 'open', shop = shop })
  SetNuiFocus(true, true)
  isUiOpen = true
end)

RegisterNetEvent('market:update')
AddEventHandler('market:update', function(shop)
  SendNUIMessage({ action = 'update', shop = shop })
end)

function ToggleMarket(shouldOpen)
  if shouldOpen then
    TriggerServerEvent('market:getShop')
  else
    SendNUIMessage({ action = 'close' })
    SetNuiFocus(false, false)
    isUiOpen = false
  end
end

-- Ensure UI is closed when the resource starts
AddEventHandler('onClientResourceStart', function(resName)
  if resName ~= GetCurrentResourceName() then return end
  SendNUIMessage({ action = 'close' })
  SetNuiFocus(false, false)
  isUiOpen = false
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    if isUiOpen then
      DisableControlAction(0, 1, true)
      DisableControlAction(0, 2, true)
      DisableControlAction(0, 142, true)
      DisableControlAction(0, 18, true)
      DisableControlAction(0, 322, true)
      if IsDisabledControlJustReleased(0, 322) then
        ToggleMarket(false)
      end
    end
  end
end)