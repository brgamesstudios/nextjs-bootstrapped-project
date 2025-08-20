-- Client events handler
local eventHandlers = {}

-- Register event handler
function RegisterEventHandler(eventName, handler)
    eventHandlers[eventName] = handler
    RegisterNetEvent(eventName)
    AddEventHandler(eventName, handler)
end

-- Key mapping
local keyMappings = {
    ['F1'] = 288,
    ['F2'] = 289,
    ['F3'] = 170,
    ['F4'] = 166,
    ['F5'] = 167,
    ['F6'] = 168,
    ['F7'] = 169,
    ['F8'] = 56,
    ['F9'] = 56,
    ['F10'] = 57
}

-- Key press handler
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        for keyName, keyCode in pairs(keyMappings) do
            if IsControlJustPressed(0, keyCode) then
                HandleKeyPress(keyName)
            end
        end
    end
end)

-- Handle key press
function HandleKeyPress(keyName)
    Utils.Debug('Key pressed: ' .. keyName)
    
    if keyName == 'F1' then
        -- Open help menu
        ShowNotification('Help menu opened', 'info')
    elseif keyName == 'F2' then
        -- Quick action
        TriggerServerEvent('base:server:quickAction')
    elseif keyName == 'F3' then
        -- Toggle something
        ToggleFeature()
    end
end

-- Toggle feature
local featureEnabled = false
function ToggleFeature()
    featureEnabled = not featureEnabled
    local status = featureEnabled and 'enabled' or 'disabled'
    ShowNotification('Feature ' .. status, 'info')
end

-- Area detection
local areas = {
    {
        name = 'Test Area 1',
        coords = vector3(0.0, 0.0, 0.0),
        radius = 10.0,
        entered = false
    }
}

-- Area detection thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        for _, area in pairs(areas) do
            local distance = #(playerCoords - area.coords)
            
            if distance <= area.radius then
                if not area.entered then
                    area.entered = true
                    OnAreaEnter(area)
                end
            else
                if area.entered then
                    area.entered = false
                    OnAreaExit(area)
                end
            end
        end
    end
end)

-- Area enter callback
function OnAreaEnter(area)
    Utils.Debug('Entered area: ' .. area.name)
    ShowNotification('Entered: ' .. area.name, 'info')
    TriggerServerEvent('base:server:areaEntered', area.name)
end

-- Area exit callback
function OnAreaExit(area)
    Utils.Debug('Exited area: ' .. area.name)
    ShowNotification('Exited: ' .. area.name, 'info')
    TriggerServerEvent('base:server:areaExited', area.name)
end

-- Interaction system
local interactions = {}

-- Add interaction point
function AddInteractionPoint(name, coords, radius, callback)
    interactions[name] = {
        coords = coords,
        radius = radius,
        callback = callback,
        active = false
    }
end

-- Remove interaction point
function RemoveInteractionPoint(name)
    interactions[name] = nil
end

-- Interaction thread
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        for name, interaction in pairs(interactions) do
            local distance = #(playerCoords - interaction.coords)
            
            if distance <= interaction.radius then
                if not interaction.active then
                    interaction.active = true
                    ShowInteractionPrompt(name)
                end
                
                -- Check for interaction input
                if IsControlJustPressed(0, 38) then -- E key
                    if interaction.callback then
                        interaction.callback()
                    end
                end
            else
                if interaction.active then
                    interaction.active = false
                    HideInteractionPrompt()
                end
            end
        end
    end
end)

-- Show interaction prompt
function ShowInteractionPrompt(text)
    -- You can customize this based on your UI system
    SetTextComponentFormat('STRING')
    AddTextComponentString('Press ~INPUT_CONTEXT~ to ' .. text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

-- Hide interaction prompt
function HideInteractionPrompt()
    -- Hide interaction prompt
end

-- Example interaction points
Citizen.CreateThread(function()
    Citizen.Wait(2000) -- Wait for player to load
    
    -- Add example interaction points
    AddInteractionPoint('Test Interaction', vector3(0.0, 0.0, 0.0), 2.0, function()
        Utils.Debug('Test interaction triggered')
        ShowNotification('Interaction successful!', 'success')
        TriggerServerEvent('base:server:interaction', 'test')
    end)
end)

-- Export functions
exports('AddInteractionPoint', AddInteractionPoint)
exports('RemoveInteractionPoint', RemoveInteractionPoint)
exports('RegisterEventHandler', RegisterEventHandler)