-- Módulo Acrylic v11.0 & NO Stroke System (Adaptado)

local Acrylic = {}

local function ensureCorner(target, radiusPx)
	local existing = target:FindFirstChildWhichIsA("UICorner")
	if existing then
		return existing
	end
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radiusPx or 8)
	corner.Parent = target
	return corner
end

local function ensureFrost(frame, theme, radiusPx)
	if frame:FindFirstChild("AcrylicFrost") then
		return
	end

	local frost = Instance.new("Frame")
	frost.Name = "AcrylicFrost"
	frost.BackgroundColor3 = Color3.new(1, 1, 1)
	frost.BackgroundTransparency = tonumber(theme and theme.AcrylicFrostTransparency) or 0.88
	frost.BorderSizePixel = 0
	frost.Size = UDim2.new(1, 0, 1, 0)
	frost.Position = UDim2.new(0, 0, 0, 0)
	frost.Active = false
	frost.ZIndex = frame.ZIndex
	frost.Parent = frame

	ensureCorner(frost, radiusPx)

	local frostGradient = Instance.new("UIGradient")
	frostGradient.Name = "AcrylicFrostGradient"
	frostGradient.Rotation = 35
	frostGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.new(0.90, 0.92, 1)),
	})
	frostGradient.Parent = frost
end

function Acrylic.Enable(frame, theme, instanceUtil, opts)
	opts = opts or {}

	frame.BackgroundTransparency = tonumber(theme and theme.AcrylicTransparency) or 0.10
	frame.BackgroundColor3 = theme.Background

	local corner = frame:FindFirstChildWhichIsA("UICorner")
	local radiusPx = 8
	if corner and corner.CornerRadius then
		radiusPx = corner.CornerRadius.Offset
	else
		ensureCorner(frame, radiusPx)
	end

	ensureFrost(frame, theme, radiusPx)

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

	if (not opts.NoStroke) and instanceUtil and instanceUtil.AddStroke then
		instanceUtil.AddStroke(frame, theme.Stroke, 1.5, 0)
	end

	local function updateBlur(_visible)
	end

	return updateBlur, nil
end

return Acrylic
