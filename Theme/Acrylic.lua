-- Módulo Acrylic v11.0 & NO Stroke System (Adaptado)

local Lighting = game:GetService("Lighting")

local Acrylic = {}

pcall(function()
	local old = Lighting:FindFirstChild("SeleniusHub_Blur")
	if old and old:IsA("BlurEffect") then
		old.Enabled = false
		old.Size = 0
		old:Destroy()
	end
end)

function Acrylic.Enable(frame, theme, instanceUtil)
	frame.BackgroundTransparency = tonumber(theme and theme.AcrylicTransparency) or 0.10
	frame.BackgroundColor3 = theme.Background

	pcall(function()
		local oldFrost = frame:FindFirstChild("AcrylicFrost")
		if oldFrost then
			oldFrost:Destroy()
		end
	end)

	if not frame:FindFirstChild("AcrylicGradient") then
		local gradient = Instance.new("UIGradient")
		gradient.Name = "AcrylicGradient"
		gradient.Rotation = 60
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(0.98, 0.98, 0.99)),
		})
		gradient.Parent = frame
	end

	if instanceUtil and instanceUtil.AddStroke then
		instanceUtil.AddStroke(frame, theme.Stroke, 1.5, 0)
	end

	local function updateBlur(visible)
		-- Sem blur global: mantemos UI funcional sem afetar a tela inteira.
	end

	return updateBlur, nil
end

return Acrylic
