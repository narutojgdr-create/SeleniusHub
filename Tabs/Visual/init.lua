return function(Tab)
	local function P(y)
		return UDim2.new(0, 20, 0, y)
	end

	Tab:SubTab("esp", "sub_visuals_esp")
	Tab:AddSectionTitle({ LocaleKey = "section_visuals_esp", Text = "ESP", Position = UDim2.new(0, 10, 0, 10) })
	Tab:AddToggle({ Id = "visual_esp_enabled", LocaleKey = "visual_esp_enabled", Position = P(60), Default = false })
	Tab:AddCheckbox({ Id = "visual_esp_boxes", LocaleKey = "visual_esp_boxes", Position = P(110), Default = true })
	Tab:AddCheckbox({ Id = "visual_esp_names", LocaleKey = "visual_esp_names", Position = P(150), Default = true })
	Tab:AddSlider({ Id = "visual_esp_distance", LocaleKey = "visual_esp_distance", Position = P(200), Min = 50, Max = 3000, Default = 800 })

	Tab:SubTab("ui", "sub_visuals_ui")
	Tab:AddSectionTitle({ LocaleKey = "section_visuals_ui", Text = "Interface", Position = UDim2.new(0, 10, 0, 10) })
	Tab:AddToggle({ Id = "visual_ui_blur", LocaleKey = "visual_ui_blur", Position = P(60), Default = true })
	Tab:AddToggle({ Id = "visual_ui_particles", LocaleKey = "visual_ui_particles", Position = P(110), Default = false })

	Tab:SubTab("colors", "sub_visuals_colors")
	Tab:AddSectionTitle({ LocaleKey = "section_visuals_colors", Text = "Cores", Position = UDim2.new(0, 10, 0, 10) })
	Tab:AddColorPicker({ Id = "visual_color_accent", LocaleKey = "visual_color_accent", Position = P(60), Default =
	Color3.fromRGB(45, 105, 250) })
	Tab:AddColorPicker({ Id = "visual_color_enemy", LocaleKey = "visual_color_enemy", Position = P(110), Default = Color3
	.fromRGB(255, 70, 70) })
end
