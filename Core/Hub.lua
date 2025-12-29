local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Defaults = require(script.Parent.Parent.Assets.Defaults)
local IconPaths = require(script.Parent.Parent.Assets.Icons)

local Assets = require(script.Parent.Parent.Utils.Assets)
local InstanceUtil = require(script.Parent.Parent.Utils.Instance)
local MathUtil = require(script.Parent.Parent.Utils.Math)

local Acrylic = require(script.Parent.Parent.Theme.Acrylic)

local ThemeManager = require(script.Parent.Parent.Theme.ThemeManager)
local LocaleManager = require(script.Parent.Parent.Locale.LocaleManager)

local Window = require(script.Parent.Parent.UI.Window)

local Registry = require(script.Parent.Registry)
local State = require(script.Parent.State)
local TabClass = require(script.Parent.Tab)

local Components = {
	Toggle = require(script.Parent.Parent.Components.Toggle),
	Checkbox = require(script.Parent.Parent.Components.Checkbox),
	Slider = require(script.Parent.Parent.Components.Slider),
	Dropdown = require(script.Parent.Parent.Components.Dropdown),
	MultiDropdown = require(script.Parent.Parent.Components.MultiDropdown),
	ColorPicker = require(script.Parent.Parent.Components.ColorPicker),
	Button = require(script.Parent.Parent.Components.Button),
	Keybind = require(script.Parent.Parent.Components.Keybind),
}

local Hub = {}
Hub.__index = Hub

-- Version identifier
Hub.Version = "Stable"

function Hub.new()
	-- [V2.0] Single Instance Protection
	if getgenv().SeleniusHubInstance then
		local old = getgenv().SeleniusHubInstance
		if old and old.ShowWarning then
			task.spawn(function()
				old:ShowWarning("Hub already opened!", "warn")
			end)
		end
		if old and old.UI and old.UI.MainFrame then
			old.UI.MainFrame.Visible = true
		end
		return old
	end

	local self = setmetatable({}, Hub)
	getgenv().SeleniusHubInstance = self

	self.Connections = {}
	self.Pages = {}
	self.Tabs = {}
	self.Minimized = false
	self.MinWidth = 520
	self.MinHeight = 350
	self.MinimizedHeight = 46

	self.State = State.new()
	self.Registry = Registry.new()

	self.LocaleManager = LocaleManager.new()
	self.ThemeManager = ThemeManager.new(InstanceUtil)

	self.CurrentThemeName = "Midnight"
	self.Locale = "pt"
	self.Keybind = Enum.KeyCode.RightControl
	self.IsMobile = UserInputService.TouchEnabled

	self.LoadedSize = nil
	self.SavedSize = nil
	self.StoredSize = nil
	self.StoredPos = nil

	self.VisibilityAnimating = false
	self.NotificationHolder = nil
	self.ConfigName = "default"
	self.SelectedConfig = "default"

	self.OptionToggles = {}
	self.OptionLocales = {}
	self.Searchables = {}
	self.CustomKeybinds = {}
	self.KeybindCallbacks = {}
	self.CapturingOptionKey = nil
	self.LocalizedDropdowns = {}
	self.DropdownZCounter = 2000

	self.Components = Components
	self._DidFinishInit = false

	Assets.EnsureFolders()
	self:LoadConfig("default")

	self:CreateUI()
	self:CreateNotificationSystem()
	self:SetupSmoothDrag()
	self:SetupResizing()
	self:SetupButtons()
	self:SetupMobileSupport()

	self:AddPage("Home", "tab_Home", "Home")
	self:AddPage("Combat", "tab_Combat", "Combat")
	self:AddPage("Visuals", "tab_Visuals", "Visuals")
	self:AddPage("Player", "tab_Player", "Player")
	self:AddPage("Settings", "tab_Settings", "Settings")
	self:SwitchPage("Home")

	self:SetTheme(self.CurrentThemeName)
	self:SetLanguage(self.Locale)
	self:SetupKeybindSystem()
	self:OnKeybindChanged()
	self:SetupSearch()

	-- IMPORTANTE: não carregar Tabs/loops aqui.
	-- Isso reduz o tempo até o KeySystem aparecer e deixa o Loading cuidar do resto.
	if self.UI and self.UI.MainFrame then
		self.UI.MainFrame.Visible = false
	end

	return self
end

function Hub:FinishInit()
	if self._DidFinishInit then
		return
	end
	self._DidFinishInit = true

	-- Carrega conteúdo pesado só depois (após Key/Loading)
	self:LoadTabs()
	self:StartLogicLoops()
end

function Hub:_NextDropdownZ()
	self.DropdownZCounter = self.DropdownZCounter - 1
	return self.DropdownZCounter
end

function Hub:_ComponentContext()
	return {
		themeManager = self.ThemeManager,
		localeManager = self.LocaleManager,
		instanceUtil = InstanceUtil,
		assets = Assets,
		addConnection = function(signal, callback) return self:AddConnection(signal, callback) end,
		registerSearchable = function(frame, localeKey) self:RegisterSearchable(frame, localeKey) end,
		nextDropdownZ = function() return self:_NextDropdownZ() end,
	}
end

function Hub:LoadTabs()
	local combat = self.Pages.Combat
	if combat then
		local tab = TabClass.new(self, "Combat", combat)
		require(script.Parent.Parent.Tabs.Combat.init)(tab)
	end

	local visuals = self.Pages.Visuals
	if visuals then
		local tab = TabClass.new(self, "Visuals", visuals)
		require(script.Parent.Parent.Tabs.Visual.init)(tab)
	end

	local player = self.Pages.Player
	if player then
		local tab = TabClass.new(self, "Player", player)
		require(script.Parent.Parent.Tabs.Player.init)(tab)
	end

	local settings = self.Pages.Settings
	if settings then
		local tab = TabClass.new(self, "Settings", settings)
		require(script.Parent.Parent.Tabs.Settings.init)(tab)
	end
end

function Hub:RegisterKeybind(id, keyCode, callback)
	if not id then
		return
	end
	self.CustomKeybinds[id] = keyCode
	self.KeybindCallbacks[id] = callback
end

function Hub:UnregisterKeybind(id)
	self.CustomKeybinds[id] = nil
	self.KeybindCallbacks[id] = nil
end

function Hub:StartLogicLoops()
	self:AddConnection(LocalPlayer.Idled, function()
		if self.State.Settings.AntiAFK then
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end
	end)

	self:AddConnection(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if self.UI and self.UI.MainFrame and self.UI.MainFrame.Visible then
				if not self.Minimized then
					local frame = self.UI.MainFrame
					if frame.AbsolutePosition.Y < 0 then
						local safeY = 20
						local halfHeight = frame.AbsoluteSize.Y / 2
						local newCenterYOffset = safeY + halfHeight
						InstanceUtil.Tween(frame, Defaults.Tween.AnimConfig, {
							Position = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset, 0, newCenterYOffset),
						})
					end
				end
			end
		end
	end)
end

function Hub:AddConnection(signal, callback)
	local conn = signal:Connect(callback)
	table.insert(self.Connections, conn)
	return conn
end

function Hub:GetText(key)
	return self.LocaleManager:GetText(key)
end

function Hub:RegisterLocale(obj, key, prefix, suffix)
	return self.LocaleManager:Register(obj, key, prefix, suffix)
end

function Hub:RegisterLocalizedOptions(dropdown, keys)
	self.LocaleManager:RegisterLocalizedOptions(dropdown, keys)
end

function Hub:SetLanguage(lang)
	if not (LocaleManager.GetLocales() and LocaleManager.GetLocales()[lang]) then
		return
	end
	self.Locale = lang
	self.LocaleManager:SetLanguage(lang)

	if self.LanguageDropdown and self.LanguageDropdown.currentLabel then
		self.LanguageDropdown.currentLabel.Text = (self.Locale == "pt") and self:GetText("lang_pt") or self:GetText("lang_en")
		if self.LanguageDropdown.optionButtons then
			for i, btn in ipairs(self.LanguageDropdown.optionButtons) do
				if i == 1 then
					btn.Text = self:GetText("lang_pt")
				else
					btn.Text = self:GetText("lang_en")
				end
			end
		end
	end

	self:OnKeybindChanged()
	if self.UpdateTabStyles then
		self:UpdateTabStyles()
	end
	if self.UpdateTabLabelPositions then
		self:UpdateTabLabelPositions()
	end
	if self.SearchBox then
		self.SearchBox.PlaceholderText = self:GetText("label_search")
	end
end

function Hub:RegisterTheme(obj, prop, key)
	self.ThemeManager:Register(obj, prop, key)
end

function Hub:SetTheme(name)
	self.ThemeManager:SetTheme(name)
	self.CurrentThemeName = name

	local Theme = self.ThemeManager:GetTheme()
	if self.UI and self.UI.TitleLabel then
		self.UI.TitleLabel.TextColor3 = Theme.Accent
	end
	if self.UI and self.UI.CloseBtn then
		self.UI.CloseBtn.BackgroundColor3 = Theme.Button
		self.UI.CloseBtn.TextColor3 = Theme.TextPrimary
	end
	if self.UI and self.UI.MinimizeBtn then
		self.UI.MinimizeBtn.BackgroundColor3 = Theme.Button
		self.UI.MinimizeBtn.TextColor3 = Theme.TextPrimary
	end

	if self.UpdateTabStyles then
		self:UpdateTabStyles()
	end
end

function Hub:GetKeybindName()
	return (self.Keybind and self.Keybind.Name) or "Nenhum"
end

function Hub:SaveConfig(name)
	if not self.UI or not self.UI.MainFrame then
		return
	end
	name = name or self.ConfigName
	if not name or name == "" then
		return
	end

	local size = self.SavedSize or self.UI.MainFrame.Size
	local data = {
		Theme = self.CurrentThemeName,
		Keybind = self.Keybind and self.Keybind.Name or nil,
		Width = size.X.Offset,
		Height = size.Y.Offset,
		Language = self.Locale,
		Settings = self.State.Settings,
	}
	local ok, encoded = pcall(function()
		return HttpService:JSONEncode(data)
	end)
	if ok then
		local filename = name .. ".json"
		Assets.SafeWriteFile(Defaults.CONFIGS_DIR .. "/" .. filename, encoded)
		self:ShowWarning("Config salva: " .. name, "info")
	end
end

function Hub:LoadConfig(name)
	local filename = (name or "default") .. ".json"
	local path = Defaults.CONFIGS_DIR .. "/" .. filename
	local encoded

	if Assets.SafeIsFile(path) and typeof(readfile) == "function" then
		local ok, res = pcall(readfile, path)
		if ok then
			encoded = res
		end
	end

	if not encoded then
		return
	end

	local ok, data = pcall(function()
		return HttpService:JSONDecode(encoded)
	end)
	if not ok or type(data) ~= "table" then
		return
	end

	local Themes = require(script.Parent.Parent.Theme.Themes)
	if data.Theme and Themes[data.Theme] then
		self:SetTheme(data.Theme)
	end
	if data.Keybind and Enum.KeyCode[data.Keybind] then
		self.Keybind = Enum.KeyCode[data.Keybind]
	end
	local locales = LocaleManager.GetLocales()
	if data.Language and locales and locales[data.Language] then
		self:SetLanguage(data.Language)
	end
	if data.Width and data.Height then
		self.LoadedSize = { Width = data.Width, Height = data.Height }
	end
	if data.Settings then
		for k, v in pairs(data.Settings) do
			self.State.Settings[k] = v
		end
		if self.OptionToggles["settings_antiafk"] then
			self.OptionToggles["settings_antiafk"].SetState(self.State.Settings.AntiAFK)
		end
	end

	self:OnKeybindChanged()
	self:ShowWarning("Config carregada: " .. (name or "default"), "info")
end

function Hub:CreateNotificationSystem()
	local holder = Instance.new("Frame")
	holder.Name = "Notifications"
	holder.BackgroundTransparency = 1
	holder.Position = UDim2.new(1, -20, 1, -20)
	holder.AnchorPoint = Vector2.new(1, 1)
	holder.Size = UDim2.new(0, 340, 1, 0)
	holder.Parent = self.UI.ScreenGui
	holder.ClipsDescendants = false

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	layout.Padding = UDim.new(0, 10)
	layout.Parent = holder

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 0)
	pad.PaddingRight = UDim.new(0, 0)
	pad.PaddingTop = UDim.new(0, 0)
	pad.PaddingBottom = UDim.new(0, 0)
	pad.Parent = holder

	self.NotificationHolder = holder
end

function Hub:ShowWarning(text, kind, instant)
	local Theme = self.ThemeManager:GetTheme()

	if not self.NotificationHolder then
		self:CreateNotificationSystem()
	end

	local frame = InstanceUtil.Create("Frame", {
		BackgroundColor3 = Theme.Secondary,
		BackgroundTransparency = 0.12,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = self.NotificationHolder,
	})
	InstanceUtil.AddCorner(frame, 12)
	InstanceUtil.AddStroke(frame, Theme.Stroke, 1, 0.45)
	pcall(function()
		Acrylic.Enable(frame, Theme, InstanceUtil)
	end)
	pcall(function()
		local grad = Instance.new("UIGradient")
		grad.Rotation = 90
		grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Theme.Secondary:Lerp(Theme.Background, 0.25)),
			ColorSequenceKeypoint.new(1, Theme.Secondary),
		})
		grad.Parent = frame
	end)

	local framePad = Instance.new("UIPadding")
	-- Padding vai no conteúdo (pra barra ficar colada na borda esquerda)
	framePad.PaddingLeft = UDim.new(0, 0)
	framePad.PaddingRight = UDim.new(0, 0)
	framePad.PaddingTop = UDim.new(0, 0)
	framePad.PaddingBottom = UDim.new(0, 0)
	framePad.Parent = frame

	local barColor = Theme.Accent
	if kind == "error" then
		barColor = Theme.Error
	end
	if kind == "warn" then
		barColor = Theme.Warning
	end

	local bar = Instance.new("Frame")
	bar.BackgroundColor3 = barColor
	bar.Position = UDim2.new(0, 0, 0, 10)
	bar.Size = UDim2.new(0, 4, 1, -20)
	bar.Parent = frame
	InstanceUtil.AddCorner(bar, 8)

	local content = Instance.new("Frame")
	content.BackgroundTransparency = 1
	content.Size = UDim2.new(1, 0, 0, 0)
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.Parent = frame

	local contentPad = Instance.new("UIPadding")
	contentPad.PaddingLeft = UDim.new(0, 14)
	contentPad.PaddingRight = UDim.new(0, 14)
	contentPad.PaddingTop = UDim.new(0, 12)
	contentPad.PaddingBottom = UDim.new(0, 12)
	contentPad.Parent = content

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Padding = UDim.new(0, 6)
	contentLayout.Parent = content

	local header = Instance.new("TextLabel")
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, 0, 0, 0)
	header.AutomaticSize = Enum.AutomaticSize.Y
	header.Font = Enum.Font.GothamBold
	header.TextSize = 14
	header.TextColor3 = barColor
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.TextWrapped = true
	header.Text = (kind == "error" and "Erro") or (kind == "warn" and "Aviso") or "Info"
	header.Parent = content

	local title = Instance.new("TextLabel")
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0, 0)
	title.AutomaticSize = Enum.AutomaticSize.Y
	title.Font = Enum.Font.GothamMedium
	title.TextSize = 15
	title.TextColor3 = Theme.TextPrimary
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextWrapped = true
	title.Text = text
	title.Parent = content

	local timeout = 4
	local timerBg = Instance.new("Frame")
	timerBg.BackgroundTransparency = 1
	timerBg.Size = UDim2.new(1, 0, 0, 3)
	timerBg.Parent = content

	local timer = Instance.new("Frame")
	timer.BackgroundColor3 = barColor
	timer.BackgroundTransparency = 0.35
	timer.Size = UDim2.new(1, 0, 1, 0)
	timer.Parent = timerBg
	InstanceUtil.AddCorner(timer, 6)

	-- Entrada
	frame.Position = instant and UDim2.new(0, 0, 0, 0) or UDim2.new(1, 220, 0, 0)
	frame.BackgroundTransparency = instant and frame.BackgroundTransparency or 1
	title.TextTransparency = instant and 0 or 1
	header.TextTransparency = instant and 0 or 1

	if not instant then
		InstanceUtil.Tween(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 0.12,
		})
		InstanceUtil.Tween(title, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 })
		InstanceUtil.Tween(header, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 })
	end

	-- Barra de tempo (discreta)
	InstanceUtil.Tween(timer, TweenInfo.new(timeout, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundTransparency = 1,
	})

	task.delay(timeout, function()
		if frame then
			local t = InstanceUtil.Tween(frame, TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				BackgroundTransparency = 1,
			})
			InstanceUtil.Tween(title, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1 })
			InstanceUtil.Tween(header, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1 })
			t.Completed:Wait()
			frame:Destroy()
		end
	end)
end

function Hub:ShowConfirmation(text, onConfirm)
	local Theme = self.ThemeManager:GetTheme()
	local gui = self.UI and self.UI.ScreenGui
	if not gui then
		return
	end

	local overlay = Instance.new("Frame")
	overlay.BackgroundColor3 = Color3.new(0, 0, 0)
	overlay.BackgroundTransparency = 1
	overlay.Size = UDim2.new(1, 0, 1, 0)
	overlay.Parent = gui
	overlay.ZIndex = 100

	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	local box = Instance.new("Frame")
	box.Size = UDim2.new(0, 320, 0, 160)
	box.AnchorPoint = Vector2.new(0.5, 0.5)
	box.Position = UDim2.new(0.5, 0, 0.5, 50)
	box.BackgroundColor3 = Theme.Secondary
	box.Parent = overlay
	box.ZIndex = 101
	InstanceUtil.AddCorner(box, 8)

	box.BackgroundTransparency = 1
	TweenService:Create(box, tweenInfo, {
		Position = UDim2.new(0.5, 0, 0.5, 0),
		BackgroundTransparency = 0,
	}):Play()

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.new(0, 10, 0, 10)
	lbl.Size = UDim2.new(1, -20, 0, 60)
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 18
	lbl.Text = text
	lbl.TextWrapped = true
	lbl.TextColor3 = Theme.TextPrimary
	lbl.TextTransparency = 1
	lbl.Parent = box
	lbl.ZIndex = 102
	TweenService:Create(lbl, tweenInfo, { TextTransparency = 0 }):Play()

	local yesBtn = Instance.new("TextButton")
	yesBtn.Text = self:GetText("label_apply")
	yesBtn.Size = UDim2.new(0.4, -10, 0, 32)
	yesBtn.Position = UDim2.new(0.1, 0, 1, -50)
	yesBtn.BackgroundColor3 = Theme.Button
	yesBtn.BackgroundTransparency = 1
	yesBtn.TextColor3 = Theme.TextPrimary
	yesBtn.TextTransparency = 1
	yesBtn.Parent = box
	yesBtn.ZIndex = 102
	yesBtn.AutoButtonColor = false
	InstanceUtil.AddCorner(yesBtn, 6)
	TweenService:Create(yesBtn, tweenInfo, { BackgroundTransparency = 0, TextTransparency = 0 }):Play()

	local noBtn = Instance.new("TextButton")
	noBtn.Text = self:GetText("label_cancel")
	noBtn.Size = UDim2.new(0.4, -10, 0, 32)
	noBtn.Position = UDim2.new(0.5, 10, 1, -50)
	noBtn.BackgroundColor3 = Theme.Button
	noBtn.BackgroundTransparency = 1
	noBtn.TextColor3 = Theme.TextPrimary
	noBtn.TextTransparency = 1
	noBtn.Parent = box
	noBtn.ZIndex = 102
	noBtn.AutoButtonColor = false
	InstanceUtil.AddCorner(noBtn, 6)
	TweenService:Create(noBtn, tweenInfo, { BackgroundTransparency = 0, TextTransparency = 0 }):Play()

	local function Close()
		TweenService:Create(box, tweenInfo, { Position = UDim2.new(0.5, 0, 0.5, 50), BackgroundTransparency = 1 }):Play()
		TweenService:Create(lbl, tweenInfo, { TextTransparency = 1 }):Play()
		TweenService:Create(yesBtn, tweenInfo, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
		TweenService:Create(noBtn, tweenInfo, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
		task.wait(0.3)
		if overlay then
			overlay:Destroy()
		end
	end

	yesBtn.MouseButton1Click:Connect(function()
		Close()
		if onConfirm then
			onConfirm()
		end
	end)
	noBtn.MouseButton1Click:Connect(function()
		Close()
	end)
end

function Hub:CreateKeybindControl(parent, position)
	local Theme = self.ThemeManager:GetTheme()
	local AnimConfig = Defaults.Tween.AnimConfig
	local PopTween = Defaults.Tween.PopTween
	local PopReturnTween = Defaults.Tween.PopReturnTween

	local frame = InstanceUtil.Create("Frame", {
		BackgroundColor3 = Theme.Button,
		Size = UDim2.new(0, 260, 0, 40),
		Position = position,
		Parent = parent,
	})
	InstanceUtil.AddCorner(frame, 6)
	InstanceUtil.AddStroke(frame, Theme.Stroke, 1, 0.5)

	local title = InstanceUtil.Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 8, 0, 0),
		Size = UDim2.new(0, 150, 1, 0),
		Font = Enum.Font.GothamMedium,
		TextSize = 18,
		TextColor3 = Theme.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = self:GetText("label_keybind"),
		Parent = frame,
	})
	self:RegisterLocale(title, "label_keybind")
	self:RegisterTheme(title, "TextColor3", "TextPrimary")

	local btn = InstanceUtil.Create("TextButton", {
		BackgroundColor3 = Theme.ButtonHover,
		Size = UDim2.new(0, 110, 0, 26),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Font = Enum.Font.GothamBold,
		TextSize = 18,
		TextColor3 = Theme.TextPrimary,
		Text = "[" .. self:GetKeybindName() .. "]",
		AutoButtonColor = false,
		Parent = frame,
	})
	InstanceUtil.AddCorner(btn, 13)
	self:RegisterTheme(btn, "TextColor3", "TextPrimary")

	local btnScale = Instance.new("UIScale")
	btnScale.Scale = 1
	btnScale.Parent = btn

	self.KeybindButtonLabel = btn

	self:AddConnection(btn.MouseButton1Click, function()
		self.CapturingKeybind = true
		btn.Text = "..."
		TweenService:Create(btnScale, PopTween, { Scale = 1.15 }):Play()
		task.delay(PopTween.Time, function()
			TweenService:Create(btnScale, PopReturnTween, { Scale = 1 }):Play()
		end)
	end)

	self:AddConnection(btn.MouseEnter, function()
		Theme = self.ThemeManager:GetTheme()
		InstanceUtil.Tween(btn, AnimConfig, { BackgroundColor3 = Theme.AccentDark })
	end)
	self:AddConnection(btn.MouseLeave, function()
		Theme = self.ThemeManager:GetTheme()
		InstanceUtil.Tween(btn, AnimConfig, { BackgroundColor3 = Theme.ButtonHover })
	end)

	self.ThemeManager:AddCallback(function()
		Theme = self.ThemeManager:GetTheme()
		frame.BackgroundColor3 = Theme.Button
		btn.BackgroundColor3 = Theme.ButtonHover
		title.TextColor3 = Theme.TextPrimary
		btn.TextColor3 = Theme.TextPrimary
	end)

	return frame
end

function Hub:_CreateSectionTitle(parent, localeKey, text, position)
	local Theme = self.ThemeManager:GetTheme()
	local label = InstanceUtil.Create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -20, 0, 24),
		Position = position or UDim2.new(0, 10, 0, 10),
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = Theme.TextPrimary,
		TextXAlignment = Enum.TextXAlignment.Center,
		Text = text or (localeKey and self:GetText(localeKey)) or "",
		Parent = parent,
	})
	self:RegisterTheme(label, "TextColor3", "TextPrimary")
	if localeKey then
		self:RegisterLocale(label, localeKey)
	end
	return label
end

function Hub:RegisterSearchable(frame, localeKey)
	if localeKey then
		table.insert(self.Searchables, { Frame = frame, KeyLocale = localeKey })
	end
end

function Hub:SetupSearch()
	if not self.SearchBox then
		return
	end
	self:AddConnection(self.SearchBox:GetPropertyChangedSignal("Text"), function()
		local query = string.lower(self.SearchBox.Text or "")
		for _, item in ipairs(self.Searchables) do
			local text = (self:GetText(item.KeyLocale) or ""):lower()
			if query == "" then
				item.Frame.Visible = true
			else
				if string.find(text, query, 1, true) then
					item.Frame.Visible = true
				else
					item.Frame.Visible = false
				end
			end
		end
	end)
end

function Hub:CreateUI()
	local ctx = {
		themeManager = self.ThemeManager,
		localeManager = self.LocaleManager,
		instanceUtil = InstanceUtil,
		assets = Assets,
	}
	local UI = Window.Create(ctx)
	self.UI = UI
	self.BlurFunction = UI.BlurFunction
	self.MainStroke = UI.MainStroke

	self.DefaultSize = UI.MainFrame.Size
	self.SavedSize = UI.MainFrame.Size
	self.StoredSize = UI.MainFrame.Size
	self.StoredPos = UI.MainFrame.Position

	if self.LoadedSize then
		local w = math.max(self.MinWidth, self.LoadedSize.Width)
		local h = math.max(self.MinHeight, self.LoadedSize.Height)
		UI.MainFrame.Size = UDim2.new(0, w, 0, h)
		self.SavedSize = UI.MainFrame.Size
		self.StoredSize = UI.MainFrame.Size
	end

	self.SearchBox = UI.SearchBox
end

function Hub:CreateTabButton(id, localeKey, iconKey)
	local Theme = self.ThemeManager:GetTheme()
	local btn = InstanceUtil.Create("TextButton", {
		Text = "",
		Font = Enum.Font.GothamMedium,
		TextSize = 16,
		TextColor3 = Theme.AccentDark,
		BackgroundColor3 = Theme.Button,
		Size = UDim2.new(1, -10, 0, 44),
		AutoButtonColor = false,
		Parent = self.UI.Sidebar,
	})
	InstanceUtil.AddCorner(btn, 6)

	local icon = InstanceUtil.Create("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 20, 0, 20),
		Position = UDim2.new(0, 8, 0.5, -10),
		Image = Assets.GetIcon(IconPaths[iconKey] or ""),
		ImageColor3 = Theme.AccentDark,
		Parent = btn,
	})

	local label = InstanceUtil.Create("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 32, 0, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.AccentDark,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = self:GetText(localeKey),
		Parent = btn,
	})
	self:RegisterLocale(label, localeKey)

	local indicator = InstanceUtil.Create("Frame", {
		BackgroundColor3 = Theme.IndicatorOff,
		Size = UDim2.new(0, 5, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		Parent = btn,
	})

	self:AddConnection(btn.MouseEnter, function()
		local T = self.ThemeManager:GetTheme()
		InstanceUtil.Tween(btn, Defaults.Tween.AnimConfig, { BackgroundColor3 = T.ButtonHover })
	end)
	self:AddConnection(btn.MouseLeave, function()
		if self.CurrentPage ~= id then
			local T = self.ThemeManager:GetTheme()
			InstanceUtil.Tween(btn, Defaults.Tween.AnimConfig, { BackgroundColor3 = T.Button })
		end
	end)
	self:AddConnection(btn.MouseButton1Click, function()
		self:SwitchPage(id)
	end)

	self.ThemeManager:AddCallback(function()
		local T = self.ThemeManager:GetTheme()
		local isSelected = (self.CurrentPage == id)
		if isSelected then
			indicator.BackgroundColor3 = T.IndicatorOn
			btn.BackgroundColor3 = T.ButtonHover
			label.TextColor3 = T.Accent
			icon.ImageColor3 = T.Accent
		else
			indicator.BackgroundColor3 = T.IndicatorOff
			btn.BackgroundColor3 = T.Button
			label.TextColor3 = T.AccentDark
			icon.ImageColor3 = T.AccentDark
		end
	end)

	return btn, indicator, label
end

function Hub:AddPage(id, localeKey, iconKey)
	if self.Pages[id] then
		return
	end

	local Theme = self.ThemeManager:GetTheme()

	local page = Instance.new("ScrollingFrame")
	page.Name = InstanceUtil.RandomString(8)
	page.BackgroundColor3 = Theme.Secondary
	page.BackgroundTransparency = 0.6
	page.Size = UDim2.new(1, 0, 1, 0)
	page.Visible = false
	page.Parent = self.UI.PagesContainer
	page.ScrollBarThickness = 2
	page.ScrollBarImageColor3 = Theme.Accent
	page.BorderSizePixel = 0
	self:RegisterTheme(page, "ScrollBarImageColor3", "Accent")
	page.CanvasSize = UDim2.new(0, 0, 0, 1200)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	InstanceUtil.AddCorner(page, 6)
	self:RegisterTheme(page, "BackgroundColor3", "Secondary")

	local btn, indicator, label = self:CreateTabButton(id, localeKey, iconKey)
	self.Tabs[id] = { Button = btn, Indicator = indicator, Label = label }
	self.Pages[id] = page

	if id == "Home" then
		self:_CreateSectionTitle(page, "section_home", "Informações")
		local infoContainer = InstanceUtil.Create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -40, 0, 200),
			Position = UDim2.new(0, 20, 0, 60),
			Parent = page,
		})
		local layout = Instance.new("UIListLayout")
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 10)
		layout.Parent = infoContainer

		local homeTitle = InstanceUtil.Create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			Font = Enum.Font.GothamBold,
			TextSize = 24,
			TextColor3 = Theme.Accent,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = self:GetText("label_home_title"),
			Parent = infoContainer,
		})
		self:RegisterTheme(homeTitle, "TextColor3", "Accent")

		local statusRow = InstanceUtil.Create("Frame", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 24),
			Parent = infoContainer,
		})
		local rowLayout = Instance.new("UIListLayout")
		rowLayout.FillDirection = Enum.FillDirection.Horizontal
		rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
		rowLayout.Padding = UDim.new(0, 8)
		rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		rowLayout.Parent = statusRow

		local statusLabel = InstanceUtil.Create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 50, 1, 0),
			Font = Enum.Font.GothamMedium,
			TextSize = 18,
			TextColor3 = Theme.TextPrimary,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = self:GetText("label_status"),
			Parent = statusRow,
		})
		self:RegisterTheme(statusLabel, "TextColor3", "TextPrimary")

		local statusText = InstanceUtil.Create("TextLabel", {
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			TextColor3 = Theme.Accent,
			Text = "Estável",
			Parent = statusRow,
		})

		local dot = Instance.new("Frame")
		dot.Size = UDim2.new(0, 10, 0, 10)
		dot.BackgroundColor3 = Theme.Accent
		dot.Parent = statusRow
		InstanceUtil.AddCorner(dot, 10)

		local credit = InstanceUtil.Create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 24),
			Font = Enum.Font.GothamMedium,
			TextSize = 16,
			TextColor3 = Theme.AccentDark,
			TextXAlignment = Enum.TextXAlignment.Left,
			Text = self:GetText("label_home_credit"),
			Parent = infoContainer,
		})
		self:RegisterTheme(credit, "TextColor3", "AccentDark")
	end
end

function Hub:SwitchPage(id)
	if self.CurrentPage == id then
		return
	end

	local Theme = self.ThemeManager:GetTheme()

	if self.CurrentPage then
		local oldTab = self.Tabs[self.CurrentPage]
		if oldTab then
			oldTab.Indicator.BackgroundColor3 = Theme.IndicatorOff
			InstanceUtil.Tween(oldTab.Button, Defaults.Tween.AnimConfig, { BackgroundColor3 = Theme.Button })
			InstanceUtil.Tween(oldTab.Label, Defaults.Tween.AnimConfig, { TextColor3 = Theme.AccentDark })
		end
		local oldPage = self.Pages[self.CurrentPage]
		if oldPage then
			oldPage.Visible = false
		end
	end

	local newTab = self.Tabs[id]
	if newTab then
		newTab.Indicator.BackgroundColor3 = Theme.IndicatorOn
		InstanceUtil.Tween(newTab.Button, Defaults.Tween.AnimConfig, { BackgroundColor3 = Theme.ButtonHover })
		InstanceUtil.Tween(newTab.Label, Defaults.Tween.AnimConfig, { TextColor3 = Theme.Accent })
	end
	local newPage = self.Pages[id]
	if newPage then
		newPage.Visible = true
		newPage.Position = UDim2.new(0, 0, 0, 20)
		newPage.BackgroundTransparency = 1
		local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		InstanceUtil.Tween(newPage, tweenInfo, { Position = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1 })
	end
	self.CurrentPage = id
end

function Hub:IsVisible()
	return self.UI and self.UI.MainFrame.Visible
end

function Hub:SetVisible(visible, animated)
	if not self.UI then
		return
	end
	if self.VisibilityAnimating then
		return
	end
	local frame = self.UI.MainFrame

	if visible then
		if frame.Visible and not animated then
			return
		end
		frame.Visible = true
		if self.BlurFunction then
			self.BlurFunction(true)
		end

		local size = self.StoredSize or self.SavedSize or self.DefaultSize
		local pos = UDim2.new(0.5, 0, 0.5, 0)

		if animated then
			self.VisibilityAnimating = true
			frame.Size = UDim2.new(size.X.Scale, size.X.Offset, 0, 0)
			frame.Position = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset + size.Y.Offset / 2)
			frame.ClipsDescendants = true
			InstanceUtil.Tween(frame, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = size,
				Position = pos,
			}).Completed:Connect(function()
				self.VisibilityAnimating = false
				frame.ClipsDescendants = false
			end)
		else
			frame.Size = size
			frame.Position = pos
			frame.ClipsDescendants = false
		end
	else
		if not frame.Visible then
			return
		end
		if self.BlurFunction then
			self.BlurFunction(false)
		end

		local size = frame.Size
		local pos = frame.Position
		self.StoredSize = size
		self.StoredPos = pos

		if animated then
			self.VisibilityAnimating = true
			local endPos = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset + size.Y.Offset / 2)
			frame.ClipsDescendants = true
			InstanceUtil.Tween(frame, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Size = UDim2.new(size.X.Scale, size.X.Offset, 0, 0),
				Position = endPos,
			}).Completed:Connect(function()
				frame.Visible = false
				frame.Size = size
				frame.Position = pos
				self.VisibilityAnimating = false
				frame.ClipsDescendants = false
			end)
		else
			frame.Visible = false
		end
	end
end

function Hub:OnKeybindChanged()
	local name = self:GetKeybindName()
	if self.KeybindButtonLabel then
		self.KeybindButtonLabel.Text = "[" .. name .. "]"
	end
end

function Hub:SetupKeybindSystem()
	self:AddConnection(UserInputService.InputBegan, function(input, gp)
		if gp or UserInputService:GetFocusedTextBox() then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		if self.CapturingKeybind then
			if input.KeyCode ~= Enum.KeyCode.Unknown then
				self.Keybind = input.KeyCode
				self.CapturingKeybind = false
				self:OnKeybindChanged()
			end
			return
		end
		if self.Keybind and input.KeyCode == self.Keybind then
			self:SetVisible(not self:IsVisible(), true)
			return
		end

		for id, keyCode in pairs(self.CustomKeybinds) do
			if keyCode and input.KeyCode == keyCode then
				local cb = self.KeybindCallbacks[id]
				if cb then
					cb()
				end
			end
		end
	end)
end

function Hub:SetupMobileSupport()
	if self.IsMobile then
		local Theme = self.ThemeManager:GetTheme()
		local mobileBtn = InstanceUtil.Create("ImageButton", {
			Name = "SeleniusMobileButton",
			Image = IconPaths.Logo,
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Theme.Background,
			Position = UDim2.new(0.9, -50, 0.1, 0),
			Size = UDim2.new(0, 50, 0, 50),
			Parent = self.UI.ScreenGui,
		})
		InstanceUtil.AddCorner(mobileBtn, 12)

		local dragging, dragStart, startPos
		mobileBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = mobileBtn.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
						if (input.Position - dragStart).Magnitude < 10 then
							self:SetVisible(not self:IsVisible(), true)
						end
					end
				end)
			end
		end)

		mobileBtn.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
				local delta = input.Position - dragStart
				mobileBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end
end

function Hub:SetupSmoothDrag()
	local dragging = false
	local dragInput, dragStart, startPos
	local frame = self.UI.MainFrame

	self:AddConnection(self.UI.TitleBar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	self:AddConnection(self.UI.TitleBar.InputChanged, function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	self:AddConnection(RunService.RenderStepped, function()
		if dragging and dragInput then
			local delta = dragInput.Position - dragStart
			local targetX = startPos.X.Offset + delta.X
			local targetY = startPos.Y.Offset + delta.Y
			frame.Position = UDim2.new(
				startPos.X.Scale,
				MathUtil.Lerp(frame.Position.X.Offset, targetX, 0.25),
				startPos.Y.Scale,
				MathUtil.Lerp(frame.Position.Y.Offset, targetY, 0.25)
			)
			self.StoredPos = frame.Position
		end
	end)
end

function Hub:SetupResizing()
	local handle = self.UI.ResizeHandle
	local frame = self.UI.MainFrame
	local resizing = false
	local dragStart
	local startSize

	self:AddConnection(handle.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if self.Minimized then
				return
			end
			resizing = true
			dragStart = input.Position
			startSize = frame.Size
			local conn
			conn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
					conn:Disconnect()
				end
			end)
		end
	end)

	self:AddConnection(UserInputService.InputChanged, function(input)
		if not resizing or input.UserInputType ~= Enum.UserInputType.MouseMovement then
			return
		end
		local delta = input.Position - dragStart
		local newW = math.max(self.MinWidth, startSize.X.Offset + delta.X)
		local newH = math.max(self.MinHeight, startSize.Y.Offset + delta.Y)
		frame.Size = UDim2.new(0, newW, 0, newH)
		self.SavedSize = frame.Size
		self.StoredSize = frame.Size
	end)

	self:AddConnection(handle.MouseEnter, function()
		local Theme = self.ThemeManager:GetTheme()
		for _, dot in ipairs(self.UI.ResizeDots) do
			InstanceUtil.Tween(dot, Defaults.Tween.AnimConfig, { BackgroundColor3 = Theme.Accent })
		end
	end)
	self:AddConnection(handle.MouseLeave, function()
		local Theme = self.ThemeManager:GetTheme()
		for _, dot in ipairs(self.UI.ResizeDots) do
			InstanceUtil.Tween(dot, Defaults.Tween.AnimConfig, { BackgroundColor3 = Theme.Separator })
		end
	end)
end

function Hub:SetupButtons()
	local UI = self.UI
	self:AddConnection(UI.CloseBtn.MouseButton1Click, function()
		self:SetVisible(false, true)
	end)

	self:AddConnection(UI.MinimizeBtn.MouseButton1Click, function()
		local frame = UI.MainFrame
		if self.Minimized then
			self.Minimized = false
			local targetSize = self.SavedSize or self.DefaultSize

			local viewport = Camera.ViewportSize
			local halfHeight = targetSize.Y.Offset / 2
			local currentAbsY = (viewport.Y * frame.Position.Y.Scale) + frame.Position.Y.Offset
			local futureTop = currentAbsY - halfHeight
			local futureBottom = currentAbsY + halfHeight
			local finalYOffset = frame.Position.Y.Offset

			if futureTop < 10 then
				local correction = 10 - futureTop
				finalYOffset = finalYOffset + correction
			elseif futureBottom > (viewport.Y - 10) then
				local correction = (viewport.Y - 10) - futureBottom
				finalYOffset = finalYOffset + correction
			end

			InstanceUtil.Tween(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = targetSize,
				Position = UDim2.new(frame.Position.X.Scale, frame.Position.X.Offset, frame.Position.Y.Scale, finalYOffset),
			})

			task.delay(0.1, function()
				UI.ContentContainer.Visible = true
				if UI.Separator then
					UI.Separator.Visible = true
				end
			end)
		else
			self.Minimized = true
			self.SavedSize = frame.Size
			UI.ContentContainer.Visible = false
			if UI.Separator then
				UI.Separator.Visible = false
			end
			InstanceUtil.Tween(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, frame.Size.X.Offset, 0, self.MinimizedHeight),
			})
		end
	end)
end

function Hub:Destroy()
	if self._Destroyed then
		return
	end
	self._Destroyed = true

	for _, conn in ipairs(self.Connections) do
		if conn and conn.Connected then
			conn:Disconnect()
		end
	end
	self.Connections = {}

	pcall(function()
		if type(getgenv) == "function" and getgenv().SeleniusHubInstance == self then
			getgenv().SeleniusHubInstance = nil
		end
	end)
	pcall(function()
		if typeof(_G) == "table" and rawget(_G, "SeleniusHubInstance") == self then
			rawset(_G, "SeleniusHubInstance", nil)
		end
	end)

	pcall(function()
		if self.__SeleniusKeyGui then
			self.__SeleniusKeyGui:Destroy()
			self.__SeleniusKeyGui = nil
		end
	end)
	pcall(function()
		if self.__SeleniusLoadingGui then
			self.__SeleniusLoadingGui:Destroy()
			self.__SeleniusLoadingGui = nil
		end
	end)

	if self.BlurFunction then
		self.BlurFunction(false)
	end
	if self.BlurInstance then
		self.BlurInstance:Destroy()
	end

	if self.UI and self.UI.ScreenGui then
		pcall(function()
			self.UI.ScreenGui:Destroy()
		end)
	end
end

return Hub
