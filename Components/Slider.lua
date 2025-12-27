local UserInputService = game:GetService("UserInputService")

local Signal = require(script.Parent.Parent.Utils.Signal)
local Defaults = require(script.Parent.Parent.Assets.Defaults)

local Slider = {}

function Slider.Create(ctx, parent, position, localeKey, minValue, maxValue, defaultValue, size)
	local Theme = ctx.themeManager:GetTheme()
	local AnimConfig = Defaults.Tween.AnimConfig
	local SliderTween = Defaults.Tween.SliderTween

	minValue = minValue or 0
	maxValue = maxValue or 100
	defaultValue = math.clamp(defaultValue or minValue, minValue, maxValue)

	local frame = ctx.instanceUtil.Create("Frame", {
		BackgroundColor3 = Theme.Button,
		BackgroundTransparency = 0.3,
		Size = size or UDim2.new(0, 260, 0, 52),
		Position = position,
		Parent = parent,
	})
	ctx.instanceUtil.AddCorner(frame, 6)
	ctx.instanceUtil.AddStroke(frame, Theme.Stroke, 1, 0.5)

	local title = ctx.instanceUtil.Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, 4),
		Size = UDim2.new(0, 160, 0, 22),
		Font = Enum.Font.GothamMedium,
		TextSize = 18,
		TextColor3 = Theme.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = ctx.localeManager:GetText(localeKey),
		Parent = frame,
	})
	ctx.localeManager:Register(title, localeKey)
	ctx.themeManager:Register(title, "TextColor3", "TextPrimary")

	local valueLabel = ctx.instanceUtil.Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -60, 0, 4),
		Size = UDim2.new(0, 52, 0, 22),
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = Theme.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = tostring(math.floor(defaultValue + 0.5)),
		Parent = frame,
	})
	ctx.themeManager:Register(valueLabel, "TextColor3", "TextPrimary")

	local barBg = ctx.instanceUtil.Create("Frame", {
		BackgroundColor3 = Theme.IndicatorOff,
		Position = UDim2.new(0, 10, 0, 34),
		Size = UDim2.new(1, -20, 0, 6), -- [V2.0] Thinner
		Parent = frame,
	})
	ctx.instanceUtil.AddCorner(barBg, 3)

	local barFill = ctx.instanceUtil.Create("Frame", {
		BackgroundColor3 = Theme.Accent,
		Size = UDim2.new(0, 0, 1, 0),
		Parent = barBg,
	})
	ctx.instanceUtil.AddCorner(barFill, 3)

	local knob = ctx.instanceUtil.Create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(0, 16, 0, 16), -- [V2.0] Slightly larger
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Parent = barBg,
	})
	ctx.instanceUtil.AddCorner(knob, 8)

	local changed = Signal.new()
	local dragging = false
	local currentValue = defaultValue

	local function ApplyVisual(alpha)
		alpha = math.clamp(alpha, 0, 1)
		if dragging then
			barFill.Size = UDim2.new(alpha, 0, 1, 0)
			knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		else
			ctx.instanceUtil.Tween(barFill, SliderTween, { Size = UDim2.new(alpha, 0, 1, 0) })
			ctx.instanceUtil.Tween(knob, SliderTween, { Position = UDim2.new(alpha, 0, 0.5, 0) })
		end
	end

	local function SetValue(v, silent)
		v = math.clamp(v, minValue, maxValue)
		v = math.floor(v + 0.5)
		currentValue = v
		local alpha = (v - minValue) / (maxValue - minValue)
		ApplyVisual(alpha)
		valueLabel.Text = string.format("%d", v)
		if not silent then
			changed:Fire(currentValue)
		end
	end

	local function UpdateFromInput(input)
		local pos = input.Position.X
		local barPos = barBg.AbsolutePosition.X
		local barSize = barBg.AbsoluteSize.X
		if barSize <= 0 then
			return
		end
		local alpha = math.clamp((pos - barPos) / barSize, 0, 1)
		local v = minValue + (maxValue - minValue) * alpha
		SetValue(v)
	end

	ctx.addConnection(barBg.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			UpdateFromInput(input)
		end
	end)
	ctx.addConnection(UserInputService.InputChanged, function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			UpdateFromInput(input)
		end
	end)
	ctx.addConnection(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	task.defer(function()
		dragging = false
		SetValue(defaultValue, false)
	end)

	ctx.addConnection(frame.MouseEnter, function()
		Theme = ctx.themeManager:GetTheme()
		ctx.instanceUtil.Tween(frame, AnimConfig, { BackgroundColor3 = Theme.ButtonHover })
	end)
	ctx.addConnection(frame.MouseLeave, function()
		Theme = ctx.themeManager:GetTheme()
		ctx.instanceUtil.Tween(frame, AnimConfig, { BackgroundColor3 = Theme.Button })
	end)

	ctx.themeManager:AddCallback(function()
		Theme = ctx.themeManager:GetTheme()
		frame.BackgroundColor3 = Theme.Button
		title.TextColor3 = Theme.TextPrimary
		valueLabel.TextColor3 = Theme.TextPrimary
		barBg.BackgroundColor3 = Theme.IndicatorOff
		barFill.BackgroundColor3 = Theme.Accent
	end)

	ctx.registerSearchable(frame, localeKey)

	return {
		Frame = frame,
		Changed = changed,
		SetValue = function(v) SetValue(v, true) end,
		GetValue = function() return currentValue end,
	}
end

return Slider
