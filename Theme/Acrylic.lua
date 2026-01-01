-- Acrylic (Glass): blur LOCALIZADO no fundo do Frame, sem BlurEffect global.
-- Implementação via GlassmorphicUI (EditableImage) -> efeito só dentro da UI.

local Acrylic = {}

local GlassmorphicUI = require(script.Parent.Parent.ThirdParty.GlassmorphicUI.init)

local clamp = math.clamp
if type(clamp) ~= "function" then
	clamp = function(x, minValue, maxValue)
		if x < minValue then
			return minValue
		end
		if x > maxValue then
			return maxValue
		end
		return x
	end
end

local _state = {
	activeCount = 0,
	glassWindows = setmetatable({}, { __mode = "k" }),
	initialized = false,
}

local function getThemeSafe(theme)
	if type(theme) == "table" then
		return theme
	end
	return {
		Background = Color3.fromRGB(14, 14, 20),
		Secondary = Color3.fromRGB(20, 20, 28),
		Stroke = Color3.fromRGB(48, 48, 70),
		-- GlassmorphicUI
		GlassBlurRadius = 6,
		GlassTransparency = 0.18,
	}
end

local function ensureInitialized()
	if _state.initialized then
		return
	end
	_state.initialized = true
	pcall(function()
		-- Default leve. Cada janela pode sobrescrever com atributo BlurRadius.
		GlassmorphicUI.setDefaultBlurRadius(6)
	end)
end

local function registerGlassWindow(window)
	_state.glassWindows[window] = true
	if _state.activeCount > 0 then
		pcall(function()
			GlassmorphicUI.resumeUpdates(window)
		end)
	else
		pcall(function()
			GlassmorphicUI.pauseUpdates(window)
		end)
	end
end

local function setActive(active)
	if active then
		_state.activeCount = _state.activeCount + 1
	else
		_state.activeCount = _state.activeCount - 1
	end
	if _state.activeCount < 0 then
		_state.activeCount = 0
	end

	for window in pairs(_state.glassWindows) do
		if window and window.Parent then
			pcall(function()
				if _state.activeCount > 0 then
					GlassmorphicUI.resumeUpdates(window)
				else
					GlassmorphicUI.pauseUpdates(window)
				end
			end)
		end
	end
end

function Acrylic.Stylize(frame, theme, instanceUtil, opts)
	if not (frame and frame.Parent) then
		return nil
	end
	ensureInitialized()
	theme = getThemeSafe(theme)
	opts = opts or {}

	-- O blur é renderizado no ImageLabel interno; o frame host precisa ficar transparente.
	pcall(function()
		frame.BackgroundTransparency = 1
	end)

	-- GlassmorphicUI precisa que o Frame seja transparente, e o "fundo" vira um ImageLabel interno.
	local glass = frame:FindFirstChild("GlassBackground")
	if not (glass and glass:IsA("ImageLabel")) then
		glass = GlassmorphicUI.addGlassBackground(frame)
		glass.Name = "GlassBackground"
		registerGlassWindow(glass)
	end

	glass.BackgroundColor3 = opts.BackgroundColor3 or theme.Background
	local glassTransparency = opts.GlassTransparency
	if glassTransparency == nil then
		glassTransparency = theme.GlassTransparency
	end
	glass.BackgroundTransparency = clamp(tonumber(glassTransparency) or 0.18, 0, 0.95)

	local blurRadius = opts.BlurRadius
	if blurRadius == nil then
		blurRadius = theme.GlassBlurRadius
	end
	blurRadius = tonumber(blurRadius) or 6
	glass:SetAttribute("BlurRadius", blurRadius)

	-- Copia corner do frame pra não "vazar" quadrado dentro
	local corner = frame:FindFirstChildWhichIsA("UICorner")
	if corner and not glass:FindFirstChildWhichIsA("UICorner") then
		local c = Instance.new("UICorner")
		c.CornerRadius = corner.CornerRadius
		c.Parent = glass
	end

	-- Pequeno realce de luz, sem mudar cor base
	local gradient = glass:FindFirstChild("AcrylicGradient")
	if not gradient then
		gradient = Instance.new("UIGradient")
		gradient.Name = "AcrylicGradient"
		gradient.Rotation = 60
		gradient.Parent = glass
	end
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(230, 235, 255)),
	})
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.75),
		NumberSequenceKeypoint.new(1, 0.95),
	})

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
	ensureInitialized()

	local stroke = Acrylic.Stylize(frame, theme, instanceUtil, {
		BackgroundColor3 = theme.Background,
		GlassTransparency = theme.GlassTransparency,
		BlurRadius = theme.GlassBlurRadius,
		AddStroke = true,
		StrokeColor3 = theme.Stroke,
		StrokeThickness = 1.5,
		StrokeTransparency = 0.6,
	})

	local function updateBlur(visible, _)
		-- Mantém assinatura compatível com Hub (true/false)
		setActive(visible and true or false)
	end

	return updateBlur, stroke
end

return Acrylic
