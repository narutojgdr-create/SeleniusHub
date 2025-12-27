local Logic = {}

function Logic.OnEspChanged(_state)
end

function Logic.OnEspColorChanged(color)
    print("Color Picked:", color)
end

function Logic.OnEspFeaturesChanged(list)
    print("Selected ESP:", table.concat(list, ", "))
end

return Logic
