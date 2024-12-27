local originalLivery = {}

local function oldlivery()
    local oldLiveryMethod = GetVehicleLivery(vehicle)

    originalLivery = {
        index = oldLiveryMethod,
        old = true
    }


    local liveryLabels = {}
    for i = 0, GetVehicleLiveryCount(vehicle) - 1 do
        liveryLabels[i + 1] = ('Livery %d'):format(i + 1)
    end


    local option = {
        id = 'oldlivery',
        label = 'Livery (Old)',
        close = true,
        values = liveryLabels,
        set = function(index)
            SetVehicleLivery(vehicle, index - 1)
            return originalLivery.index == index - 1, ('%s installed'):format(liveryLabels[index])
        end,
        restore = function()
            SetVehicleLivery(vehicle, originalLivery.index)
        end,
        defaultIndex = originalLivery.old and originalLivery.index + 1 or originalLivery.index + 2,
    }


    return option
end

return oldlivery