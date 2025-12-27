local Signal = require(script.Parent.Parent.Utils.Signal)
local Defaults = require(script.Parent.Parent.Assets.Defaults)

local Toggle = {}

function Toggle.Create(ctx, parent, position, localeKey, default, size)
	local Theme = ctx.themeManager:GetTheme()
	local AnimConfig = Defaults.Tween.AnimConfig

	local frame = ctx.instanceUtil.Create("TextButton", {
		BackgroundColor3 = Theme.Button,
		BackgroundTransparency = 0.3,
		Size = size or UDim2.new(0, 260, 0, 36),
		Position = position,
		AutoButtonColor = false,
		Text = "",
		Parent = parent,
	})
	ctx.instanceUtil.AddCorner(frame, 6)
	ctx.instanceUtil.AddStroke(frame, Theme.Stroke, 1, 0.5)

	local labelWidth = nil
	if size then
		local w = size.X.Offset or 260
		labelWidth = math.max(0, w - 80)
	end

	local title = ctx.instanceUtil.Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, 0),
		Size = labelWidth and UDim2.new(0, labelWidth, 1, 0) or UDim2.new(0, 180, 1, 0),
		Font = Enum.Font.GothamMedium,
		TextSize = 18,
		TextColor3 = Theme.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = ctx.localeManager:GetText(localeKey),
		Parent = frame,
	})
	ctx.localeManager:Register(title, localeKey)
	ctx.themeManager:Register(title, "TextColor3", "TextPrimary")

	local indicatorBg = ctx.instanceUtil.Create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 40, 0, 18),
		BackgroundColor3 = Theme.IndicatorOff,
		Parent = frame,
	})
	ctx.instanceUtil.AddCorner(indicatorBg, 9)

	local knob = ctx.instanceUtil.Create("Frame", {
		Size = UDim2.new(0, 18, 0, 18),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = indicatorBg,
	})
	ctx.instanceUtil.AddCorner(knob, 9)

	local changed = Signal.new()
	local state = default or false

	local function UpdateVisual()
		Theme = ctx.themeManager:GetTheme()
		if state then
			ctx.instanceUtil.Tween(indicatorBg, AnimConfig, { BackgroundColor3 = Theme.Accent })
			ctx.instanceUtil.Tween(knob, AnimConfig, { Position = UDim2.new(1, -18, 0, 0), BackgroundColor3 = Color3.new(1, 1, 1) })
		else
			ctx.instanceUtil.Tween(indicatorBg, AnimConfig, { BackgroundColor3 = Theme.IndicatorOff })
			ctx.instanceUtil.Tween(knob, AnimConfig, { Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Color3.new(1, 1, 1) })
		end
		frame.BackgroundColor3 = Theme.Button
		title.TextColor3 = Theme.TextPrimary
	end

	local function SetState(newState, silent)
		state = newState
		UpdateVisual()
		if not silent then
			changed:Fire(state)
		end
	end

	ctx.addConnection(frame.MouseButton1Click, function()
		SetState(not state)
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
		UpdateVisual()
	end)

	ctx.registerSearchable(frame, localeKey)
	UpdateVisual()

	return {
		Frame = frame,
		Changed = changed,
		SetState = function(v) SetState(v, true) end,
		GetState = function() return state end,
	}
end

return Toggle
