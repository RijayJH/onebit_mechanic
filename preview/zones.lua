local zoneId
local QBCore
local allowAccess = false
local saves = {}

if GetResourceState('qb-core') == 'started' then
    QBCore = exports['qb-core']:GetCoreObject()
end

CreateThread(function()
    for _, v in ipairs(Config.Zones) do
        lib.zones.poly({
            points = v.points,
            onEnter = function(s)
                zoneId = s.id
                if not cache.vehicle then return end
                local hasJob = true
                if v.job and QBCore then
                    hasJob = false
                    local playerJob = QBCore.Functions.GetPlayerData().job.name
                    for _, job in ipairs(v.job) do
                        if playerJob == job then
                            hasJob = true
                            break
                        end
                    end
                end

                allowAccess = hasJob
                if not hasJob then
                    return
                end

                lib.showTextUI('Press [E] to preview some tunes to you vehicle', {
                    icon = 'fa-solid fa-car',
                    position = 'left-center',
                })
            end,
            onExit = function()
                zoneId = nil
                lib.hideTextUI()
            end,
            inside = function()
                if IsControlJustPressed(0, 38) and cache.vehicle and allowAccess and cache.seat == -1 then
                    SetEntityVelocity(cache.vehicle, 0.0, 0.0, 0.0)
                    lib.hideTextUI()
                    require('preview.menus.main')()
                end
            end,
        })
    end
end)

lib.callback.register('onebit_mechanic:client:zone', function()
    return zoneId
end)

function AddSave(type, id)
    saves[type] = id
end

function GetSave(type)
    return saves[type]
end

function RemoveSave(type)
    saves[type] = nil
end

function ClearSave()
    saves = {}
end
