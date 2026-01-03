-- !!! ULTRA PROTEÇÃO !!!
local function safeRequire(mod)
	local ok, result = pcall(function() return require(mod) end)
	if ok and result then return result end
	return {}
end

local Assets = safeRequire(script.Parent.Parent.Parent.Utils.Assets)

return function(Tab)
	local Hub = Tab.Hub
	local function P(y)
		return UDim2.new(0, 20, 0, y)
	end

	-- =====================
	-- Geral
	-- =====================
	Tab:AddSectionTitle({
		LocaleKey = "section_settings_general",
		Text = "Geral",
		Position = UDim2.new(0, 10, 0, 10),
	})

	-- Tema
	local themeNames = {}
	local themes = Hub.ThemeManager and Hub.ThemeManager.GetThemes and Hub.ThemeManager.GetThemes() or {}
	for name, _ in pairs(themes or {}) do
		table.insert(themeNames, tostring(name))
	end
	table.sort(themeNames)
	for i, n in ipairs(themeNames) do
		if n == "Midnight" then
			table.remove(themeNames, i)
			table.insert(themeNames, 1, "Midnight")
			break
		end
	end

	Tab:AddDropdown({
		Id = "ui_theme",
		LocaleKey = "label_theme",
		Position = P(60),
		Options = themeNames,
		DefaultIndex = (function()
			local current = Hub.CurrentThemeName or "Midnight"
			for i, n in ipairs(themeNames) do
				if n == current then
					return i
				end
			end
			return 1
		end)(),
		Callback = function(themeName)
			if type(themeName) == "string" and themeName ~= "" then
				Hub:SetTheme(themeName)
			end
		end,
	})

	-- Idioma
	local languageDropdown = Tab:AddDropdown({
		Id = "ui_language",
		LocaleKey = "label_language",
		Position = P(110),
		OptionsKeys = { "lang_pt", "lang_en" },
		DefaultIndex = (Hub.Locale == "en") and 2 or 1,
		Callback = function(_text, idx)
			if idx == 2 then
				Hub:SetLanguage("en")
			else
				Hub:SetLanguage("pt")
			end
		end,
	})
	Hub.LanguageDropdown = languageDropdown

	-- Tecla do menu
	Tab:AddKeybind({
		Id = "ui_keybind",
		LocaleKey = "label_keybind",
		Position = P(160),
		Default = Hub.Keybind,
		Callback = function(keyCode)
			if keyCode then
				Hub.Keybind = keyCode
				Hub:OnKeybindChanged()
			end
		end,
	})

	-- Anti-AFK
	Tab:AddToggle({
		Id = "settings_antiafk",
		LocaleKey = "label_antiafk",
		Position = P(220),
		Default = (Hub.State and Hub.State.Settings and Hub.State.Settings.AntiAFK) or false,
		Callback = function(v)
			if Hub.State and Hub.State.Settings then
				Hub.State.Settings.AntiAFK = (v == true)
			end
		end,
	})

	-- =====================
	-- Configs
	-- =====================
	Tab:AddSectionTitle({
		LocaleKey = "label_config_system",
		Text = "Sistema de Configs",
		Position = UDim2.new(0, 10, 0, 290),
	})

	local selectedConfig = Hub.SelectedConfig or "default"
	local cfgList = Assets.GetConfigList()
	local defaultIdx = 1
	for i, name in ipairs(cfgList) do
		if name == selectedConfig then
			defaultIdx = i
			break
		end
	end

	local cfgDropdown = Tab:AddDropdown({
		Id = "settings_cfg_select",
		LocaleKey = "label_select_cfg",
		Position = P(340),
		Options = cfgList,
		DefaultIndex = defaultIdx,
		Callback = function(text)
			if type(text) == "string" and text ~= "" then
				selectedConfig = text
				Hub.SelectedConfig = text
			end
		end,
	})

	Tab:AddButton({
		Id = "settings_cfg_refresh",
		LocaleKey = "label_refresh",
		Position = P(390),
		Callback = function()
			local list = Assets.GetConfigList()
			if cfgDropdown and cfgDropdown.UpdateOptions then
				cfgDropdown.UpdateOptions(list)
			end
		end,
	})

	Tab:AddButton({
		Id = "settings_cfg_load",
		LocaleKey = "label_load",
		Position = P(436),
		Callback = function()
			Hub:LoadConfig(selectedConfig)
		end,
	})

	Tab:AddButton({
		Id = "settings_cfg_save",
		LocaleKey = "label_save",
		Position = P(482),
		Callback = function()
			Hub:SaveConfig(selectedConfig)
		end,
	})

	-- =====================
	-- Sobre
	-- =====================
	Tab:AddSectionTitle({
		LocaleKey = "section_settings_about",
		Text = "Sobre",
		Position = UDim2.new(0, 10, 0, 552),
	})

	Tab:AddButton({
		Id = "about_credit",
		LocaleKey = "label_home_credit",
		Position = P(602),
		Callback = function()
			Hub:ShowWarning(Hub:GetText("label_home_credit"), "info")
		end,
	})

	Tab:AddButton({
		Id = "about_discord",
		LocaleKey = "label_home_discord",
		Position = P(648),
		Callback = function()
			Hub:ShowWarning(Hub:GetText("label_home_discord"), "info")
		end,
	})
end
