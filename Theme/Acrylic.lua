-- Módulo Acrylic v11.0 & NO Stroke System (Adaptado)

local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local Acrylic = {}

local BLUR_NAME = "SeleniusHub_Blur"
local _blurUsers = 0
local _blurTween = nil

local function getOrCreateBlur()
	local blur = Lighting:FindFirstChild(BLUR_NAME)
	if blur and blur:IsA("BlurEffect") then
		return blur
	end
	blur = Instance.new("BlurEffect")
	blur.Name = BLUR_NAME
	blur.Size = 0
	blur.Enabled = false
	blur.Parent = Lighting
	return blur
end

function Acrylic.RequestBlur(visible, theme)
	if visible then
		_blurUsers = _blurUsers + 1
	else
		_blurUsers = math.max(0, _blurUsers - 1)
	end

	local blur = getOrCreateBlur()
	local targetSize = tonumber(theme and theme.BlurSize) or 18

	if _blurTween then
		pcall(function()
			_blurTween:Cancel()
		end)
		_blurTween = nil
	end

	if _blurUsers > 0 then
		blur.Enabled = true
		_blurTween = TweenService:Create(blur, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = targetSize,
		})
		_blurTween:Play()
	else
		_blurTween = TweenService:Create(blur, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = 0,
		})
		_blurTween:Play()
		task.delay(0.24, function()
			if _blurUsers == 0 and blur and blur.Parent then
				blur.Enabled = false
			end
		end)
	end
end

function Acrylic.Enable(frame, theme, instanceUtil)
	frame.BackgroundTransparency = tonumber(theme and theme.AcrylicTransparency) or 0.10
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
		Acrylic.RequestBlur(_visible, theme)
	end

	return updateBlur, nil
end

return Acrylic
