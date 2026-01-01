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

local function getQualityLevel()
	local okSettings, q = pcall(function()
		return settings().Rendering.QualityLevel
	end)
	if okSettings and typeof(q) == "EnumItem" then
		if q == Enum.QualityLevel.Automatic then
			return nil, true
		end
		local n = tonumber((q.Name or ""):match("Level(%d+)$"))
		if n then
			return n, false
		end
	end

	local okUGS, ugs = pcall(function()
		return UserSettings():GetService("UserGameSettings")
	end)
	if okUGS and ugs then
		local saved = ugs.SavedQualityLevel
		if typeof(saved) == "EnumItem" and saved == Enum.SavedQualitySetting.Automatic then
			return nil, true
		end
		if typeof(saved) == "EnumItem" then
			local n = tonumber((saved.Name or ""):match("QualityLevel(%d+)$"))
			if n then
				return n, false
			end
		end
	end

	return nil, true
end

local function canUseRobloxBlur(theme)
	local minQ = tonumber(theme and theme.BlurMinQuality) or 7
	local allowAuto = (theme and theme.BlurAllowAutomatic) == true
	local level, isAuto = getQualityLevel()
	if isAuto then
		return allowAuto
	end
	return level ~= nil and level >= minQ
end

function Acrylic.RequestBlur(visible, theme)
	if visible then
		_blurUsers = _blurUsers + 1
	else
		_blurUsers = math.max(0, _blurUsers - 1)
	end

	local blur = getOrCreateBlur()
	local targetSize = tonumber(theme and theme.BlurSize) or 18
	local shouldEnable = (_blurUsers > 0) and canUseRobloxBlur(theme)

	if _blurTween then
		pcall(function()
			_blurTween:Cancel()
		end)
		_blurTween = nil
	end

	if shouldEnable then
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
			if blur and blur.Parent and (_blurUsers == 0 or not canUseRobloxBlur(theme)) then
				blur.Enabled = false
			end
		end)
	end
end

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
		Acrylic.RequestBlur(visible, theme)
	end

	return updateBlur, nil
end

return Acrylic
