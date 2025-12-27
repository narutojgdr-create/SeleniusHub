local Signal = require(script.Parent.Parent.Utils.Signal)
local Defaults = require(script.Parent.Parent.Assets.Defaults)

local Dropdown = {}

function Dropdown.Create(ctx, parent, position, localeKey, options, defaultIndex)
	options = options or {}
	defaultIndex = defaultIndex or 1
	if defaultIndex < 1 or defaultIndex > #options then
		defaultIndex = 1
	end

	local Theme = ctx.themeManager:GetTheme()
	local AnimConfig = Defaults.Tween.AnimConfig
	local DropdownTween = Defaults.Tween.DropdownTween

	local z = ctx.nextDropdownZ()

	local dropdownObj = {}
	local changed = Signal.new()

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

	local title = ctx.instanceUtil.Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(0, 120, 1, 0),
		Font = Enum.Font.GothamMedium,
		TextSize = 18,
		TextColor3 = Theme.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = ctx.localeManager:GetText(localeKey),
		Parent = frame,
		ZIndex = z + 1,
	})
	ctx.localeManager:Register(title, localeKey)
	ctx.themeManager:Register(title, "TextColor3", "TextPrimary")

	local currentLabel = ctx.instanceUtil.Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 130, 0, 0),
		Size = UDim2.new(0, 90, 1, 0),
		Font = Enum.Font.GothamMedium,
		TextSize = 18,
		TextColor3 = Theme.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = options[defaultIndex] or "",
		Parent = frame,
		ZIndex = z + 1,
	})
	ctx.themeManager:Register(currentLabel, "TextColor3", "TextPrimary")

	local arrow = ctx.instanceUtil.Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0.9, 0, 0, 0),
		Size = UDim2.new(0.1, -4, 1, 0),
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = Theme.TextPrimary,
		Text = "▼",
		Rotation = 0,
		Parent = frame,
		ZIndex = z + 1,
	})
	ctx.themeManager:Register(arrow, "TextColor3", "TextPrimary")

	local clickArea = ctx.instanceUtil.Create("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		AutoButtonColor = false,
		Parent = frame,
		ZIndex = z + 2,
	})

	local listHeight = (#options * 26) + 6
	local listFrame = ctx.instanceUtil.Create("Frame", {
		BackgroundColor3 = Theme.Secondary,
		Position = UDim2.new(0, 0, 1, 2),
		Size = UDim2.new(1, 0, 0, 0),
		Visible = false,
		ClipsDescendants = true,
		Parent = frame,
		ZIndex = z + 5,
	})
	ctx.instanceUtil.AddCorner(listFrame, 6)
	ctx.instanceUtil.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = listFrame,
	})

	local selectedIndex = defaultIndex
	local isOpen = false
	dropdownObj.optionButtons = {}

	local function CloseDropdown()
		isOpen = false
		ctx.instanceUtil.Tween(listFrame, DropdownTween, { Size = UDim2.new(1, 0, 0, 0) })
		Theme = ctx.themeManager:GetTheme()
		ctx.instanceUtil.Tween(arrow, DropdownTween, { Rotation = 0, TextColor3 = Theme.TextPrimary })
		arrow.Text = "▼"
		task.delay(DropdownTween.Time, function()
			if not isOpen then
				listFrame.Visible = false
			end
		end)
	end

	local function OpenDropdown()
		isOpen = true
		if not listFrame.Visible then
			listFrame.Size = UDim2.new(1, 0, 0, 0)
			listFrame.Visible = true
		end
		ctx.instanceUtil.Tween(listFrame, DropdownTween, { Size = UDim2.new(1, 0, 0, listHeight) })
		Theme = ctx.themeManager:GetTheme()
		ctx.instanceUtil.Tween(arrow, DropdownTween, { Rotation = 180, TextColor3 = Theme.Accent })
		arrow.Text = "▲"
	end

	local function SelectOption(idx)
		selectedIndex = idx
		currentLabel.Text = options[idx] or ""
		changed:Fire(currentLabel.Text, idx)
		CloseDropdown()
	end

	function dropdownObj:UpdateOptions(newOptions)
		for _, btn in ipairs(dropdownObj.optionButtons) do
			btn:Destroy()
		end
		dropdownObj.optionButtons = {}
		options = newOptions or {}
		listHeight = (#options * 26) + 6

		for i, opt in ipairs(options) do
			local optBtn = ctx.instanceUtil.Create("TextButton", {
				BackgroundColor3 = Theme.Button,
				Size = UDim2.new(1, 0, 0, 24),
				Text = opt,
				Font = Enum.Font.GothamMedium,
				TextSize = 16,
				TextColor3 = Theme.AccentDark,
				AutoButtonColor = false,
				Parent = listFrame,
				ZIndex = z + 6,
			})
			ctx.instanceUtil.AddCorner(optBtn, 4)
			optBtn.MouseEnter:Connect(function()
				Theme = ctx.themeManager:GetTheme()
				ctx.instanceUtil.Tween(optBtn, AnimConfig, { BackgroundColor3 = Theme.ButtonHover, TextColor3 = Theme.TextPrimary })
			end)
			optBtn.MouseLeave:Connect(function()
				Theme = ctx.themeManager:GetTheme()
				ctx.instanceUtil.Tween(optBtn, AnimConfig, { BackgroundColor3 = Theme.Button, TextColor3 = Theme.AccentDark })
			end)
			optBtn.MouseButton1Click:Connect(function()
				SelectOption(i)
			end)
			dropdownObj.optionButtons[i] = optBtn
		end

		if selectedIndex > #options then
			selectedIndex = 1
			currentLabel.Text = options[1] or ""
		end
	end

	dropdownObj:UpdateOptions(options)

	ctx.addConnection(clickArea.MouseButton1Click, function()
		if isOpen then
			CloseDropdown()
		else
			OpenDropdown()
		end
	end)

	ctx.themeManager:AddCallback(function()
		Theme = ctx.themeManager:GetTheme()
		frame.BackgroundColor3 = Theme.Button
		title.TextColor3 = Theme.TextPrimary
		currentLabel.TextColor3 = Theme.TextPrimary
		arrow.TextColor3 = Theme.TextPrimary
		listFrame.BackgroundColor3 = Theme.Secondary
		for _, btn in ipairs(dropdownObj.optionButtons) do
			btn.BackgroundColor3 = Theme.Button
		end
	end)

	ctx.registerSearchable(frame, localeKey)

	return {
		Frame = frame,
		Changed = changed,
		UpdateOptions = function(newOptions) dropdownObj:UpdateOptions(newOptions) end,
		currentLabel = currentLabel,
		optionButtons = dropdownObj.optionButtons,
	}
end

return Dropdown
