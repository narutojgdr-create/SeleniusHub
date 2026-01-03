local Option = require(script.Parent.Option)

local Defaults = require(script.Parent.Parent.Assets.Defaults)
local InstanceUtil = require(script.Parent.Parent.Utils.Instance)

local Tab = {}
Tab.__index = Tab

function Tab.new(hub, id, page)
	local self = setmetatable({}, Tab)
	self.Hub = hub
	self.Id = id
	self.Page = page
	self.RootPage = page
	self.SubTabs = nil
	self.CurrentSubTabId = nil
	self._SubTabBar = nil
	self._SubTabViewport = nil
	return self
end

function Tab:_EnsureSubTabUI()
	if self.SubTabs then
		return
	end

	self.SubTabs = {}
	self.CurrentSubTabId = nil

	local Theme = self.Hub.ThemeManager:GetTheme()
	local root = self.RootPage

	-- Quando SubAbas são usadas, a página vira um container fixo.
	pcall(function()
		root.ScrollingEnabled = false
		root.ScrollBarThickness = 0
		root.AutomaticCanvasSize = Enum.AutomaticSize.None
		root.CanvasSize = UDim2.new(0, 0, 0, 0)
	end)

	local bar = InstanceUtil.Create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 10),
		Size = UDim2.new(1, -20, 0, 34),
		Parent = root,
	})

	local barLayout = InstanceUtil.Create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Parent = bar,
	})
	barLayout:GetPropertyChangedSignal("AbsoluteContentSize")

	local viewport = InstanceUtil.Create("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 52),
		Size = UDim2.new(1, 0, 1, -52),
		ClipsDescendants = true,
		Parent = root,
	})

	self._SubTabBar = bar
	self._SubTabViewport = viewport

	self.Hub.ThemeManager:AddCallback(function()
		-- Reaplica cores em todos botões de SubAba
		local T = self.Hub.ThemeManager:GetTheme()
		for subId, sub in pairs(self.SubTabs or {}) do
			local selected = (self.CurrentSubTabId == subId)
			if sub.Button and sub.Label then
				sub.Button.BackgroundColor3 = selected and T.ButtonHover or T.Button
				sub.Label.TextColor3 = selected and T.Accent or T.AccentDark
				local stroke = sub.Button:FindFirstChildOfClass("UIStroke")
				if stroke then
					stroke.Color = T.Stroke
				end
			end
			if sub.Page then
				pcall(function()
					sub.Page.ScrollBarImageColor3 = T.Accent
				end)
			end
		end
	end)
end

function Tab:_GetActivePage()
	if self.SubTabs then
		if not self.CurrentSubTabId then
			-- fallback seguro
			self:SubTab("Main")
		end
		local sub = self.SubTabs[self.CurrentSubTabId]
		if sub and sub.Page then
			return sub.Page
		end
	end
	return self.Page
end

function Tab:_SwitchSubTab(id)
	if not self.SubTabs then
		return
	end
	if self.CurrentSubTabId == id then
		return
	end

	local Theme = self.Hub.ThemeManager:GetTheme()
	for subId, sub in pairs(self.SubTabs) do
		local selected = (subId == id)
		if sub.Page then
			sub.Page.Visible = selected
		end
		if sub.Button and sub.Label then
			InstanceUtil.Tween(sub.Button, Defaults.Tween.AnimConfig, {
				BackgroundColor3 = selected and Theme.ButtonHover or Theme.Button,
			})
			InstanceUtil.Tween(sub.Label, Defaults.Tween.AnimConfig, {
				TextColor3 = selected and Theme.Accent or Theme.AccentDark,
			})
		end
	end

	self.CurrentSubTabId = id
	if self.Hub and self.Hub._OnSubTabChanged then
		self.Hub:_OnSubTabChanged(self.Id, id)
	end
end

function Tab:SwitchSubTab(id)
	self:_SwitchSubTab(id)
end

-- Cria/ativa uma SubAba para o Tab atual.
-- Uso:
--   tab:SubTab("Geral")
--   tab:SubTab("tab_visual", "tab_visual") -- (id, localeKey)
function Tab:SubTab(id, localeKey)
	if not id then
		return
	end
	self:_EnsureSubTabUI()

	if not self.SubTabs[id] then
		local Theme = self.Hub.ThemeManager:GetTheme()

		local btn = InstanceUtil.Create("TextButton", {
			AutoButtonColor = false,
			BackgroundColor3 = Theme.Button,
			BackgroundTransparency = tonumber(Theme.ControlTransparency) or 0.34,
			Size = UDim2.new(0, 96, 0, 28),
			Text = "",
			Parent = self._SubTabBar,
		})
		InstanceUtil.AddCorner(btn, 6)
		InstanceUtil.AddStroke(btn, Theme.Stroke, 1, 0.5)

		local label = InstanceUtil.Create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -10, 1, 0),
			Position = UDim2.new(0, 5, 0, 0),
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextColor3 = Theme.AccentDark,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextWrapped = false,
			Text = localeKey and self.Hub:GetText(localeKey) or tostring(id),
			Parent = btn,
		})
		if localeKey then
			self.Hub:RegisterLocale(label, localeKey)
		end

		local page = Instance.new("ScrollingFrame")
		page.Name = InstanceUtil.RandomString(8)
		page.BackgroundTransparency = 1
		page.Size = UDim2.new(1, 0, 1, 0)
		page.Visible = false
		page.Parent = self._SubTabViewport
		page.ScrollBarThickness = 2
		page.ScrollBarImageColor3 = Theme.Accent
		page.BorderSizePixel = 0
		page.CanvasSize = UDim2.new(0, 0, 0, 1200)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y

		self.Hub:AddConnection(btn.MouseEnter, function()
			local T = self.Hub.ThemeManager:GetTheme()
			if self.CurrentSubTabId ~= id then
				InstanceUtil.Tween(btn, Defaults.Tween.AnimConfig, { BackgroundColor3 = T.ButtonHover })
			end
		end)
		self.Hub:AddConnection(btn.MouseLeave, function()
			local T = self.Hub.ThemeManager:GetTheme()
			if self.CurrentSubTabId ~= id then
				InstanceUtil.Tween(btn, Defaults.Tween.AnimConfig, { BackgroundColor3 = T.Button })
			end
		end)
		self.Hub:AddConnection(btn.MouseButton1Click, function()
			self:_SwitchSubTab(id)
		end)

		self.SubTabs[id] = {
			Button = btn,
			Label = label,
			Page = page,
		}

		if self.Hub and self.Hub.RegisterSidebarSubTab then
			self.Hub:RegisterSidebarSubTab(self.Id, id, localeKey)
		end
	end

	-- Se for a primeira SubAba, seleciona automaticamente.
	if not self.CurrentSubTabId then
		self:_SwitchSubTab(id)
	else
		self:_SwitchSubTab(id)
	end

	return self
end

function Tab:AddSectionTitle(def)
	return self.Hub:_CreateSectionTitle(self:_GetActivePage(), def.LocaleKey, def.Text, def.Position)
end

function Tab:AddToggle(def)
	local option = Option.new(def)
	option.Type = "Toggle"
	local widget = self.Hub.Components.Toggle.Create(self.Hub:_ComponentContext(), self:_GetActivePage(), option
		.Position, option.LocaleKey, option.Default, option.Size)
	self.Hub:AddConnection(widget.Changed, function(value)
		self.Hub.Registry:Set(option.Id, value)
		if type(option.Callback) == "function" then
			pcall(option.Callback, value)
		end
		local label = self.Hub:GetText(option.LocaleKey)
		local status = value and self.Hub:GetText("msg_on") or self.Hub:GetText("msg_off")
		self.Hub:ShowWarning(label .. ": " .. status, "info")
	end)
	self.Hub.Registry:Register(option, widget)
	self.Hub.OptionToggles[option.Id] = widget
	return widget
end

function Tab:AddCheckbox(def)
	local option = Option.new(def)
	option.Type = "Checkbox"
	local widget = self.Hub.Components.Checkbox.Create(self.Hub:_ComponentContext(), self:_GetActivePage(),
		option.Position, option.LocaleKey, option.Default)
	self.Hub:AddConnection(widget.Changed, function(value)
		self.Hub.Registry:Set(option.Id, value)
		if type(option.Callback) == "function" then
			pcall(option.Callback, value)
		end
		local label = self.Hub:GetText(option.LocaleKey)
		local status = value and self.Hub:GetText("msg_on") or self.Hub:GetText("msg_off")
		self.Hub:ShowWarning(label .. ": " .. status, "info")
	end)
	self.Hub.Registry:Register(option, widget)
	self.Hub.OptionToggles[option.Id] = widget
	return widget
end

function Tab:AddSlider(def)
	local option = Option.new(def)
	option.Type = "Slider"
	local widget = self.Hub.Components.Slider.Create(
		self.Hub:_ComponentContext(),
		self:_GetActivePage(),
		option.Position,
		option.LocaleKey,
		option.Min,
		option.Max,
		option.Default,
		option.Size
	)
	self.Hub:AddConnection(widget.Changed, function(value)
		self.Hub.Registry:Set(option.Id, value)
		if type(option.Callback) == "function" then
			pcall(option.Callback, value)
		end
	end)
	self.Hub.Registry:Register(option, widget)
	return widget
end

function Tab:AddDropdown(def)
	local option = Option.new(def)
	option.Type = "Dropdown"
	local options = option.Options
	if type(option.OptionsKeys) == "table" then
		options = {}
		for i, k in ipairs(option.OptionsKeys) do
			options[i] = self.Hub:GetText(k)
		end
	end
	local widget = self.Hub.Components.Dropdown.Create(
		self.Hub:_ComponentContext(),
		self:_GetActivePage(),
		option.Position,
		option.LocaleKey,
		options,
		option.DefaultIndex
	)
	if type(option.OptionsKeys) == "table" and self.Hub and type(self.Hub.RegisterLocalizedOptions) == "function" then
		self.Hub:RegisterLocalizedOptions(widget, option.OptionsKeys)
	end
	self.Hub:AddConnection(widget.Changed, function(text, idx)
		self.Hub.Registry:Set(option.Id, text, idx)
		if type(option.Callback) == "function" then
			pcall(option.Callback, text, idx)
		end
	end)
	self.Hub.Registry:Register(option, widget)
	return widget
end

function Tab:AddMultiDropdown(def)
	local option = Option.new(def)
	option.Type = "MultiDropdown"
	local widget = self.Hub.Components.MultiDropdown.Create(
		self.Hub:_ComponentContext(),
		self:_GetActivePage(),
		option.Position,
		option.LocaleKey,
		option.Options,
		option.DefaultList
	)
	self.Hub:AddConnection(widget.Changed, function(list)
		self.Hub.Registry:Set(option.Id, list)
		if type(option.Callback) == "function" then
			pcall(option.Callback, list)
		end
	end)
	self.Hub.Registry:Register(option, widget)
	return widget
end

function Tab:AddColorPicker(def)
	local option = Option.new(def)
	option.Type = "ColorPicker"
	local widget = self.Hub.Components.ColorPicker.Create(
		self.Hub:_ComponentContext(),
		self:_GetActivePage(),
		option.Position,
		option.LocaleKey,
		option.Default
	)
	self.Hub:AddConnection(widget.Changed, function(color)
		self.Hub.Registry:Set(option.Id, color)
		if type(option.Callback) == "function" then
			pcall(option.Callback, color)
		end
	end)
	self.Hub.Registry:Register(option, widget)
	return widget
end

function Tab:AddButton(def)
	local option = Option.new(def)
	option.Type = "Button"
	local widget = self.Hub.Components.Button.Create(self.Hub:_ComponentContext(), self:_GetActivePage(), option
		.Position, option.LocaleKey)
	self.Hub:AddConnection(widget.Clicked, function()
		self.Hub.Registry:Set(option.Id)
		if type(option.Callback) == "function" then
			pcall(option.Callback)
		end
	end)
	self.Hub.Registry:Register(option, widget)
	return widget
end

function Tab:AddKeybind(def)
	local option = Option.new(def)
	option.Type = "Keybind"
	local widget = self.Hub.Components.Keybind.Create(
		self.Hub:_ComponentContext(),
		self:_GetActivePage(),
		option.Position,
		option.LocaleKey,
		option.Default
	)
	self.Hub:AddConnection(widget.Changed, function(keyCode)
		self.Hub.Registry:Set(option.Id, keyCode)
		if type(option.Callback) == "function" then
			pcall(option.Callback, keyCode)
		end
	end)
	self.Hub.Registry:Register(option, widget)
	return widget
end

return Tab
