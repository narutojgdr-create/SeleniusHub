-- Módulo Acrylic v11.0 & NO Stroke System (Adaptado)

local Acrylic = {}

function Acrylic.Enable(frame, theme, instanceUtil)
	frame.BackgroundTransparency = 0.05
	frame.BackgroundColor3 = theme.Background

	local gradient = Instance.new("UIGradient")
	gradient.Rotation = 60
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(0.98, 0.98, 0.99)),
	})
	gradient.Parent = frame

	if instanceUtil and instanceUtil.AddStroke then
		instanceUtil.AddStroke(frame, theme.Stroke, 1.5, 0)
	end

	local function updateBlur(_visible)
	end

	return updateBlur, nil
end

return Acrylic
