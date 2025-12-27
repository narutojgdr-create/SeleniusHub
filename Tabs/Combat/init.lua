local Logic = require(script.Parent.logic)

return function(Tab)
	Tab:AddSectionTitle({
		LocaleKey = "section_combat",
		Text = nil,
		Position = UDim2.new(0, 10, 0, 10),
	})

	Tab:AddToggle({
		Id = "combat_aimbot",
		LocaleKey = "Enable Aimbot",
		Default = false,
		Position = UDim2.new(0, 10, 0, 50),
		Callback = Logic.OnAimbotChanged,
	})

	Tab:AddCheckbox({
		Id = "combat_silent",
		LocaleKey = "Silent Aim",
		Default = true,
		Position = UDim2.new(0, 10, 0, 90),
		Callback = Logic.OnSilentAimChanged,
	})

	Tab:AddSlider({
		Id = "combat_fov",
		LocaleKey = "FOV Radius",
		Min = 0,
		Max = 500,
		Default = 150,
		Position = UDim2.new(0, 10, 0, 130),
		Callback = Logic.OnFovChanged,
	})

	Tab:AddSectionTitle({
		LocaleKey = nil,
		Text = "Target Selection",
		Position = UDim2.new(0, 10, 0, 190),
	})

	Tab:AddDropdown({
		Id = "combat_target_part",
		LocaleKey = "Target Part",
		Options = { "Head", "Torso", "Random" },
		DefaultIndex = 1,
		Position = UDim2.new(0, 10, 0, 230),
		Callback = Logic.OnTargetPartChanged,
	})
end
