local Logic = {}

function Logic.OnAimbotChanged(state)
    print("Aimbot:", state)
end

function Logic.OnSilentAimChanged(state)
    print("Silent:", state)
end

function Logic.OnFovChanged(value)
    print("FOV:", value)
end

function Logic.OnTargetPartChanged(opt)
    print("Target:", opt)
end

return Logic
