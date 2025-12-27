local Option = require(script.Parent.Option)

local Tab = {}
Tab.__index = Tab

function Tab.new(hub, id, page)
	local self = setmetatable({}, Tab)
	self.Hub = hub
	self.Id = id
	self.Page = page
	return self
end

function Tab:AddSectionTitle(def)
	return self.Hub:_CreateSectionTitle(self.Page, def.LocaleKey, def.Text, def.Position)
end

function Tab:AddToggle(def)
	local option = Option.new(def)
	option.Type = "Toggle"
	local widget = self.Hub.Components.Toggle.Create(self.Hub:_ComponentContext(), self.Page, option.Position, option.LocaleKey, option.Default, option.Size)
	widget.Changed:Connect(function(value)
		self.Hub.Registry:Set(option.Id, value)
	end)
	self.Hub.Registry:Register(option, widget)
	return widget
end

function Tab:AddCheckbox(def)
	local option = Option.new(def)
	option.Type = "Checkbox"
	local widget = self.Hub.Components.Checkbox.Create(self.Hub:_ComponentContext(), self.Page, option.Position, option.LocaleKey, option.Default)
	widget.Changed:Connect(function(value)
		self.Hub.Registry:Set(option.Id, value)
	end)
	self.Hub.Registry:Register(option, widget)
	return widget
end

function Tab:AddSlider(def)
	local option = Option.new(def)
	option.Type = "Slider"
	local widget = self.Hub.Components.Slider.Create(
		self.Hub:_ComponentContext(),
		self.Page,
		option.Position,
		option.LocaleKey,
		option.Min,
		option.Max,
		option.Default,
		option.Size
	)
	widget.Changed:Connect(function(value)
		self.Hub.Registry:Set(option.Id, value)
	end)
	self.Hub.Registry:Register(option, widget)
	return widget
end

function Tab:AddDropdown(def)
	local option = Option.new(def)
	option.Type = "Dropdown"
	local widget = self.Hub.Components.Dropdown.Create(
		self.Hub:_ComponentContext(),
		self.Page,
		option.Position,
		option.LocaleKey,
		option.Options,
		option.DefaultIndex
	)
	widget.Changed:Connect(function(text, idx)
		self.Hub.Registry:Set(option.Id, text, idx)
	end)
	self.Hub.Registry:Register(option, widget)
	return widget
end

function Tab:AddMultiDropdown(def)
	local option = Option.new(def)
	option.Type = "MultiDropdown"
	local widget = self.Hub.Components.MultiDropdown.Create(
		self.Hub:_ComponentContext(),
		self.Page,
		option.Position,
		option.LocaleKey,
		option.Options,
		option.DefaultList
	)
	widget.Changed:Connect(function(list)
		self.Hub.Registry:Set(option.Id, list)
	end)
	self.Hub.Registry:Register(option, widget)
	return widget
end

function Tab:AddColorPicker(def)
	local option = Option.new(def)
	option.Type = "ColorPicker"
	local widget = self.Hub.Components.ColorPicker.Create(
		self.Hub:_ComponentContext(),
		self.Page,
		option.Position,
		option.LocaleKey,
		option.Default
	)
	widget.Changed:Connect(function(color)
		self.Hub.Registry:Set(option.Id, color)
	end)
	self.Hub.Registry:Register(option, widget)
	return widget
end

function Tab:AddButton(def)
	local option = Option.new(def)
	option.Type = "Button"
	local widget = self.Hub.Components.Button.Create(self.Hub:_ComponentContext(), self.Page, option.Position, option.LocaleKey)
	widget.Clicked:Connect(function()
		self.Hub.Registry:Set(option.Id)
	end)
	self.Hub.Registry:Register(option, widget)
	return widget
end

return Tab
