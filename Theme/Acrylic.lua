-- Módulo Acrylic: glassmorphism (blur global + superfície translúcida)
-- Observação: Roblox não tem blur nativo por-Gui; usamos BlurEffect global

local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local Acrylic = {}

local BLUR_NAME = "SeleniusHub_AcrylicBlur"

local _state = {
	count = 0,
	blur = nil,
	tween = nil,
	destroyToken = 0,
	lastTarget = 0,
}

local function getThemeSafe(theme)
	if type(theme) == "table" then
		return theme
	end
	return {
		Background = Color3.fromRGB(14, 14, 20),
		Secondary = Color3.fromRGB(20, 20, 28),
		Stroke = Color3.fromRGB(48, 48, 70),
		BlurSize = 26,
	}
end

local function getOrCreateBlur()
	if _state.blur and _state.blur.Parent then
		return _state.blur
	end

	local existing = Lighting:FindFirstChild(BLUR_NAME)
	if existing and existing:IsA("BlurEffect") then
		_state.blur = existing
		return existing
	end

	local blur = Instance.new("BlurEffect")
	blur.Name = BLUR_NAME
	blur.Size = 0
	blur.Parent = Lighting
	_state.blur = blur
	return blur
end

local function tweenBlurTo(size)
	local blur = getOrCreateBlur()

	pcall(function()
		if _state.tween then
			_state.tween:Cancel()
		end
	end)

	local info = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	_state.tween = TweenService:Create(blur, info, { Size = size })
	_state.tween:Play()
end

local function setBlurEnabled(enabled, targetSize)
	if enabled then
		_state.count = _state.count + 1
	else
		_state.count = _state.count - 1
	end

	if _state.count < 0 then
		_state.count = 0
	end

	if _state.count > 0 then
		local desired = tonumber(targetSize)
		if not desired then
			desired = _state.lastTarget
		end
		if not desired or desired <= 0 then
			desired = 26
		end
		_state.lastTarget = desired
		tweenBlurTo(desired)
		return
	end

	-- Sem consumidores: anima de volta pra 0 e destrói depois
	tweenBlurTo(0)
	_state.destroyToken = _state.destroyToken + 1
	local token = _state.destroyToken
	task.delay(0.8, function()
		if _state.count ~= 0 then
			return
		end
		if token ~= _state.destroyToken then
			return
		end
		if _state.blur and _state.blur.Parent then
			pcall(function()
				_state.blur:Destroy()
			end)
		end
		_state.blur = nil
	end)
end

function Acrylic.Request(duration, blurSize)
	duration = tonumber(duration) or 0
	setBlurEnabled(true, blurSize)
	if duration > 0 then
		task.delay(duration, function()
			setBlurEnabled(false)
		end)
	end
end

function Acrylic.Stylize(frame, theme, instanceUtil, opts)
	if not (frame and frame.Parent) then
		return nil
	end

	theme = getThemeSafe(theme)
	opts = opts or {}

	frame.BackgroundColor3 = opts.BackgroundColor3 or theme.Background
	if opts.BackgroundTransparency ~= nil then
		frame.BackgroundTransparency = opts.BackgroundTransparency
	else
		-- Importante: manter sólido (sem "vazar" o mundo pela UI)
		frame.BackgroundTransparency = 0
	end

	local gradient = frame:FindFirstChild("AcrylicGradient")
	if not gradient then
		gradient = Instance.new("UIGradient")
		gradient.Name = "AcrylicGradient"
		gradient.Rotation = 60
		gradient.Parent = frame
	end

	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(245, 245, 255)),
	})
	-- Mantém o gradiente totalmente opaco (só efeito de cor/realce)
	gradient.Transparency = NumberSequence.new(0)

	local stroke = nil
	if opts.AddStroke and instanceUtil and instanceUtil.AddStroke then
		stroke = instanceUtil.AddStroke(
			frame,
			opts.StrokeColor3 or theme.Stroke,
			opts.StrokeThickness or 1.5,
			opts.StrokeTransparency or 0.6
		)
	end

	return stroke
end

function Acrylic.Enable(frame, theme, instanceUtil)
	theme = getThemeSafe(theme)

	local stroke = Acrylic.Stylize(frame, theme, instanceUtil, {
		BackgroundColor3 = theme.Background,
		BackgroundTransparency = 0,
		AddStroke = true,
		StrokeColor3 = theme.Stroke,
		StrokeThickness = 1.5,
		StrokeTransparency = 0.6,
	})

	local function updateBlur(visible, blurSize)
		if visible then
			setBlurEnabled(true, blurSize or theme.BlurSize or 26)
		else
			setBlurEnabled(false)
		end
	end

	return updateBlur, stroke
end

return Acrylic
