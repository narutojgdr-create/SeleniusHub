local Assets = require(script.Parent.Parent.Utils.Assets)
local Themes = require(script.Parent.Parent.Theme.Themes)
local Defaults = require(script.Parent.Parent.Assets.Defaults)
local InstanceUtil = require(script.Parent.Parent.Utils.Instance)

local function sortedThemeNames()
	local list = {}
	for name in pairs(Themes) do
		table.insert(list, name)
	end
	table.sort(list)
	return list
end

local function indexOf(list, value)
	for i, v in ipairs(list) do
		if v == value then
			return i
		end
	end
	return 1
end

return function(Tab)
	local hub = Tab.Hub
	local page = Tab.Page

	Tab:AddSectionTitle({
		LocaleKey = "section_settings",
		Text = nil,
		Position = UDim2.new(0, 10, 0, 10),
	})

	local themeNames = sortedThemeNames()
	Tab:AddDropdown({
		Id = "settings_theme",
		LocaleKey = "label_theme",
		Options = themeNames,
		DefaultIndex = indexOf(themeNames, hub.CurrentThemeName),
		Position = UDim2.new(0, 10, 0, 50),
		Callback = function(name)
			hub:SetTheme(name)
		end,
	})

	local langDropdown = Tab:AddDropdown({
		Id = "settings_language",
		LocaleKey = "label_language",
		Options = { hub:GetText("lang_pt"), hub:GetText("lang_en") },
		DefaultIndex = (hub.Locale == "en") and 2 or 1,
		Position = UDim2.new(0, 10, 0, 90),
		Callback = function(_, idx)
			if idx == 2 then
				hub:SetLanguage("en")
			else
				hub:SetLanguage("pt")
			end
		end,
	})
	hub.LanguageDropdown = langDropdown

	hub:CreateKeybindControl(page, UDim2.new(0, 10, 0, 130))

	local testKeybind = Tab:AddKeybind({
		Id = "settings_test_keybind",
		LocaleKey = "Keybind de teste",
		Default = Enum.KeyCode.K,
		Position = UDim2.new(0, 10, 0, 175),
		Callback = function(keyCode)
			hub:RegisterKeybind("test", keyCode, function()
				hub:ShowWarning("Keybind de teste acionado", "info")
			end)
		end,
	})
	-- Inicializa callback do bind de teste
	hub:RegisterKeybind("test", testKeybind.GetKey(), function()
		hub:ShowWarning("Keybind de teste acionado", "info")
	end)

	Tab:AddToggle({
		Id = "settings_antiafk",
		LocaleKey = "label_antiafk",
		Default = hub.State.Settings.AntiAFK,
		Position = UDim2.new(0, 10, 0, 220),
		Callback = function(value)
			hub.State.Settings.AntiAFK = value and true or false
		end,
	})

	Tab:AddSectionTitle({
		LocaleKey = "label_config_system",
		Text = nil,
		Position = UDim2.new(0, 10, 0, 270),
	})

	local configList = Assets.GetConfigList()
	local cfgDropdown = Tab:AddDropdown({
		Id = "settings_config_select",
		LocaleKey = "label_select_cfg",
		Options = configList,
		DefaultIndex = indexOf(configList, hub.SelectedConfig or "default"),
		Position = UDim2.new(0, 10, 0, 305),
		Callback = function(name)
			hub.SelectedConfig = name
		end,
	})
	hub.SelectedConfig = configList[1] or hub.SelectedConfig or "default"

	local Theme = hub.ThemeManager:GetTheme()
	local nameBox = InstanceUtil.Create("TextBox", {
		BackgroundColor3 = Theme.Button,
		BackgroundTransparency = 0.3,
		Position = UDim2.new(0, 10, 0, 345),
		Size = UDim2.new(0, 260, 0, 32),
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.TextPrimary,
		PlaceholderText = hub:GetText("label_new_cfg_ph"),
		PlaceholderColor3 = Theme.AccentDark,
		ClearTextOnFocus = false,
		Text = "",
		Parent = page,
	})
	InstanceUtil.AddCorner(nameBox, 6)
	InstanceUtil.AddStroke(nameBox, Theme.Stroke, 1, 0.5)
	hub.ThemeManager:Register(nameBox, "TextColor3", "TextPrimary")
	hub.ThemeManager:Register(nameBox, "PlaceholderColor3", "AccentDark")
	hub.ThemeManager:AddCallback(function()
		local T = hub.ThemeManager:GetTheme()
		nameBox.BackgroundColor3 = T.Button
	end)

	Tab:AddButton({
		Id = "settings_config_create",
		LocaleKey = "label_create",
		Position = UDim2.new(0, 10, 0, 385),
		Callback = function()
			local name = (nameBox.Text and nameBox.Text:gsub("%s+", "")) or ""
			if name == "" then
				hub:ShowWarning("Nome inválido", "warn")
				return
			end
			hub:SaveConfig(name)
			cfgDropdown.UpdateOptions(Assets.GetConfigList())
			if cfgDropdown.currentLabel then
				cfgDropdown.currentLabel.Text = name
			end
			hub.SelectedConfig = name
			nameBox.Text = ""
		end,
	})

	Tab:AddButton({
		Id = "settings_config_save",
		LocaleKey = "label_save",
		Position = UDim2.new(0, 10, 0, 425),
		Callback = function()
			hub:SaveConfig(hub.SelectedConfig or "default")
		end,
	})

	Tab:AddButton({
		Id = "settings_config_load",
		LocaleKey = "label_load",
		Position = UDim2.new(0, 10, 0, 465),
		Callback = function()
			hub:LoadConfig(hub.SelectedConfig or "default")
		end,
	})

	Tab:AddButton({
		Id = "settings_config_refresh",
		LocaleKey = "label_refresh",
		Position = UDim2.new(0, 10, 0, 505),
		Callback = function()
			cfgDropdown.UpdateOptions(Assets.GetConfigList())
			hub:ShowWarning("Lista atualizada", "info")
		end,
	})

	Tab:AddButton({
		Id = "settings_config_reset",
		LocaleKey = "label_reset",
		Position = UDim2.new(0, 10, 0, 545),
		Callback = function()
			hub:ShowConfirmation(hub:GetText("confirm_reset"), function()
				hub.State.Settings.AntiAFK = false
				if hub.OptionToggles["settings_antiafk"] then
					hub.OptionToggles["settings_antiafk"].SetState(false)
				end
				hub.Keybind = Enum.KeyCode.RightControl
				hub.CurrentThemeName = "Midnight"
				hub:SetTheme("Midnight")
				hub:SetLanguage("pt")
				hub:OnKeybindChanged()
				hub:ShowWarning("Resetado", "info")
			end)
		end,
	})

	Tab:AddSectionTitle({
		LocaleKey = nil,
		Text = "",
		Position = UDim2.new(0, 10, 0, 590),
	})

	Tab:AddButton({
		Id = "settings_reinject",
		LocaleKey = "label_reinject",
		Position = UDim2.new(0, 10, 0, 610),
		Callback = function()
			hub:ShowConfirmation(hub:GetText("confirm_reinject"), function()
				if typeof(_G) == "table" and typeof(_G.SeleniusHubReload) == "function" then
					_G.SeleniusHubReload()
				else
					hub:ShowWarning("Reload indisponível", "error")
				end
			end)
		end,
	})

	Tab:AddButton({
		Id = "settings_destroy",
		LocaleKey = "label_destroy",
		Position = UDim2.new(0, 10, 0, 650),
		Callback = function()
			hub:ShowConfirmation(hub:GetText("confirm_destroy"), function()
				hub:Destroy()
			end)
		end,
	})
end
