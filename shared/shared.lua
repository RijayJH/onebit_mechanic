local shared = {}
local QBCore = exports['qb-core']:GetCoreObject()
local sharedinfo = {}

for i, v in pairs(QBCore.Shared.Vehicles) do
    if not v.class then goto continue end
    sharedinfo[v.hash] = {
        name = v.name,
        class = v.class
    }
    ::continue::
end

function shared.GetVehClass(vehicle, server)
    local info
    if server then info = NetworkGetEntityFromNetworkId(vehicle) else info = vehicle end
    local model = GetEntityModel(info)
    if not sharedinfo[model] then return false end
    return sharedinfo[model].class
end

function shared.GetVehName(vehicle, server)
    local info
    if server then info = NetworkGetEntityFromNetworkId(vehicle) else info = vehicle end
    local model = GetEntityModel(info)
    -- print(json.encode(QBCore.Shared.Vehicles[string.lower(modelname)]))
    if not sharedinfo[model] then return false end
    return sharedinfo[model].name
end

function shared.ProgBarColor(number)
    if number > 60 then
        return 'lime'
    elseif number > 20 then
        return 'yellow'
    elseif number <= 20 then
        return 'red'
    end
end

return shared