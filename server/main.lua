
local sql = require 'server.sql'
local inv = require 'server.inv'
local shared = require 'shared.shared'
local qb = require 'server.qb'

-- Events --
RegisterNetEvent('onebit_mechanic:server:saveVehicleProps', function()
    local src = source
    local vehicleProps = lib.callback.await('onebit_mechanic:client:vehicle', src)
    if sql.IsVehicleOwned(vehicleProps.plate) then
        sql.UpdateMods(vehicleProps, vehicleProps.plate)
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (cache.resource == resourceName) then
        while GetResourceState('ox_inventory') ~= 'started' do
            Wait(100)
        end
        inv.CreateCrafting()
        inv.CreateStash()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (cache.resource == resourceName) then
        inv.ClearItemsfromTempStash()
    end
end)

RegisterNetEvent('onebit_mechanic:server:AddTicket', function(netId, properties, name, plate)
    local src = source
    if not name or not plate then lib.notify(src, {description = 'This vehicle cannot be customized', type = 'error'}) return end
    print(netId, properties, name, plate)
    inv.AddItem(src, 'mechanic_ticket', 1, {vehname = name, properties = properties, vehplate = plate})
end)

-- Callbacks --

lib.callback.register('onebit_mechanic:server:ProcessTicket', function(source, i)
    local item = inv.GetTicketItemSlot(i)
    if not item then lib.notify(source, {description = 'Nothing to Process', type = 'error'}) return false end
    if next(item.metadata) == nil then lib.notify(source, {description = 'Seems like this ticket is empty', type = 'error'}) inv.RemoveItem('mechanic_ticket:'..i, item.name, 1) return false end
    local properties = item.metadata.properties
    if next(properties) == nil then return false end
    local finalprice = 0
    for j, _ in pairs(properties) do
        finalprice = finalprice + Config.Prices[Config.Types[j].type]
    end
    if not exports['Renewed-Banking']:getAccountMoney(i) or not (exports['Renewed-Banking']:getAccountMoney(i) >= finalprice) then lib.notify(source, {description = 'Company Account doesnt have enough money', type = 'error'}) return false end
    local success = lib.callback.await('onebit_mechanic:client:GetPermission', source, finalprice)
    if not success then return false end
    exports['Renewed-Banking']:removeAccountMoney(i, finalprice)
    exports['Renewed-Banking']:handleTransaction(i, 'Parts Import Fees', finalprice, 'Import fees for vehicle parts', 'Outside Source', i, 'withdraw')
    inv.GetinvItems('mechanic_products', i)
    for l, v in pairs(properties) do
        inv.AddItem('mechanic_products:'..i, 'mechanic_part', 1, {label = Config.Types[l].name, image = Config.Types[l].image, vehname = item.metadata.vehname, vehplate = item.metadata.vehplate, property = v, type = Config.Types[l].type, custom_name = l})
    end
    if next(inv.GetinvItems('mechanic_products', i)) == nil then lib.notify(source, {description = 'Couldnt add items in stash! Please try again!', type = 'error'}) return false end
    inv.RemoveItem('mechanic_ticket:'..i, item.name, 1)
    return true
end)

lib.callback.register('onebit_mechanic:server:EditVehInfo', function(source, veh, info, item)
    local entity = NetworkGetEntityFromNetworkId(veh)
    local owner = NetworkGetEntityOwner(entity)
    return lib.callback.await('onebit_mechanic:ApplyVehProperties', owner, veh, info), inv.RemoveItem(source, item.name, 1, item.slot)
end)

lib.callback.register('onebit_mechanic:server:SetWax', function(source, netid)
    local veh = NetworkGetEntityFromNetworkId(netid)
    Entity(veh).state:set('isWaxed', true, true)
    return true
end)

lib.callback.register('onebit_mechanic:sever:openhood', function(source, netid, bool)
    local entity = NetworkGetEntityFromNetworkId(netid)
    local owner = NetworkGetEntityOwner(entity)
    return lib.callback.await('onebit_mechanic:client:openhood', owner, netid, bool)
end)

lib.callback.register('onebit_mechanic:server:SetOtherRepair', function(source, vehnet, type, value, item)
    local veh = NetworkGetEntityFromNetworkId(vehnet)
    local owner = NetworkGetEntityOwner(veh)
    return lib.callback.await('onebit_mechanic:SetVehRepair', owner, vehnet, type, value), inv.RemoveItem(source, item.name, 1, item.slot)
end)

lib.callback.register('onebit_mechanic:scallback:fixvehicleparts', function(source, id)
    return lib.callback.await('onebit_mechanic:ccallback:fixvehicleparts', id)
end)
-- Command --

lib.addCommand('fixcarparts', {
    help = 'Fixes all interior parts of a car.',
    params = {},
    restricted = 'qbcore.god'
}, function(source, args, raw)
    TriggerClientEvent('onebit_mechanic:client:fixvehicleprops', source)
end)
-- --

-- Local Functions --

local function GetConfigLocation()
    return Config.Locations
end
exports('GetConfigLocation', GetConfigLocation)

-- Cron --

lib.cron.new('*/5 * * * *', function()
    TriggerClientEvent('onebit_mechanic:client:DegradePart', -1)
end)