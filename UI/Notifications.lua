local TweenService = game:GetService("TweenService")

local InstanceUtil = require(script.Parent.Parent.Utils.Instance)

local Notifications = {}

local STATES = setmetatable({}, { __mode = "k" })

local function getTheme(themeManager)
	if themeManager and type(themeManager.GetTheme) == "function" then
		local ok, t = pcall(function()
			return themeManager:GetTheme()
		end)
		if ok and type(t) == "table" then
			return t
		end
	end

	return {
		Background = Color3.fromRGB(18, 18, 22),
		Secondary = Color3.fromRGB(28, 28, 34),
		Button = Color3.fromRGB(45, 45, 55),
		Stroke = Color3.fromRGB(55, 65, 90),
		TextPrimary = Color3.fromRGB(235, 235, 235),
		Accent = Color3.fromRGB(80, 140, 255),
		AccentDark = Color3.fromRGB(60, 105, 200),
		Error = Color3.fromRGB(255, 85, 85),
		Status = Color3.fromRGB(80, 255, 150),
	}
end

local function getAccent(theme, kind)
	kind = kind or "info"
	local accentColor = theme.Accent
	local titleText = "INFO"
	local iconChar = "i"

	if kind == "error" then
		accentColor = theme.Error
		titleText = "ERRO"
		iconChar = "×"
	elseif kind == "warn" then
		accentColor = theme.AccentDark
		titleText = "AVISO"
		iconChar = "!"
	elseif kind == "success" or kind == "status" then
		accentColor = theme.Status
		titleText = "SUCESSO"
		iconChar = "✓"
	end

	return accentColor, titleText, iconChar
end

local function buildHolder(screenGui)
	local holder = Instance.new("Frame")
	holder.Name = "Notifications"
	holder.BackgroundTransparency = 1
	holder.Position = UDim2.new(1, -20, 1, -20)
	holder.AnchorPoint = Vector2.new(1, 1)
	holder.Size = UDim2.new(0, 340, 1, 0)
	holder.Parent = screenGui
	holder.ClipsDescendants = false

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	layout.Padding = UDim.new(0, 10)
	layout.Parent = holder

	return holder
end

local function getState(screenGui)
	if not (screenGui and screenGui.Parent) then
		return nil
	end

	local state = STATES[screenGui]
	if state and state.holder and state.holder.Parent then
		return state
	end

	state = state or {}
	state.pool = state.pool or {}
	state.seq = state.seq or 0
	state.holder = buildHolder(screenGui)
	STATES[screenGui] = state
	return state
end

local function buildNotificationFrame(theme)
	local frame = InstanceUtil.Create("Frame", {
		Name = "Notification",
		ClipsDescendants = true,
		Size = UDim2.new(1, 0, 0, 58),
	})
	InstanceUtil.AddCorner(frame, 12)
	local stroke = InstanceUtil.AddStroke(frame, theme.Stroke, 1, 1)
	stroke.Name = "Stroke"

	local iconBg = InstanceUtil.Create("Frame", {
		Name = "IconBg",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.new(0, 30, 0, 30),
		BorderSizePixel = 0,
		Parent = frame,
	})
	InstanceUtil.AddCorner(iconBg, 15)

	InstanceUtil.Create("TextLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = iconBg,
	})

	InstanceUtil.Create("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 52, 0, 10),
		Size = UDim2.new(1, -64, 0, 14),
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextWrapped = false,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = frame,
	})

	InstanceUtil.Create("TextLabel", {
		Name = "Message",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 52, 0, 26),
		Size = UDim2.new(1, -64, 0, 20),
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = frame,
	})

	local progressBg = InstanceUtil.Create("Frame", {
		Name = "ProgressBg",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 3),
		BorderSizePixel = 0,
		Parent = frame,
	})

	InstanceUtil.Create("Frame", {
		Name = "Progress",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 3),
		BorderSizePixel = 0,
		Parent = progressBg,
	})

	local scale = Instance.new("UIScale")
	scale.Name = "Scale"
	scale.Scale = 1
	scale.Parent = frame

	return frame
end

function Notifications.Init(screenGui)
	local state = getState(screenGui)
	return state and state.holder or nil
end

function Notifications.Show(screenGui, themeManager, text, kind, instant, opts)
	opts = opts or {}
	local lifetime = tonumber(opts.Lifetime) or 3.4

	local state = getState(screenGui)
	if not state then
		return
	end

	local theme = getTheme(themeManager)
	local accentColor, titleText, iconChar = getAccent(theme, kind)

	state.seq += 1
	local token = state.seq

	local frame = table.remove(state.pool)
	if not frame then
		frame = buildNotificationFrame(theme)
	end

	frame:SetAttribute("NotifToken", token)
	frame.LayoutOrder = token
	frame.Parent = state.holder

	frame.BackgroundColor3 = theme.Secondary
	frame.BackgroundTransparency = 0.12

	local stroke = frame:FindFirstChild("Stroke")
	if stroke then
		stroke.Color = theme.Stroke
		stroke.Transparency = 1
	end

	local iconBg = frame:FindFirstChild("IconBg")
	local icon = iconBg and iconBg:FindFirstChild("Icon")
	local title = frame:FindFirstChild("Title")
	local msg = frame:FindFirstChild("Message")
	local progressBg = frame:FindFirstChild("ProgressBg")
	local progress = progressBg and progressBg:FindFirstChild("Progress")
	local scale = frame:FindFirstChild("Scale")

	if iconBg then
		iconBg.BackgroundColor3 = accentColor
		iconBg.BackgroundTransparency = 0.15
	end
	if icon then
		icon.Text = iconChar
		icon.TextColor3 = theme.TextPrimary
		icon.TextTransparency = 0
	end
	if title then
		title.Text = titleText
		title.TextColor3 = accentColor
		title.TextTransparency = 1
	end
	if msg then
		msg.Text = tostring(text or "")
		msg.TextColor3 = theme.TextPrimary
		msg.TextTransparency = 1
	end
	if progressBg then
		progressBg.BackgroundColor3 = theme.Button
		progressBg.BackgroundTransparency = 0.35
	end
	if progress then
		progress.BackgroundColor3 = accentColor
		progress.BackgroundTransparency = 1
		progress.Size = UDim2.new(1, 0, 0, 3)
	end
	if scale then
		scale.Scale = instant and 1 or 0.94
	end
	frame.BackgroundTransparency = instant and 0.12 or 1

	local inTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local outTween = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	if not instant then
		if scale then
			InstanceUtil.Tween(scale, inTween, { Scale = 1 })
		end
		InstanceUtil.Tween(frame, inTween, { BackgroundTransparency = 0.12 })
		if title then
			InstanceUtil.Tween(title, inTween, { TextTransparency = 0 })
		end
		if msg then
			InstanceUtil.Tween(msg, inTween, { TextTransparency = 0 })
		end
		if progress then
			InstanceUtil.Tween(progress, inTween, { BackgroundTransparency = 0 })
		end
		if stroke then
			pcall(function()
				InstanceUtil.Tween(stroke, inTween, { Transparency = 0.55 })
			end)
		end
	end

	if progress then
		InstanceUtil.Tween(progress, TweenInfo.new(lifetime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 0, 0, 3),
		})
	end

	task.delay(lifetime, function()
		if not (frame and frame.Parent) then
			return
		end
		if frame:GetAttribute("NotifToken") ~= token then
			return
		end

		if scale then
			InstanceUtil.Tween(scale, outTween, { Scale = 0.94 })
		end
		local t = InstanceUtil.Tween(frame, outTween, { BackgroundTransparency = 1 })
		if title then
			InstanceUtil.Tween(title, outTween, { TextTransparency = 1 })
		end
		if msg then
			InstanceUtil.Tween(msg, outTween, { TextTransparency = 1 })
		end
		if progress then
			InstanceUtil.Tween(progress, outTween, { BackgroundTransparency = 1 })
		end
		if stroke then
			pcall(function()
				InstanceUtil.Tween(stroke, outTween, { Transparency = 1 })
			end)
		end
		pcall(function()
			t.Completed:Wait()
		end)
		if frame:GetAttribute("NotifToken") ~= token then
			return
		end

		frame.Parent = nil
		table.insert(state.pool, frame)
	end)
end

return Notifications
