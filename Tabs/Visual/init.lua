local Logic = require(script.Parent.logic)

return function(Tab)
	Tab:AddSectionTitle({
		LocaleKey = "section_visuals",
		Text = nil,
		Position = UDim2.new(0, 10, 0, 10),
	})

	Tab:AddToggle({
		Id = "visuals_esp",
		LocaleKey = "Enable ESP",
		Default = false,
		Position = UDim2.new(0, 10, 0, 50),
		Callback = Logic.OnEspChanged,
	})

	Tab:AddColorPicker({
		Id = "visuals_esp_color",
		LocaleKey = "ESP Color",
		Default = Color3.fromRGB(255, 0, 0),
		Position = UDim2.new(0, 10, 0, 90),
		Callback = Logic.OnEspColorChanged,
	})

	Tab:AddMultiDropdown({
		Id = "visuals_esp_features",
		LocaleKey = "ESP Features",
		Options = { "Box", "Name", "Distance", "Health", "Skeleton" },
		DefaultList = { "Box", "Name" },
		Position = UDim2.new(0, 10, 0, 130),
		Callback = Logic.OnEspFeaturesChanged,
	})
end
