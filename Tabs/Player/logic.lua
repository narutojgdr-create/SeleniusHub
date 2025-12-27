local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Logic = {}

function Logic.SetWalkSpeed(v)
    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = v
    end
end

function Logic.SetJumpPower(v)
    if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = v
    end
end

function Logic.Respawn()
    if LocalPlayer and LocalPlayer.Character then
        LocalPlayer.Character:BreakJoints()
    end
end

return Logic
