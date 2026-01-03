-- !!! ULTRA PROTEÇÃO !!!
local function safeRequire(mod)
	local ok, result = pcall(function() return require(mod) end)
	if ok and result then return result end
	return {}
end

local Option = safeRequire(script.Parent.Option)
local Defaults = safeRequire(script.Parent.Parent.Assets.Defaults)
local InstanceUtil = safeRequire(script.Parent.Parent.Utils.Instance)
local ComponentRefs = {
	Toggle = script.Parent.Parent.Components.Toggle,
	Checkbox = script.Parent.Parent.Components.Checkbox,
	Slider = script.Parent.Parent.Components.Slider,
	Dropdown = script.Parent.Parent.Components.Dropdown,
	MultiDropdown = script.Parent.Parent.Components.MultiDropdown,
	ColorPicker = script.Parent.Parent.Components.ColorPicker,
	Button = script.Parent.Parent.Components.Button,
	Keybind = script.Parent.Parent.Components.Keybind,
}

local Tab = {}
Tab.__index = Tab

local function getComponent(self, key)
	self.Hub.Components = self.Hub.Components or {}
	if self.Hub.Components[key] then
		return self.Hub.Components[key]
	end
	local ref = ComponentRefs[key]
	if not ref then
		return nil
	end
	local mod = safeRequire(ref)
	if mod then
		self.Hub.Components[key] = mod
	end
	return mod
end

function Tab.new(hub, id, page)
	local self = setmetatable({}, Tab)
	self.Hub = hub
	self.Id = id
	self.Page = page
	self.RootPage = page
	return self
end

function Tab:_GetActivePage()
	return self.Page
end

function Tab:AddSectionTitle(def)
	return self.Hub:_CreateSectionTitle(self:_GetActivePage(), def.LocaleKey, def.Text, def.Position)
end

function Tab:AddToggle(def)
	local option = Option.new(def)
	option.Type = "Toggle"
	local component = getComponent(self, "Toggle")
	if not component or not component.Create then
		return nil
	end
	local widget = component.Create(self.Hub:_ComponentContext(), self:_GetActivePage(), option.Position,
		option.LocaleKey, option.Default, option.Size)
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
	local component = getComponent(self, "Checkbox")
	if not component or not component.Create then
		return nil
	end
	local widget = component.Create(self.Hub:_ComponentContext(), self:_GetActivePage(), option.Position,
		option.LocaleKey, option.Default)
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
	local component = getComponent(self, "Slider")
	if not component or not component.Create then
		return nil
	end
	local widget = component.Create(
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
	local component = getComponent(self, "Dropdown")
	if not component or not component.Create then
		return nil
	end
	local widget = component.Create(
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
	local component = getComponent(self, "MultiDropdown")
	if not component or not component.Create then
		return nil
	end
	local widget = component.Create(
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
	local component = getComponent(self, "ColorPicker")
	if not component or not component.Create then
		return nil
	end
	local widget = component.Create(
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
	local component = getComponent(self, "Button")
	if not component or not component.Create then
		return nil
	end
	local widget = component.Create(self.Hub:_ComponentContext(), self:_GetActivePage(), option.Position,
		option.LocaleKey)
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
	local component = getComponent(self, "Keybind")
	if not component or not component.Create then
		return nil
	end
	local widget = component.Create(
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
