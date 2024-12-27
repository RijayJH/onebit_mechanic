local qb = {}
local QBCore = exports['qb-core']:GetCoreObject()
qb.QBCore = QBCore

function qb.GetJob()
    local info = QBCore.Functions.GetPlayerData()
    return {name = info.job.name, onduty = info.job.onduty, rank = info.job.grade.level}
end

function qb.GetPlate(vehicle)
    return QBCore.Functions.GetPlate(vehicle) or 'Not Found'
end

function qb.GetAccountMoney(type)
    return QBCore.Functions.GetPlayerData().money[type]
end

return qb

