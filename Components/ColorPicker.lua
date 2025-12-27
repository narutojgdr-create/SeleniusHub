local UserInputService = game:GetService("UserInputService")

local Signal = require(script.Parent.Parent.Utils.Signal)
local Defaults = require(script.Parent.Parent.Assets.Defaults)

local ColorPicker = {}

function ColorPicker.Create(ctx, parent, position, localeKey, default)
	local Theme = ctx.themeManager:GetTheme()
	local DropdownTween = Defaults.Tween.DropdownTween

	local z = ctx.nextDropdownZ()

	local frame = ctx.instanceUtil.Create("Frame", {
		BackgroundColor3 = Theme.Button,
		BackgroundTransparency = 0.3,
		Size = UDim2.new(0, 260, 0, 36),
		Position = position,
		Parent = parent,
		ZIndex = z,
	})
	ctx.instanceUtil.AddCorner(frame, 6)
	ctx.instanceUtil.AddStroke(frame, Theme.Stroke, 1, 0.5)
	ctx.themeManager:Register(frame, "BackgroundColor3", "Button")

	local lbl = ctx.instanceUtil.Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(1, -50, 1, 0),
		Font = Enum.Font.GothamMedium,
		TextSize = 18,
		TextColor3 = Theme.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = ctx.localeManager:GetText(localeKey),
		Parent = frame,
		ZIndex = z + 1,
	})
	ctx.localeManager:Register(lbl, localeKey)
	ctx.themeManager:Register(lbl, "TextColor3", "TextPrimary")

	local currentColor = default or Color3.fromRGB(255, 255, 255)
	local prev = ctx.instanceUtil.Create("TextButton", {
		BackgroundColor3 = currentColor,
		Size = UDim2.new(0, 30, 0, 20),
		Position = UDim2.new(1, -40, 0.5, -10),
		Text = "",
		AutoButtonColor = false,
		Parent = frame,
		ZIndex = z + 1,
	})
	ctx.instanceUtil.AddCorner(prev, 4)
	ctx.instanceUtil.AddStroke(prev, Theme.Stroke, 1, 0.5)

	local pickerFrame = ctx.instanceUtil.Create("Frame", {
		BackgroundColor3 = Theme.Secondary,
		Position = UDim2.new(0, 0, 1, 2),
		Size = UDim2.new(1, 0, 0, 0),
		Visible = false,
		Parent = frame,
		ZIndex = z + 5,
		ClipsDescendants = true,
	})
	ctx.instanceUtil.AddCorner(pickerFrame, 6)
	ctx.instanceUtil.AddStroke(pickerFrame, Theme.Stroke, 1, 0.5)

	local pickerContent = ctx.instanceUtil.Create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = pickerFrame,
		Visible = false,
	})

	local svMap = ctx.instanceUtil.Create("ImageButton", {
		Size = UDim2.new(0, 240, 0, 120),
		Position = UDim2.new(0, 10, 0, 10),
		BackgroundColor3 = Color3.fromHSV(1, 1, 1),
		Image = "rbxassetid://4155801252",
		AutoButtonColor = false,
		Parent = pickerContent,
		ZIndex = z + 6,
	})

	local svKnob = ctx.instanceUtil.Create("Frame", {
		Size = UDim2.new(0, 10, 0, 10),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0,
		Parent = svMap,
		ZIndex = z + 7,
	})
	ctx.instanceUtil.AddCorner(svKnob, 10)

	local hueBar = ctx.instanceUtil.Create("ImageButton", {
		Size = UDim2.new(0, 240, 0, 15),
		Position = UDim2.new(0, 10, 0, 140),
		BackgroundColor3 = Color3.new(1, 1, 1),
		AutoButtonColor = false,
		Parent = pickerContent,
		ZIndex = z + 6,
	})
	local hueGradient = Instance.new("UIGradient")
	hueGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
	})
	hueGradient.Parent = hueBar

	local hueKnob = ctx.instanceUtil.Create("Frame", {
		Size = UDim2.new(0, 6, 1, 4),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = hueBar,
		ZIndex = z + 7,
	})
	ctx.instanceUtil.AddCorner(hueKnob, 4)

	local rgbBox = ctx.instanceUtil.Create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 165),
		Size = UDim2.new(0, 240, 0, 25),
		Parent = pickerContent,
		ZIndex = z + 6,
	})

	local rInput = ctx.instanceUtil.Create("TextBox", {
		BackgroundColor3 = Theme.Button,
		Size = UDim2.new(0, 70, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		Text = math.floor(currentColor.R * 255),
		TextColor3 = Theme.TextPrimary,
		Parent = rgbBox,
		ZIndex = z + 7,
	})
	ctx.instanceUtil.AddCorner(rInput, 4)
	ctx.instanceUtil.AddStroke(rInput, Theme.Stroke, 1, 0.5)

	local gInput = ctx.instanceUtil.Create("TextBox", {
		BackgroundColor3 = Theme.Button,
		Size = UDim2.new(0, 70, 1, 0),
		Position = UDim2.new(0.5, -35, 0, 0),
		Text = math.floor(currentColor.G * 255),
		TextColor3 = Theme.TextPrimary,
		Parent = rgbBox,
		ZIndex = z + 7,
	})
	ctx.instanceUtil.AddCorner(gInput, 4)
	ctx.instanceUtil.AddStroke(gInput, Theme.Stroke, 1, 0.5)

	local bInput = ctx.instanceUtil.Create("TextBox", {
		BackgroundColor3 = Theme.Button,
		Size = UDim2.new(0, 70, 1, 0),
		Position = UDim2.new(1, -70, 0, 0),
		Text = math.floor(currentColor.B * 255),
		TextColor3 = Theme.TextPrimary,
		Parent = rgbBox,
		ZIndex = z + 7,
	})
	ctx.instanceUtil.AddCorner(bInput, 4)
	ctx.instanceUtil.AddStroke(bInput, Theme.Stroke, 1, 0.5)

	local h, s, v = Color3.toHSV(currentColor)
	local draggingHue, draggingSV = false, false

	local changed = Signal.new()

	local function UpdateVisuals()
		svKnob.Position = UDim2.new(s, 0, 1 - v, 0)
		hueKnob.Position = UDim2.new(1 - h, 0, 0.5, 0)

		svMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		prev.BackgroundColor3 = currentColor

		if not rInput:IsFocused() then
			rInput.Text = math.floor(currentColor.R * 255)
		end
		if not gInput:IsFocused() then
			gInput.Text = math.floor(currentColor.G * 255)
		end
		if not bInput:IsFocused() then
			bInput.Text = math.floor(currentColor.B * 255)
		end
	end

	local function UpdateColor(silent)
		currentColor = Color3.fromHSV(h, s, v)
		UpdateVisuals()
		if not silent then
			changed:Fire(currentColor)
		end
	end

	UpdateVisuals()

	local function UpdateSV(input)
		local rPos = input.Position.X - svMap.AbsolutePosition.X
		local rPosY = input.Position.Y - svMap.AbsolutePosition.Y
		s = math.clamp(rPos / svMap.AbsoluteSize.X, 0, 1)
		v = 1 - math.clamp(rPosY / svMap.AbsoluteSize.Y, 0, 1)
		UpdateColor(false)
	end

	local function UpdateHue(input)
		local rPos = input.Position.X - hueBar.AbsolutePosition.X
		h = 1 - math.clamp(rPos / hueBar.AbsoluteSize.X, 0, 1)
		UpdateColor(false)
	end

	svMap.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSV = true
			UpdateSV(input)
		end
	end)
	hueBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingHue = true
			UpdateHue(input)
		end
	end)

	ctx.addConnection(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSV = false
			draggingHue = false
		end
	end)
	ctx.addConnection(UserInputService.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			if draggingSV then
				UpdateSV(input)
			end
			if draggingHue then
				UpdateHue(input)
			end
		end
	end)

	local function ManualUpdate()
		local r = tonumber(rInput.Text) or 0
		local g = tonumber(gInput.Text) or 0
		local b = tonumber(bInput.Text) or 0
		currentColor = Color3.fromRGB(math.clamp(r, 0, 255), math.clamp(g, 0, 255), math.clamp(b, 0, 255))
		h, s, v = Color3.toHSV(currentColor)
		UpdateColor(false)
	end
	rInput.FocusLost:Connect(ManualUpdate)
	gInput.FocusLost:Connect(ManualUpdate)
	bInput.FocusLost:Connect(ManualUpdate)

	local open = false
	prev.MouseButton1Click:Connect(function()
		open = not open
		pickerFrame.Visible = true
		pickerContent.Visible = open
		ctx.instanceUtil.Tween(pickerFrame, DropdownTween, { Size = UDim2.new(1, 0, 0, open and 200 or 0) })
	end)

	ctx.registerSearchable(frame, localeKey)

	return {
		Frame = frame,
		Changed = changed,
		SetColor = function(c)
			currentColor = c
			h, s, v = Color3.toHSV(c)
			UpdateColor(true)
		end,
		GetColor = function() return currentColor end,
	}
end

return ColorPicker
