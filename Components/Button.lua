local Signal = require(script.Parent.Parent.Utils.Signal)
local Defaults = require(script.Parent.Parent.Assets.Defaults)

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

	local title = ctx.instanceUtil.Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.GothamMedium,
		TextSize = 18,
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
