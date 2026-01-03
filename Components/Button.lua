-- !!! ULTRA PROTEÇÃO !!!
local function safeRequire(mod)
	local ok, result = pcall(function() return require(mod) end)
	if ok and result then return result end
	return {}
end

local Signal = safeRequire(script.Parent.Parent.Utils.Signal)
local Defaults = safeRequire(script.Parent.Parent.Assets.Defaults)

local Button = {}

function Button.Create(ctx, parent, position, localeKey)
	local Theme = ctx.themeManager:GetTheme()
	local AnimConfig = Defaults.Tween.AnimConfig

	local frame = ctx.instanceUtil.Create("TextButton", {
		BackgroundColor3 = Theme.Button,
		Size = UDim2.new(0, 260, 0, 36),
		Position = position,
		AutoButtonColor = false,
		Text = "",
		Parent = parent,
	})
	ctx.instanceUtil.AddCorner(frame, 6)
	ctx.instanceUtil.AddStroke(frame, Theme.Stroke, 1, 0.5) -- [V2.0]

	local title = ctx.instanceUtil.Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = Theme.TextPrimary,
		Text = ctx.localeManager:GetText(localeKey),
		Parent = frame,
	})
	ctx.localeManager:Register(title, localeKey)
	ctx.themeManager:Register(title, "TextColor3", "TextPrimary")

	local clicked = Signal.new()

	ctx.addConnection(frame.MouseButton1Click, function()
		clicked:Fire()
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
	end)

	ctx.registerSearchable(frame, localeKey)

	return {
		Frame = frame,
		Clicked = clicked,
	}
end

return Button
