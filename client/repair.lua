local repair = {}
local shared = require 'shared.shared'
local qb = require 'client.qb'
local isopen = false
local timeout = GetGameTimer()

local function Anim(vehicle, start, anim, dict, prop, open)
    local animDict = dict
    local animation = anim

    if start then
        lib.requestAnimDict(animDict)
        if open then
            if GetVehicleDoorAngleRatio(vehicle, 4) > 0.1 then isopen = true else isopen = false lib.callback.await('onebit_mechanic:sever:openhood', 50, VehToNet(vehicle), true) end
        end
    end
    TaskPlayAnim(cache.ped, animDict, animation, 8.0, -8.0, -1, 1, 0, 0, 0, 0)
end

local function Scenario(scenario)
    TaskStartScenarioInPlace(cache.ped, scenario, 0, true)
end

local function CheckTimeout()
    if GetGameTimer() - timeout < 500 then return false end
    timeout = GetGameTimer()
    return true
end

local function Minigame(veh, max, anim, dict, prop, open, scenario)
    LocalPlayer.state:set('invBusy', true, false)
    if anim then
        Anim(veh, true, anim, dict, prop, open)
    elseif scenario then
        Scenario(scenario)
    end
    local fullsuccess = false
    math.randomseed(GetGameTimer())
    local random = math.random(max)
    local int
    if exports['ps-buffs']:HasBuff('intelligence') then int = { areaSize = 40, speedMultiplier = 0.15 } else int = { areaSize = 30, speedMultiplier = 0.15 } end
    for i = 1, random do
        local success = lib.skillCheck(int, {'1', '2', '3', '4'})
        if not success then
            break
        elseif i == random then
            fullsuccess = true
            break
        end
        Wait(100)
        if anim then
            Anim(veh, false, anim, dict, prop, open)
        end
    end
    if not isopen then
        lib.callback.await('onebit_mechanic:sever:openhood', 50, VehToNet(veh), false)
    end
    ClearPedTasks(cache.ped)
    LocalPlayer.state:set('invBusy', false, false)
    return fullsuccess
end

function repair.engineRepair(info)
    if not CheckTimeout() then return end
    if cache.vehicle or cache.weapon then return end
    local job = qb.GetJob().name
    if not Config.Locations[job] then return lib.notify({description = 'You cannot use this', type = 'error'}) end
    if not getinfo()[job].inMainZone then lib.notify({description = 'Can only be used inside the shop', type = 'error'}) return end
    if next(info.metadata) == nil then return end
    local veh = lib.getClosestVehicle(GetEntityCoords(cache.ped), 4, false)
    if not veh then lib.notify({description = 'No Vehicle Nearby', type = 'error'}) return end
    local coords = GetWorldPositionOfEntityBone(veh, GetEntityBoneIndexByName(veh, 'engine'))
    local dist = #(coords - GetEntityCoords(cache.ped))
    if dist > 3.5 then lib.notify({description = 'Too Far away from the engine', type = 'error'}) return end
    if shared.GetVehClass(veh) ~= info.metadata.vehclass and not(info.metadata.vehclass == 'D' and not shared.GetVehClass(veh)) then lib.notify({description = 'Wrong Class', type = 'error'}) return end
    local engineinfo = lib.getVehicleProperties(veh).engineHealth
    if engineinfo >= 1000 then lib.notify({description = 'Already fixed', type = 'error'}) return end
    if not Minigame(veh, 5, 'fixing_a_player', 'mini@repair', nil, true) then return end
    engineinfo = engineinfo + (Config.HealthIncrease.Engine * 10)
    print(engineinfo)
    if engineinfo >= 1000 then engineinfo = 1000.0 end
    local await, remove = lib.callback.await('onebit_mechanic:server:EditVehInfo', 100, VehToNet(veh), {engineHealth = engineinfo}, info)
    if not await or not remove then lib.notify({description = 'Something went wrong', type = 'error'}) return end

end


function repair.bodyRepair(info)
    if not CheckTimeout() then return end
    if cache.vehicle or cache.weapon then return end
    local job = qb.GetJob().name
    if not Config.Locations[job] then return lib.notify({description = 'You cannot use this', type = 'error'}) end
    if not getinfo()[job].inMainZone then lib.notify({description = 'Can only be used inside the shop', type = 'error'}) return end
    if next(info.metadata) == nil then return end
    local veh = lib.getClosestVehicle(GetEntityCoords(cache.ped), 4, false)
    if not veh then lib.notify({description = 'No Vehicle Nearby', type = 'error'}) return end
    if shared.GetVehClass(veh) ~= info.metadata.vehclass and not(info.metadata.vehclass == 'D' and not shared.GetVehClass(veh)) then lib.notify({description = 'Wrong Class', type = 'error'}) return end
    local vehprop = lib.getVehicleProperties(veh)
    if not vehprop then return end
    if vehprop.bodyHealth >= 1000 then lib.notify({description = 'Already fixed', type = 'error'}) return end
    if not Minigame(veh, 5, nil, nil, nil, false, 'WORLD_HUMAN_WELDING') then return end
    local bodyinfo = vehprop.bodyHealth + (Config.HealthIncrease.Body * 10)
    local engineinfo = vehprop.engineHealth
    if bodyinfo >= 1000 then bodyinfo = 1000.0 end
    local await, remove = lib.callback.await('onebit_mechanic:server:EditVehInfo', 100, VehToNet(veh), {engineHealth = engineinfo, bodyHealth = bodyinfo}, info)
    if not await or not remove then lib.notify({description = 'Something went wrong', type = 'error'}) return end
end

function repair.transmission(info)
    if not CheckTimeout() then return end
    if cache.vehicle or cache.weapon then return end
    local job = qb.GetJob().name
    if not Config.Locations[job] then return lib.notify({description = 'You cannot use this', type = 'error'}) end
    if not getinfo()[job].inMainZone then lib.notify({description = 'Can only be used inside the shop', type = 'error'}) return end
    if next(info.metadata) == nil then return end
    local veh = lib.getClosestVehicle(GetEntityCoords(cache.ped), 4, false)
    if not veh then lib.notify({description = 'No Vehicle Nearby', type = 'error'}) return end
    local coords = GetWorldPositionOfEntityBone(veh, GetEntityBoneIndexByName(veh, 'engine'))
    local dist = #(coords - GetEntityCoords(cache.ped))
    if dist > 3.5 then lib.notify({description = 'Too Far away from the engine', type = 'error'}) return end
    if shared.GetVehClass(veh) ~= info.metadata.vehclass and not(info.metadata.vehclass == 'D' and not shared.GetVehClass(veh)) then lib.notify({description = 'Wrong Class', type = 'error'}) return end
    local vehstate = Entity(veh).state 
    if vehstate.transmission >= 100 then lib.notify({description = 'Already fixed', type = 'error'}) return end
    if not Minigame(veh, 5, 'fixing_a_player', 'mini@repair', nil, true) then return end
    local transmission = vehstate.transmission + Config.HealthIncrease.Transmission
    if transmission > 100 then transmission = 100 end
    local dodatthing, dodatthing2 = lib.callback.await('onebit_mechanic:server:SetOtherRepair', false, VehToNet(veh), 'transmission', transmission, info)
    if not dodatthing or not dodatthing2 then return lib.notify({description = 'This do be broken', type = 'error'}) end
end

function repair.brakes(info)
    local wheels = {'wheel_lf', 'wheel_rf', 'wheel_lr', 'wheel_rr'}
    if not CheckTimeout() then return end
    if cache.vehicle or cache.weapon then return end
    local job = qb.GetJob().name
    if not Config.Locations[job] then return lib.notify({description = 'You cannot use this', type = 'error'}) end
    if not getinfo()[job].inMainZone then lib.notify({description = 'Can only be used inside the shop', type = 'error'}) return end
    if next(info.metadata) == nil then return end
    local veh = lib.getClosestVehicle(GetEntityCoords(cache.ped), 4, false)
    if not veh then lib.notify({description = 'No Vehicle Nearby', type = 'error'}) return end
    local isnear = false
    for _, v in pairs(wheels) do
        local coords = GetWorldPositionOfEntityBone(veh, GetEntityBoneIndexByName(veh, v))
        local dist = #(coords - GetEntityCoords(cache.ped))
        if dist <= 1.0 then
            isnear = true
            break
        end
    end
    if not isnear then lib.notify({description = 'Too Far away from the wheels', type = 'error'}) return end
    if shared.GetVehClass(veh) ~= info.metadata.vehclass and not(info.metadata.vehclass == 'D' and not shared.GetVehClass(veh)) then lib.notify({description = 'Wrong Class', type = 'error'}) return end
    local vehstate = Entity(veh).state 
    if vehstate.brakes >= 100 then lib.notify({description = 'Already fixed', type = 'error'}) return end
    if not Minigame(veh, 5, 'machinic_loop_mechandplayer', 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', nil, false) then return end
    local brakes = vehstate.brakes + Config.HealthIncrease.Brakes
    if brakes > 100 then brakes = 100 end
    local dodatthing, dodatthing2 = lib.callback.await('onebit_mechanic:server:SetOtherRepair', false, VehToNet(veh), 'brakes', brakes, info)
    if not dodatthing or not dodatthing2 then return lib.notify({description = 'This do be broken', type = 'error'}) end
end

function repair.suspension(info)
    local wheels = {'wheel_lf', 'wheel_rf', 'wheel_lr', 'wheel_rr'}
    if not CheckTimeout() then return end
    if cache.vehicle or cache.weapon then return end
    local job = qb.GetJob().name
    if not Config.Locations[job] then return lib.notify({description = 'You cannot use this', type = 'error'}) end
    if not getinfo()[job].inMainZone then lib.notify({description = 'Can only be used inside the shop', type = 'error'}) return end
    if next(info.metadata) == nil then return end
    local veh = lib.getClosestVehicle(GetEntityCoords(cache.ped), 4, false)
    if not veh then lib.notify({description = 'No Vehicle Nearby', type = 'error'}) return end
    local isnear = false
    for _, v in pairs(wheels) do
        local coords = GetWorldPositionOfEntityBone(veh, GetEntityBoneIndexByName(veh, v))
        local dist = #(coords - GetEntityCoords(cache.ped))
        if dist <= 1.0 then
            isnear = true
            break
        end
    end
    if not isnear then lib.notify({description = 'Too Far away from the wheels', type = 'error'}) return end
    if shared.GetVehClass(veh) ~= info.metadata.vehclass and not(info.metadata.vehclass == 'D' and not shared.GetVehClass(veh)) then lib.notify({description = 'Wrong Class', type = 'error'}) return end
    local vehstate = Entity(veh).state
    if vehstate.suspension >= 100 then lib.notify({description = 'Already fixed', type = 'error'}) return end
    if not Minigame(veh, 5, 'machinic_loop_mechandplayer', 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', nil, false) then return end
    local suspension = vehstate.suspension + Config.HealthIncrease.Suspension
    if suspension > 100 then suspension = 100 end
    local dodatthing, dodatthing2 = lib.callback.await('onebit_mechanic:server:SetOtherRepair', false, VehToNet(veh), 'suspension', suspension, info)
    if not dodatthing or not dodatthing2 then return lib.notify({description = 'This do be broken', type = 'error'}) end
end

function repair.bodyClean(info)
    if not CheckTimeout() then return end
    if cache.vehicle or cache.weapon then return end
    local veh = lib.getClosestVehicle(GetEntityCoords(cache.ped), 4, false)
    if not veh then lib.notify({description = 'No Vehicle Nearby', type = 'error'}) return end
    if lib.progressCircle({
        duration = 20000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        label = 'Cleaning...',
        disable = {
            car = true,
            move = true,
            combat = true,
        },
        anim = {
            scenario = 'WORLD_HUMAN_MAID_CLEAN',
        },
    }) then
        local await = lib.callback.await('onebit_mechanic:server:EditVehInfo', 100, VehToNet(veh), {dirtLevel = 0}, info)
        if not await then lib.notify({description = 'Something went wrong', type = 'error'}) return end
        Wait(100)
        if lib.progressCircle({
            duration = 20000,
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            label = 'Waxing Vehicle...',
            disable = {
                car = true,
                move = true,
                combat = true,
            },
            anim = {
                scenario = 'WORLD_HUMAN_MAID_CLEAN',
            },
        }) then
            local await2 = lib.callback.await('onebit_mechanic:server:SetWax', 100, VehToNet(veh))
            if not await2 then lib.notify({description = 'Something went wrong', type = 'error'}) return end
            local job = qb.GetJob().name
            if not Config.Locations[job] or not getinfo()[job].inMainZone then return end
            TriggerServerEvent('evidence:server:RemoveCarEvidence', GetVehicleNumberPlateText(veh))
        end
    end

end

return repair