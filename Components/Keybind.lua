local UserInputService = game:GetService("UserInputService")

local Signal = require(script.Parent.Parent.Utils.Signal)
local Defaults = require(script.Parent.Parent.Assets.Defaults)

local Keybind = {}

local function keyName(keyCode)
	if not keyCode then
		return "Nenhum"
	end
	if typeof(keyCode) == "EnumItem" then
		return keyCode.Name
	end
	return tostring(keyCode)
end

function Keybind.Create(ctx, parent, position, localeKey, defaultKeyCode)
	local Theme = ctx.themeManager:GetTheme()
	local AnimConfig = Defaults.Tween.AnimConfig
	local PopTween = Defaults.Tween.PopTween
	local PopReturnTween = Defaults.Tween.PopReturnTween

	local frame = ctx.instanceUtil.Create("Frame", {
		BackgroundColor3 = Theme.Button,
		BackgroundTransparency = 0.3,
		Size = UDim2.new(0, 260, 0, 40),
		Position = position,
		Parent = parent,
	})
	ctx.instanceUtil.AddCorner(frame, 6)
	ctx.instanceUtil.AddStroke(frame, Theme.Stroke, 1, 0.5)

	local title = ctx.instanceUtil.Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(0, 150, 1, 0),
		Font = Enum.Font.GothamMedium,
		TextSize = 18,
		TextColor3 = Theme.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = ctx.localeManager:GetText(localeKey),
		Parent = frame,
	})
	ctx.localeManager:Register(title, localeKey)
	ctx.themeManager:Register(title, "TextColor3", "TextPrimary")

	local btn = ctx.instanceUtil.Create("TextButton", {
		BackgroundColor3 = Theme.ButtonHover,
		Size = UDim2.new(0, 110, 0, 26),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = Theme.TextPrimary,
		Text = "[" .. keyName(defaultKeyCode) .. "]",
		AutoButtonColor = false,
		Parent = frame,
	})
	ctx.instanceUtil.AddCorner(btn, 13)
	ctx.themeManager:Register(btn, "TextColor3", "TextPrimary")

	local btnScale = Instance.new("UIScale")
	btnScale.Scale = 1
	btnScale.Parent = btn

	local changed = Signal.new()
	local capturing = false
	local currentKey = defaultKeyCode
	local captureConn = nil

	local function stopCapture()
		capturing = false
		if captureConn then
			captureConn:Disconnect()
			captureConn = nil
		end
		btn.Text = "[" .. keyName(currentKey) .. "]"
	end

	local function startCapture()
		if capturing then
			return
		end
		capturing = true
		btn.Text = "..."
		game:GetService("TweenService"):Create(btnScale, PopTween, { Scale = 1.15 }):Play()
		task.delay(PopTween.Time, function()
			game:GetService("TweenService"):Create(btnScale, PopReturnTween, { Scale = 1 }):Play()
		end)

		captureConn = UserInputService.InputBegan:Connect(function(input, gp)
			if gp or UserInputService:GetFocusedTextBox() then
				return
			end
			if input.UserInputType ~= Enum.UserInputType.Keyboard then
				return
			end
			if input.KeyCode == Enum.KeyCode.Unknown then
				return
			end
			currentKey = input.KeyCode
			changed:Fire(currentKey)
			stopCapture()
		end)
	end

	ctx.addConnection(btn.MouseButton1Click, function()
		startCapture()
	end)

	ctx.addConnection(btn.MouseEnter, function()
		Theme = ctx.themeManager:GetTheme()
		ctx.instanceUtil.Tween(btn, AnimConfig, { BackgroundColor3 = Theme.AccentDark })
	end)
	ctx.addConnection(btn.MouseLeave, function()
		Theme = ctx.themeManager:GetTheme()
		ctx.instanceUtil.Tween(btn, AnimConfig, { BackgroundColor3 = Theme.ButtonHover })
	end)

	ctx.themeManager:AddCallback(function()
		Theme = ctx.themeManager:GetTheme()
		frame.BackgroundColor3 = Theme.Button
		title.TextColor3 = Theme.TextPrimary
		btn.BackgroundColor3 = Theme.ButtonHover
		btn.TextColor3 = Theme.TextPrimary
	end)

	ctx.registerSearchable(frame, localeKey)

	return {
		Frame = frame,
		Changed = changed,
		SetKey = function(keyCode)
			currentKey = keyCode
			stopCapture()
		end,
		GetKey = function()
			return currentKey
		end,
	}
end

return Keybind
