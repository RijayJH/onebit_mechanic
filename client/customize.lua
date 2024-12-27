local customize = {Anim = {}}
local shared = require 'shared.shared'
local qb = require 'client.qb'
local timeout = GetGameTimer()

local function CheckTimeout()
    if GetGameTimer() - timeout < 500 then return false end
    timeout = GetGameTimer()
    return true
end

function customize.Anim.Color(info, veh)
    if lib.progressCircle({
        duration = 10000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
        anim = {
            dict =  "switch@franklin@lamar_tagging_wall",
            clip = "lamar_tagging_exit_loop_lamar",
        },
        prop = {
            model = `ng_proc_spraycan01b`,
            bone = 57005,
            pos = {
                x = 0.072,
                y = 0.041,
                z = -0.06,
            },
            rot = {
                x = 33.0,
                y = 28.0,
                z = 0.0,
            }
        }
    }) then
        spraying = false
        DeleteObject(spraycan)
        return lib.callback.await('onebit_mechanic:server:EditVehInfo', false, VehToNet(veh), {[info.metadata.custom_name] = info.metadata.property}, info)
    else
        spraying = false
        DeleteObject(spraycan)
        return false
    end
end

function customize.Anim.Part(info, veh)
    if lib.progressCircle({
        duration = 10000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
        },
        anim = {
            scenario = 'WORLD_HUMAN_WELDING'
        },
    }) then return lib.callback.await('onebit_mechanic:server:EditVehInfo', false, VehToNet(veh), {[info.metadata.custom_name] = info.metadata.property}, info) else return false end

end

function customize.UsePart(info)
    if not CheckTimeout() then return false end
    if cache.weapon or cache.vehicle then return end
    local job = qb.GetJob().name
    if not Config.Locations[job] then return lib.notify({description = 'You cannot use this', type = 'error'}) end
    if not getinfo()[job].inMainZone then lib.notify({description = 'Can only be used inside the shop', type = 'error'}) return end
    local veh = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3, false)
    if not veh then lib.notify({description = 'No Vehicle Nearby', type = 'error'}) return end
    if qb.GetPlate(veh) ~= info.metadata.vehplate then lib.notify({description = 'The part doesnt fit in this vehicle', type = 'error'}) return end
    if info.metadata.type == 'Color' and not getinfo()[job].inPaintingZone then lib.notify({description = 'You can only use this in a paint zone', type = 'error'}) return end
    local result = customize.Anim[info.metadata.type](info, veh)
    if not result then lib.notify({description = 'Failed', type = 'error'}) end
end

function customize.ViewTicket(info)
    if not CheckTimeout() then return false end
    if not info.metadata or not info.metadata.properties then lib.notify({description = 'This ticket is empty!', type = 'error'}) return end
    local content = 'List of Parts to Order:     \n     '
    for i, v in pairs(info.metadata.properties) do
        content = content..'\n      '..Config.Types[i].name..'   '
    end
    lib.alertDialog({
        header = '**Ticket Information: '..info.metadata.vehname..'**',
        content = content,
        centered = true,
        labels = {
            confirm = 'Exit'
        }
    })
end


return customize