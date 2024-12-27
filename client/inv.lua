local inv = {}
local ox_inventory = exports.ox_inventory

function inv.GetSlot(name, slot)
    local info
    local search = ox_inventory:Search('slots', name)
    if next(search) == nil then return end
    for _, v in pairs(search) do
        if v.slot == slot then
            info = v
            break
        end
    end
    return info
end


return inv