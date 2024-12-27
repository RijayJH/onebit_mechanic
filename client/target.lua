

function TargetStart()
    for i, v in pairs(Config.Locations) do
        if not v.crafting then goto continue end
        if not v.crafting.target then goto continue end
        exports.ox_target:addBoxZone({
            coords = v.crafting.target.coords,
            size = v.crafting.target.size,
            rotation = v.crafting.target.rotation,
            options = {
                {
                    label = 'Craft Items',
                    name = 'mechanic_crafting:'..i,
                    icon = 'fa-solid fa-toolbox',
                    distance = v.crafting.target.distance,
                    groups = i,
                    onSelect = function()
                        exports.ox_inventory:openInventory('crafting', {id = 'mechanic-bench', index = i})
                    end,
                },
            }
        })
        ::continue::
        if v.ped then
            local data = {
                id = 'onebit_mechanic:'..i,
                model = joaat(v.ped.model),
                coords = v.ped.coords,
                anim = {
                    scenario = v.ped.scenario
                },
                target = {
                    {
                        name = 'onebit_mechanic:'..i..':GiveTicket',
                        icon = 'fa-solid fa-ticket',
                        label = 'Give Customer Ticket',
                        distance = 2.5,
                        onSelect = function()
                            exports.ox_inventory:openInventory('stash', { id = 'mechanic_ticket', owner = i })
                        end,
                        groups = i,
                    },
                    {
                        name = 'onebit_mechanic:'..i..':ProcessTicket',
                        icon = 'fa-solid fa-ticket',
                        label = 'Process Ticket',
                        distance = 2.5,
                        onSelect = function()
                            local await = lib.callback.await('onebit_mechanic:server:ProcessTicket', false, i)
                            if not await then lib.notify({description = 'Failed', type = 'error'}) else lib.notify({description = 'Success!! Please Check the Processed Item Storage', type = 'success'}) end
                        end,
                        groups = i,
                    }
                }
            }
            TriggerEvent('onebit_persistents:Client:RegisterEnt', data)
        end
        if v.customizationStorage then
            exports.ox_target:addBoxZone({
                coords = v.customizationStorage.coords,
                size = v.customizationStorage.size,
                rotation = v.customizationStorage.rotation,
                options = {
                    {
                        label = 'Get Processed Items',
                        name = 'mechanic_processing:'..i,
                        icon = 'fa-solid fa-toolbox',
                        distance = v.customizationStorage.distance,
                        onSelect = function()
                            exports.ox_inventory:openInventory('stash', {id = 'mechanic_products', owner = i})
                        end,
                        groups = i
                    },
                }
            })
        end
        exports.ox_target:addBoxZone({
            coords = v.storage.coords,
            size = v.storage.size,
            rotation = v.storage.rotation,
            options = {
                {
                    label = 'Open Storage',
                    name = 'mechanic_storage:'..i,
                    icon = 'fa-solid fa-warehouse',
                    distance = v.storage.distance,
                    onSelect = function()
                        exports.ox_inventory:openInventory('stash', {id = 'mechanic_storage', owner = i})
                    end,
                    groups = i
                },
            }
        })
        exports.ox_target:addGlobalVehicle({
            {
                name = 'onebit_mechanic:SeeDamage',
                label = 'Vehicle Health',
                icon = 'fa-solid fa-heart-pulse',
                bones = {'bonnet', 'engine'},
                groups = i,
                canInteract = function(entity, distance)
                    if cache.weapon or cache.vehicle then return false end
                    return distance < 5.0 and (getinfo()[i].inMainZone or exports["snipe-menu"]:isDevMode())
                end,
                onSelect = function(data)
                    if GetVehicleDoorLockStatus(data.entity) > 1 then lib.notify({description = 'Vehicle Locked', type = 'error'}) return end
                    require('client.healthmenu')(data.entity)
                end
            }
        })
    end
end

return TargetStart