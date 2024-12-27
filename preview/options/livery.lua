local originalLivery = {}

local function livery()
    local newLiveryMethod = GetVehicleMod(vehicle, 48)

   
    originalLivery = {
        index = newLiveryMethod,
        old = false
    }

    local liveryLabels = {}
    liveryLabels[1] = 'Stock'
    for i = 0, GetNumVehicleMods(vehicle, 48) - 1 do
        liveryLabels[i + 2] = ('%s'):format(GetLabelText(GetModTextLabel(vehicle, 48, i)))
    end

    local option = {
        id = 'livery',
        label = 'Livery',
        close = true,
        values = liveryLabels,
        set = function(index)
            SetVehicleMod(vehicle, 48, index - 2, false)
            return originalLivery.index == index - 2, ('%s installed'):format(liveryLabels[index])
        end,
        restore = function()
            SetVehicleMod(vehicle, 48, originalLivery.index, false)
        end,
        defaultIndex = originalLivery.old and originalLivery.index + 1 or originalLivery.index + 2,
    }


    return option
end

return livery
