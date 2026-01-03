-- !!! ULTRA PROTEÇÃO !!!
local function safeRequire(mod)
	local ok, result = pcall(function() return require(mod) end)
	if ok and result then return result end
	return {}
end

local Signal = safeRequire(script.Parent.Parent.Utils.Signal)
local Defaults = safeRequire(script.Parent.Parent.Assets.Defaults)

local MultiDropdown = {}

function MultiDropdown.Create(ctx, parent, position, localeKey, options, defaultList)
	local Theme = ctx.themeManager:GetTheme()
	local DropdownTween = Defaults.Tween.DropdownTween

	local z = ctx.nextDropdownZ()

	local frame = ctx.instanceUtil.Create("Frame", {
		BackgroundColor3 = Theme.Button,
		BackgroundTransparency = tonumber(Theme.ControlTransparency) or 0.34,
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
		Size = UDim2.new(0, 100, 1, 0),
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

	local disp = ctx.instanceUtil.Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 110, 0, 0),
		Size = UDim2.new(1, -120, 1, 0),
		Font = Enum.Font.GothamMedium,
		TextSize = 16,
		TextColor3 = Theme.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Right,
		Text = "...",
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = frame,
		ZIndex = z + 1,
	})
	ctx.themeManager:Register(disp, "TextColor3", "TextPrimary")

	local btn = ctx.instanceUtil.Create("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "",
		Parent = frame,
		ZIndex = z + 2,
	})

	local listFrame = ctx.instanceUtil.Create("Frame", {
		BackgroundColor3 = Theme.Secondary,
		Position = UDim2.new(0, 0, 1, 2),
		Size = UDim2.new(1, 0, 0, 0),
		Visible = false,
		Parent = frame,
		ZIndex = z + 5,
		ClipsDescendants = true,
	})
	ctx.instanceUtil.AddCorner(listFrame, 6)
	ctx.instanceUtil.Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = listFrame,
	})
	ctx.instanceUtil.Create("UIPadding", {
		PaddingTop = UDim.new(0, 2),
		PaddingBottom = UDim.new(0, 2),
		Parent = listFrame,
	})

	local selected = {}
	for _, v in ipairs(defaultList or {}) do
		selected[v] = true
	end

	local changed = Signal.new()

	local function Snapshot()
		local t = {}
		for k, v in pairs(selected) do
			if v then
				table.insert(t, k)
			end
		end
		return t
	end

	local function UpdateText(fire)
		local t = Snapshot()
		disp.Text = #t > 0 and table.concat(t, ", ") or "None"
		if fire then
			changed:Fire(t)
		end
	end
	UpdateText(true)

	local open = false
	ctx.addConnection(btn.MouseButton1Click, function()
		open = not open
		listFrame.Visible = true
		ctx.instanceUtil.Tween(listFrame, DropdownTween, { Size = UDim2.new(1, 0, 0, open and (#options * 26 + 6) or 0) })
	end)

	for _, opt in ipairs(options or {}) do
		local optBtn = ctx.instanceUtil.Create("TextButton", {
			BackgroundColor3 = Theme.Button,
			Size = UDim2.new(1, -4, 0, 24),
			Text = "",
			Parent = listFrame,
			ZIndex = z + 6,
		})
		ctx.instanceUtil.AddCorner(optBtn, 4)

		local box = ctx.instanceUtil.Create("Frame", {
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(0, 4, 0.5, -8),
			BackgroundColor3 = selected[opt] and Theme.Accent or Theme.Secondary,
			Parent = optBtn,
			ZIndex = z + 7,
		})
		ctx.instanceUtil.AddCorner(box, 4)

		local check = ctx.instanceUtil.Create("ImageLabel", {
			Size = UDim2.new(0, 12, 0, 12),
			Position = UDim2.new(0.5, -6, 0.5, -6),
			BackgroundTransparency = 1,
			Image = "rbxassetid://6031094667",
			ImageColor3 = Theme.Secondary,
			ImageTransparency = selected[opt] and 0 or 1,
			Parent = box,
			ZIndex = z + 8,
		})

		local optLabel = ctx.instanceUtil.Create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 28, 0, 0),
			Size = UDim2.new(1, -28, 1, 0),
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextColor3 = selected[opt] and Theme.Accent or Theme.AccentDark,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = opt,
			Parent = optBtn,
			ZIndex = z + 7,
		})

		ctx.addConnection(optBtn.MouseButton1Click, function()
			Theme = ctx.themeManager:GetTheme()
			selected[opt] = not selected[opt]
			optLabel.TextColor3 = selected[opt] and Theme.Accent or Theme.AccentDark
			box.BackgroundColor3 = selected[opt] and Theme.Accent or Theme.Secondary
			check.ImageTransparency = selected[opt] and 0 or 1
			UpdateText(true)
		end)
	end

	ctx.registerSearchable(frame, localeKey)

	return {
		Frame = frame,
		Changed = changed,
		GetSelection = function() return selected end,
	}
end

return MultiDropdown
