
local shared = require 'shared.shared'
local qb = require 'client.qb'
local inv = require 'client.inv'
local repair = require 'client.repair'
local customize = require 'client.customize'
local Zones = {}
local stuff = {'suspension', 'brakes', 'transmission'}

local Wait = Wait
local AddStateBagChangeHandler = AddStateBagChangeHandler
local NetworkGetEntityOwner = NetworkGetEntityOwner

function getinfo()
    return Zones
end

local blips = {}
local function AddBlips()
    local i = 1
    for _, v in pairs(Config.Locations) do
        blips[i] = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z-1)
        SetBlipSprite(blips[i], 779)
        SetBlipDisplay(blips[i], 4)
        SetBlipScale  (blips[i], 0.80)
        SetBlipColour (blips[i], 3)
        SetBlipAsShortRange(blips[i], true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString('Mechanic')
        EndTextCommandSetBlipName(blips[i])
        i = i + 1
    end
end




function ZoneStart()
    for i, v in pairs(Config.Locations) do
        Zones[i] = {
            inMainZone = false,
            inPaintingZone = false,
        }
        lib.zones.poly({
            points = v.points,
            onEnter = function()
                Zones[i].inMainZone = true
            end,
            onExit = function()
                Zones[i].inMainZone = false
            end
        })
        for _, k in pairs(v.paintloc) do
            lib.zones.box({
                coords = k.coords,
                size = k.size,
                rotation = k.rotation,
                onEnter = function()
                    Zones[i].inPaintingZone = true
                end,
                onExit = function()
                    Zones[i].inPaintingZone = false
                end,
            })
        end
    end
end

local function stateBagWrapper(keyFilter, cb)
    return AddStateBagChangeHandler(keyFilter, '', function(bagName, _, value, _, replicated)
        local netId = tonumber(bagName:gsub('entity:', ''), 10)

        local timeout = GetGameTimer() + 1500

        while not NetworkDoesEntityExistWithNetworkId(netId) do
            if timeout < GetGameTimer() then
                print('onebit_mechanic: Timeout while waiting for entity to exist')
                return
            end

            Wait(0)
        end

        local entity = NetToVeh(netId)

        local amOwner = NetworkGetEntityOwner(entity) == cache.playerId
        if (not amOwner and replicated) or (amOwner and not replicated) then
            return
        end

        cb(entity, value)
    end)
end


-- Events --

local function registerNetEvent(event, fn)
    RegisterNetEvent(event, function(...)
        if source ~= '' then fn(...) end
    end)
end


AddEventHandler('onResourceStop', function(resourceName)
    if (cache.resource == resourceName) then
        for i = 1, #blips do
            RemoveBlip(blips[i])
        end
    end
end)

-- AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
--     ZoneStart()
--     require('client.target')()
--     exports.ox_inventory:displayMetadata('vehname', 'Vehicle')
--     exports.ox_inventory:displayMetadata('vehplate', 'Plate')
--     AddBlips()
-- end)

registerNetEvent('onebit_mechanic:client:fixvehicleprops', function()
    if not cache.vehicle or cache.seat ~= -1 then return end
    local vehclass = GetVehicleClass(cache.vehicle)
    if not (vehclass >= 13 and vehclass <= 16) then
        local vehstate = Entity(cache.vehicle).state
        vehstate:set('suspension', 100, true)
        vehstate:set('brakes', 100, true)
        vehstate:set('transmission', 100, true)
    end
end)

registerNetEvent('onebit_mechanic:client:DegradePart', function()
    if not cache.vehicle or cache.seat ~= -1 then return end
    local DamageComponents = {
        "transmission",
        "brakes",
        "suspension"
    }
    local vehstate = Entity(cache.vehicle).state
    math.randomseed(GetGameTimer())
    local random = DamageComponents[math.random(#DamageComponents)]
    local amount = vehstate[random] - math.random(1, 3)
    if amount < 0 then amount = 0 end
    vehstate:set(random, amount, true)
end)
-- Callbacks --

lib.callback.register('onebit_mechanic:client:vehicleProps', function(vehicle)
    return qb.QBCore.Functions.GetVehicleProperties(vehicle)
end)

lib.callback.register('onebit_mechanic:ApplyVehProperties', function(netid, data)
    local timeout = 100
    while not NetworkDoesEntityExistWithNetworkId(netid) and timeout > 0 do
        Wait(0)
        timeout -= 1
    end
    if timeout > 0 then
        if data.bodyHealth and data.bodyHealth >= 800 then
            SetVehicleFixed(NetToVeh(netid))
        end
        Wait(50)
        lib.setVehicleProperties(NetToVeh(netid), data)
        return true
    end
    return false
end)

lib.callback.register('onebit_mechanic:client:openhood', function(netid, bool)
    local veh = NetToVeh(netid)
    if bool then
        SetVehicleDoorOpen(veh, 4, false, true)
    else
        SetVehicleDoorShut(veh, 4, false)
    end
end)

lib.callback.register('onebit_mechanic:client:GetPermission', function(price)
    local success = lib.alertDialog({
        header = '**Payment Confiemation**',
        content = 'Importing these parts will cost the company $'..price..'. Do you accept?',
        centered = true,
        cancel = true,
        labels = {
            cancel = 'Deny',
            confirm = 'Accept'
        }
    })
    if success ~= 'confirm' then
        return false
    end
    return true
end)

lib.callback.register('onebit_mechanic:SetVehRepair', function(netid, type, value)
    local timeout = 100
    while not NetworkDoesEntityExistWithNetworkId(netid) and timeout > 0 do
        Wait(0)
        timeout -= 1
    end
    if timeout > 0 then
        Entity(NetToVeh(netid)).state:set(type, value, true)
        return true
    end
    return false
end)

lib.callback.register('onebit_mechanic:ccallback:fixvehicleparts', function()
    if not cache.vehicle then return 'novehicle' end
    if cache.seat ~= -1 then return 'isnotdriver' end
    local vehstate = Entity(cache.vehicle).state
    for _, v in pairs(stuff) do
        vehstate:set(v, 100, true)
    end
    lib.notify({description = 'Vehicle Parts Fixed', type = 'success'})
    return true
end)
-- Item Exports --

exports('engineparts', function(data)
    local info = inv.GetSlot(data.name, data.slot)
    repair.engineRepair(info)
end)

exports('bodypanels', function(data)
    local info = inv.GetSlot(data.name, data.slot)
    repair.bodyRepair(info)
end)

exports('cleaningkit', function(data)
    local info = inv.GetSlot(data.name, data.slot)
    repair.bodyClean(info)
end)

exports('part', function(data)
    local info = inv.GetSlot(data.name, data.slot)
    customize.UsePart(info)
end)

exports('ticket', function(data)
    local info = inv.GetSlot(data.name, data.slot)
    customize.ViewTicket(info)
end)

exports('otherrepair', function(data)
    local info = inv.GetSlot(data.name, data.slot)
    if not info or not info.metadata.repairtype then return end
    repair[info.metadata.repairtype](info)
end)


-- Dirt Level Shit --

local function DirtLoop(value, oldveh)
    CreateThread(function()
        while cache.seat == -1 and cache.vehicle == oldveh do
            SetVehicleDirtLevel(cache.vehicle, 0.0)
            Wait(3000)
        end
    end)
end



lib.onCache('seat', function(value)
    if value ~= -1 then return end
    local vehstate = Entity(cache.vehicle).state
    local vehclass = GetVehicleClass(cache.vehicle)
    -- Adding state for parts for local vehicles --
    if not (vehclass >= 13 and vehclass <= 16) then
        for i = 1, #stuff do
            if not vehstate[stuff[i]] then
                vehstate:set(stuff[i], math.random(85, 99), true)
            end
        end
    end
    -- --
    if not vehstate.isWaxed then return end
    DirtLoop(value, cache.vehicle)
end)

-- State Bag Handler --

local function PoliceVehicle(model, value)
    return (Config.PoliceVeh[model] and math.ceil(value/4)) or value
end

stateBagWrapper('suspension', function(veh, value)
    if type(value) ~= 'number' or GetVehicleClass(veh) == 18 then return end
    local model = GetEntityModel(veh)
    local modelMaxTraction = GetVehicleModelMaxTraction(model)
    local maxdecrease = modelMaxTraction - (modelMaxTraction/3)
    value = PoliceVehicle(model, value)
    local decrease = maxdecrease - ((value/100)*maxdecrease)
    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fTractionCurveMax', modelMaxTraction - decrease)
    --print('suspension updated')
end)

stateBagWrapper('brakes', function(veh, value)
    if type(value) ~= 'number' or GetVehicleClass(veh) == 18 then return end
    local model = GetEntityModel(veh)
    local modelMaxBrakes = GetVehicleModelMaxBraking(model)
    local maxdecrease = modelMaxBrakes - (modelMaxBrakes/3)
    value = PoliceVehicle(model, value)
    local decrease = maxdecrease - ((value/100)*maxdecrease)
    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fBrakeForce', modelMaxBrakes - decrease)
    --print('brakes updated')
end)

stateBagWrapper('transmission', function(veh, value)
    if type(value) ~= 'number' or GetVehicleClass(veh) == 18 then return end
    local model = GetEntityModel(veh)
    local modelAcceleration = GetVehicleModelAcceleration(model)
    local maxdecrease = modelAcceleration - (modelAcceleration/3)
    value = PoliceVehicle(model, value)
    local decrease = maxdecrease - ((value/100)*maxdecrease)
    SetVehicleHandlingFloat(veh, 'CHandlingData', 'fInitialDriveForce', modelAcceleration - decrease)
    --print('transmission updated')
end)


-- Thread
CreateThread(function()
    while GetResourceState('ox_lib') ~= 'started' or GetResourceState('ox_target') ~= 'started' or GetResourceState('ox_inventory') ~= 'started' do
        Wait(1000)
    end
    ZoneStart()
    require('client.target')()
    exports.ox_inventory:displayMetadata('vehname', 'Vehicle')
    exports.ox_inventory:displayMetadata('vehplate', 'Plate')
    AddBlips()
end)