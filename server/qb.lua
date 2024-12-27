local qb = {}
local QBCore = exports['qb-core']:GetCoreObject()

function qb.Getjob(src)
    local info = QBCore.Functions.GetPlayer(src).PlayerData
    return {name = info.job.name, onduty = info.job.onduty, rank = info.job.grade.level}
end

function qb.RemoveMoney(src, type, amount)
    return QBCore.Functions.GetPlayer(src).Functions.RemoveMoney(type, amount)
end

function qb.GetCID(src)
    return QBCore.Functions.GetPlayer(src).PlayerData.citizenid
end

function qb.GetName(src)
    local Player = QBCore.Functions.GetPlayer(src)
    return Player.PlayerData.charinfo.firstname..' '.. Player.PlayerData.charinfo.lastname
end

return qb