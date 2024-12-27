mainLastIndex = 1
vehicle = 0
mainMenuId = 'customs-main'
local QBCore
local inMenu = false
local dragcam = require('preview.dragcam')
local startDragCam = dragcam.startDragCam
local stopDragCam = dragcam.stopDragCam
oldcarinfo = {}
local shared = require 'shared.shared'
local qb = require 'client.qb'

if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
end

local menu = {
    id = mainMenuId,
    canClose = true,
    disableInput = false,
    title = 'Customs Preview',
    position = 'top-left',
    options = {},
}

local function main()
    -- if GetVehicleBodyHealth(vehicle) < 1000.0 then
    --     return {{
    --         label = 'Repair',
    --         description = ('%s%d'):format(Config.Currency, math.ceil(1000 - GetVehicleBodyHealth(vehicle))),
    --         close = true,
    --     }}
    -- end

    local options = {
        {
            label = 'Cosmetics - Parts',
            close = true,
            args = {
                menu = 'preview.menus.parts',
            }
        },
        {
            label = 'Cosmetics - Colors',
            close = true,
            args = {
                menu = 'preview.menus.colors',
            }
        },
    }

    if DoesExtraExist(vehicle, 1) then
        options[#options + 1] = {
            label = 'Extras',
            close = true,
            args = {
                menu = 'preview.menus.extras',
            }
        }
    end

    return options
end

local function disableControls()
    inMenu = true
    CreateThread(function()
        while inMenu do
            Wait(0)
            DisableControlAction(0, 71, true) -- accelerating
            DisableControlAction(0, 72, true) -- decelerating
            for i = 81, 85 do -- radio stuff
                DisableControlAction(0, i, true)
            end
            DisableControlAction(0, 106, true) -- turning vehicle wheels
        end
    end)
end

local function onMenuClose()
    local properties = lib.getVehicleProperties(cache.vehicle)
    local ignore = {
        ['bodyHealth'] = true,
        ['engineHealth'] = true,
        ['tankHealth'] = true,
        ['fuelLevel'] = true,
        ['oilLevel'] = true,
        ['dirtLevel'] = true,
        ['wheelSize'] = true,
        ['extras'] = true,
        ['modNitrous'] = true,
        ['tyres'] = true,
        ['doors'] = true,
        ['windows'] = true,
        ['bulletProofTyres'] = true,
        ['wheelWidth'] = true,
    }
    for i, v in pairs(properties) do
        if ignore[i] then
            properties[i] = nil
            goto continue
        end
        if v == oldcarinfo[i] then
            properties[i] = nil
        elseif type(v) == 'table' then
            local same = true
            if #v == #oldcarinfo[i] then
                for l = 1, #v do
                    if v[l] ~= oldcarinfo[i][l] then
                        same = false
                    end
                end
                if same then
                    properties[i] = nil
                end
            end
        end
        ::continue::
    end
    if next(properties) == nil then return end
    TriggerServerEvent('onebit_mechanic:server:AddTicket', VehToNet(cache.vehicle), properties, shared.GetVehName(cache.vehicle), qb.GetPlate(cache.vehicle))
end

local function repair()
    local success = lib.callback.await('onebit_mechanic:server:repair', false, GetVehicleBodyHealth(vehicle))
    if success then
        lib.notify({
            title = 'Customs Preview',
            description = 'Vehicle repaired!',
            position = 'top',
            type = 'success'
        })
        SendNUIMessage({sound = true})
        SetVehicleBodyHealth(vehicle, 1000.0)
        SetVehicleEngineHealth(vehicle, 1000.0)
        local fuelLevel = GetVehicleFuelLevel(vehicle)
        SetVehicleFixed(vehicle)
        SetVehicleFuelLevel(vehicle, fuelLevel)
    else
        lib.notify({
            title = 'Customs',
            description = 'You don\'t have enough money!',
            position = 'top',
            type = 'error'
        })
    end

    menu.options = main()
    lib.setMenuOptions(menu.id, menu.options)
    lib.showMenu(menu.id, 1)
end

local function onSubmit(selected, scrollIndex, args)
    if menu.options[selected].label == 'Repair' then
        lib.hideMenu(false)
        repair()
        return
    end
    local menuId = require(args.menu)()
    lib.showMenu(menuId, 1)
end

menu.onSelected = function(selected)
    PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    mainLastIndex = selected
end

menu.onClose = function()
    onMenuClose()
    inMenu = false
    stopDragCam()
    lib.showTextUI('Press [E] to preview some tunes to you vehicle', {
        icon = 'fa-solid fa-car',
        position = 'left-center',
    })
    lib.setVehicleProperties(cache.vehicle, oldcarinfo)
    oldcarinfo = {}
    ClearSave()
end

return function()
    if not cache.vehicle or inMenu then return end
    vehicle = cache.vehicle
    SetVehicleModKit(vehicle, 0)
    oldcarinfo = lib.getVehicleProperties(vehicle)
    menu.options = main()
    lib.registerMenu(menu, onSubmit)
    lib.showMenu(menu.id, 1)
    disableControls()
    startDragCam(vehicle)
end
