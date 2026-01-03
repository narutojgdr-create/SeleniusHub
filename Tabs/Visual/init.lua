return function(Tab)
	local function P(y)
		return UDim2.new(0, 20, 0, y)
	end

	-- ESP
	Tab:AddSectionTitle({ LocaleKey = "section_visuals_esp", Text = "ESP", Position = UDim2.new(0, 10, 0, 10) })
	Tab:AddToggle({ Id = "visual_esp_enabled", LocaleKey = "visual_esp_enabled", Position = P(60), Default = false })
	Tab:AddCheckbox({ Id = "visual_esp_boxes", LocaleKey = "visual_esp_boxes", Position = P(110), Default = true })
	Tab:AddCheckbox({ Id = "visual_esp_names", LocaleKey = "visual_esp_names", Position = P(150), Default = true })
	Tab:AddSlider({ Id = "visual_esp_distance", LocaleKey = "visual_esp_distance", Position = P(200), Min = 50, Max = 3000, Default = 800 })

	-- Interface
	Tab:AddSectionTitle({ LocaleKey = "section_visuals_ui", Text = "Interface", Position = UDim2.new(0, 10, 0, 270) })
	Tab:AddToggle({ Id = "visual_ui_blur", LocaleKey = "visual_ui_blur", Position = P(320), Default = true })
	Tab:AddToggle({ Id = "visual_ui_particles", LocaleKey = "visual_ui_particles", Position = P(370), Default = false })

	-- Colors
	Tab:AddSectionTitle({ LocaleKey = "section_visuals_colors", Text = "Cores", Position = UDim2.new(0, 10, 0, 440) })
	Tab:AddColorPicker({ Id = "visual_color_accent", LocaleKey = "visual_color_accent", Position = P(490), Default =
	Color3.fromRGB(45, 105, 250) })
	Tab:AddColorPicker({ Id = "visual_color_enemy", LocaleKey = "visual_color_enemy", Position = P(540), Default = Color3
	.fromRGB(255, 70, 70) })
end
