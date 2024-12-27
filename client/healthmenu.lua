local shared = require('shared.shared')
local qb = require('client.qb')
local isopen = false
local isinanim = false

local function mechanicAnim(vehicle)
    local animDict = 'mini@repair'
    local animation = 'fixing_a_player'

    lib.requestAnimDict(animDict)
    if GetVehicleDoorAngleRatio(vehicle, 4) > 0.1 then isopen = true else isopen = false lib.callback.await('onebit_mechanic:sever:openhood', 50, VehToNet(vehicle), true) end
    SetVehicleDoorOpen(vehicle, 4, false, true)
    TaskPlayAnim(cache.ped, animDict, animation, 8.0, -8.0, -1, 1, 0, 0, 0, 0)
end

local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function CalculateParts(amount, percent)
    return math.ceil(math.floor(100/percent) - (amount/percent))
end

local function PartsHealth(vehicle)
    local vehstate = Entity(vehicle).state
    if not vehstate.suspension or not vehstate.brakes or not vehstate.transmission then
        lib.notify({description = "You cannot check this for some reason", type = 'error'})
        lib.showContext('mechanic_healthmenu')
        return
    end

    lib.registerContext({
        id = 'mechanic_partshealthmenu',
        title = 'Vehicle Parts Health Status',
        canClose = true,
        onExit = function()
            ClearPedTasks(cache.ped)
            if not isopen then
                lib.callback.await('onebit_mechanic:sever:openhood', 50, VehToNet(vehicle), false)
            end
        end,
        menu = 'mechanic_healthmenu',
        options = {
            {
                title = 'Transmission Parts Health',
                progress = vehstate.transmission,
                icon = 'fa-solid fa-gauge-high',
                colorScheme = shared.ProgBarColor(vehstate.transmission),
                metadata = {{label = 'Health', value = vehstate.transmission}, {label = 'Parts Needed', value = CalculateParts(vehstate.transmission, Config.HealthIncrease.Transmission)}}
            },
            {
                title = 'Brake Parts Health',
                progress = vehstate.brakes,
                icon = 'fa-solid fa-ban',
                colorScheme = shared.ProgBarColor(vehstate.brakes),
                metadata = {{label = 'Health', value = vehstate.brakes}, {label = 'Parts Needed', value = CalculateParts(vehstate.brakes, Config.HealthIncrease.Brakes)}}
            },
            {
                title = 'Suspension Parts Health',
                progress = vehstate.suspension,
                icon = 'fas fa-unlink',
                colorScheme = shared.ProgBarColor(vehstate.suspension),
                metadata = {{label = 'Health', value = vehstate.suspension}, {label = 'Parts Needed', value = CalculateParts(vehstate.suspension, Config.HealthIncrease.Suspension)}}
            },
        }
    })
    lib.showContext('mechanic_partshealthmenu')
end

function HealthMenu(vehicle)
    if cache.weapon or cache.vehicle then return end
    local info = lib.getVehicleProperties(vehicle)
    local vehclass = GetVehicleClass(vehicle)
    if not info then return end
    local options = {}
    options[#options+1] = {
        title = 'Vehicle Name: '..(shared.GetVehName(vehicle) or GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))),
        description = 'Plate: '..qb.GetPlate(vehicle)..'\nClass: '..(shared.GetVehClass(vehicle) or 'D')
    }
    local enginehealth = info.engineHealth/10
    local bodyhealth = info.bodyHealth/10
    local dirtLevel = ((15.0 - info.dirtLevel)/15.0) * 100
    options[#options+1] = {
        title = 'Engine Health',
        progress = enginehealth,
        icon = 'fa-solid fa-fire',
        colorScheme = shared.ProgBarColor(enginehealth),
        metadata = {{label = 'Health', value = enginehealth}, {label = 'Parts Needed', value = CalculateParts(enginehealth, Config.HealthIncrease.Engine)}}
    }
    options[#options+1] = {
        title = 'Body Health',
        progress = bodyhealth,
        icon = 'fa-solid fa-car-side',
        colorScheme = shared.ProgBarColor(bodyhealth),
        metadata = {{label = 'Health', value = bodyhealth}, {label = 'Parts Needed', value = CalculateParts(bodyhealth, Config.HealthIncrease.Body)}}
    }
    options[#options+1] = {
        title = 'Dirt Level',
        progress = dirtLevel,
        icon = 'fa-solid fa-soap',
        colorScheme = shared.ProgBarColor(dirtLevel),
        metadata = {{label = 'Dirt Level', value = round(dirtLevel, 1)}}
    }
    if not (vehclass >= 13 and vehclass <= 16) then
        options[#options+1] = {
            title = 'View Vehicle Parts Health',
            icon = 'fa-solid fa-gears',
            onSelect = function()
                PartsHealth(vehicle)
            end,
            arrow = true
        }
    end


    lib.registerContext({
        id = 'mechanic_healthmenu',
        title = 'Vehicle Health Status',
        canClose = true,
        onExit = function()
            ClearPedTasks(cache.ped)
            if not isopen then
                lib.callback.await('onebit_mechanic:sever:openhood', 50, VehToNet(vehicle), false)
            end
        end,
        options = options
    })
    lib.showContext('mechanic_healthmenu')
    mechanicAnim(vehicle)
end

return HealthMenu