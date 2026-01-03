-- !!! ULTRA PROTEÇÃO !!!
local function safeRequire(mod)
	local ok, result = pcall(function() return require(mod) end)
	if ok and result then return result end
	return {}
end

local Signal = safeRequire(script.Parent.Parent.Utils.Signal)
local Defaults = safeRequire(script.Parent.Parent.Assets.Defaults)

local Checkbox = {}

function Checkbox.Create(ctx, parent, position, localeKey, default)
	local Theme = ctx.themeManager:GetTheme()
	local AnimConfig = Defaults.Tween.AnimConfig

	local frame = ctx.instanceUtil.Create("TextButton", {
		BackgroundColor3 = Theme.Button,
		BackgroundTransparency = tonumber(Theme.ControlTransparency) or 0.34,
		Size = UDim2.new(0, 260, 0, 32),
		Position = position,
		AutoButtonColor = false,
		Text = "",
		Parent = parent,
	})
	ctx.instanceUtil.AddCorner(frame, 6)
	ctx.instanceUtil.AddStroke(frame, Theme.Stroke, 1, 0.5)

	local box = ctx.instanceUtil.Create("Frame", {
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(0, 10, 0.5, -10),
		BackgroundColor3 = Theme.Secondary,
		Parent = frame,
	})
	ctx.instanceUtil.AddCorner(box, 4)
	ctx.instanceUtil.AddStroke(box, Theme.AccentDark, 1, 0.5)

	local check = ctx.instanceUtil.Create("ImageLabel", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(0.5, -8, 0.5, -8),
		BackgroundTransparency = 1,
		Image = "rbxassetid://6031094667",
		ImageColor3 = Theme.Secondary,
		ImageTransparency = 1,
		Parent = box,
	})

	local title = ctx.instanceUtil.Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 40, 0, 0),
		Size = UDim2.new(1, -50, 1, 0),
		Font = Enum.Font.GothamMedium,
		TextSize = 18,
		TextColor3 = Theme.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = ctx.localeManager:GetText(localeKey),
		Parent = frame,
	})
	ctx.localeManager:Register(title, localeKey)

	local changed = Signal.new()
	local state = default or false

	local function UpdateVisual()
		Theme = ctx.themeManager:GetTheme()
		if state then
			ctx.instanceUtil.Tween(check, AnimConfig, { ImageTransparency = 0 })
			ctx.instanceUtil.Tween(box, AnimConfig, { BackgroundColor3 = Theme.Accent })
		else
			ctx.instanceUtil.Tween(check, AnimConfig, { ImageTransparency = 1 })
			ctx.instanceUtil.Tween(box, AnimConfig, { BackgroundColor3 = Theme.Secondary })
		end
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

	ctx.themeManager:AddCallback(function()
		Theme = ctx.themeManager:GetTheme()
		frame.BackgroundColor3 = Theme.Button
		title.TextColor3 = Theme.TextPrimary
		check.ImageColor3 = Theme.Secondary
		if not state then
			box.BackgroundColor3 = Theme.Secondary
		else
			box.BackgroundColor3 = Theme.Accent
		end
	end)

	UpdateVisual()
	ctx.registerSearchable(frame, localeKey)

	return {
		Frame = frame,
		Changed = changed,
		SetState = function(v) SetState(v, true) end,
		GetState = function() return state end,
	}
end

return Checkbox
