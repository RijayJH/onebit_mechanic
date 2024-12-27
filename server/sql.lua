local sql = {}


function sql.IsVehicleOwned(plate)
    local result = MySQL.scalar.await('SELECT 1 from player_vehicles WHERE plate = ?', {plate})
    if result then
        return true
    else
        return false
    end
end

function sql.UpdateMods(vehicleProps, plate)
    MySQL.update('UPDATE player_vehicles SET mods = ? WHERE plate = ?', {json.encode(vehicleProps), plate})
end

return sql