local originalWindowTint
local function windowTint()
    originalWindowTint = GetVehicleWindowTint(vehicle)

    local windowTintLabels = {}
    for i, v in ipairs(Config.WindowTints) do
        windowTintLabels[i] = v.label
    end

    local option = {
        id = 'window_tint',
        label = 'Window Tint',
        close = true,
        values = windowTintLabels,
        set = function(index)
            SetVehicleWindowTint(vehicle, index - 1)
            return originalWindowTint == index - 1, ('%s windows installed'):format(windowTintLabels[index])
        end,
        restore = function()
            SetVehicleWindowTint(vehicle, originalWindowTint)
        end,
        defaultIndex = originalWindowTint + 1,
    }

    return option
end

return windowTint