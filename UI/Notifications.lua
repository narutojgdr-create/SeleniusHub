local TweenService = game:GetService("TweenService")

local InstanceUtil = require(script.Parent.Parent.Utils.Instance)
local Acrylic = require(script.Parent.Parent.Theme.Acrylic)

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
		Warning = Color3.fromRGB(255, 170, 40),
		Status = Color3.fromRGB(80, 255, 150),
	}
end

local function getAccent(theme, kind)
	kind = kind or "info"
	local accentColor = theme.Accent
	local titleText = "NORMAL"

	if kind == "error" then
		accentColor = theme.Error
		titleText = "GRAVE"
	elseif kind == "warn" then
		accentColor = theme.Warning or theme.AccentDark
		titleText = "ATENÇÃO"
	elseif kind == "status" then
		accentColor = theme.Accent
		titleText = "ATIVO"
	elseif kind == "success" then
		accentColor = theme.Status
		titleText = "OK"
	end

	return accentColor, titleText
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
		Size = UDim2.new(1, 0, 0, 54),
	})
	Acrylic.Stylize(frame, theme, InstanceUtil, {
		BackgroundColor3 = theme.Secondary,
		BackgroundTransparency = 0.14,
		AddStroke = false,
	})
	InstanceUtil.AddCorner(frame, 12)
	local stroke = InstanceUtil.AddStroke(frame, theme.Stroke, 1, 1)
	stroke.Name = "Stroke"

	local severity = InstanceUtil.Create("Frame", {
		Name = "Severity",
		BackgroundColor3 = theme.Accent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 12, 0, 10),
		Size = UDim2.new(0, 5, 1, -20),
		Parent = frame,
	})
	InstanceUtil.AddCorner(severity, 8)

	InstanceUtil.Create("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 28, 0, 10),
		Size = UDim2.new(1, -40, 0, 14),
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
		Position = UDim2.new(0, 28, 0, 26),
		Size = UDim2.new(1, -40, 0, 18),
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = frame,
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
	local accentColor, titleText = getAccent(theme, kind)

	-- Glass blur também nas notificações (por padrão ligado)
	if opts.Blur ~= false then
		local blurSize = opts.BlurSize or theme.NotifBlurSize or theme.BlurSize or 18
		blurSize = tonumber(blurSize) or 18
		if blurSize > 20 then
			blurSize = 20
		end
		Acrylic.Request(lifetime + 0.4, blurSize)
	end

	state.seq = state.seq + 1
	local token = state.seq

	local frame = table.remove(state.pool)
	if not frame then
		frame = buildNotificationFrame(theme)
	end

	frame:SetAttribute("NotifToken", token)
	frame.LayoutOrder = token
	frame.Parent = state.holder

	frame.BackgroundColor3 = theme.Secondary
	frame.BackgroundTransparency = 0
	Acrylic.Stylize(frame, theme, InstanceUtil, {
		BackgroundColor3 = theme.Secondary,
		BackgroundTransparency = 0,
		AddStroke = false,
	})

	local stroke = frame:FindFirstChild("Stroke")
	if stroke then
		stroke.Color = theme.Stroke
		stroke.Transparency = 1
	end

	local severity = frame:FindFirstChild("Severity")
	local title = frame:FindFirstChild("Title")
	local msg = frame:FindFirstChild("Message")
	local scale = frame:FindFirstChild("Scale")

	if severity then
		severity.BackgroundColor3 = accentColor
		severity.BackgroundTransparency = 0
	end
	if title then
		title.Text = titleText
		title.TextColor3 = theme.TextSecondary or theme.AccentDark
		title.TextTransparency = 1
	end
	if msg then
		msg.Text = tostring(text or "")
		msg.TextColor3 = theme.TextPrimary
		msg.TextTransparency = 1
	end
	if scale then
		scale.Scale = instant and 1 or 0.94
	end
	frame.BackgroundTransparency = instant and 0.14 or 1

	local inTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local outTween = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	if not instant then
		if scale then
			InstanceUtil.Tween(scale, inTween, { Scale = 1 })
		end
		InstanceUtil.Tween(frame, inTween, { BackgroundTransparency = 0.14 })
		if title then
			InstanceUtil.Tween(title, inTween, { TextTransparency = 0 })
		end
		if msg then
			InstanceUtil.Tween(msg, inTween, { TextTransparency = 0 })
		end
		if stroke then
			pcall(function()
				InstanceUtil.Tween(stroke, inTween, { Transparency = 0.55 })
			end)
		end
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
