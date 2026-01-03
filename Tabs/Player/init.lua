return function(Tab)
	local function P(y)
		return UDim2.new(0, 20, 0, y)
	end

	-- Movement
	Tab:AddSectionTitle({ LocaleKey = "section_player_movement", Text = "Movement", Position = UDim2.new(0, 10, 0, 10) })
	Tab:AddToggle({ Id = "player_sprint", LocaleKey = "player_sprint", Position = P(60), Default = false })
	Tab:AddSlider({ Id = "player_speed", LocaleKey = "player_speed", Position = P(110), Min = 1, Max = 100, Default = 16 })
	Tab:AddSlider({ Id = "player_jump", LocaleKey = "player_jump", Position = P(170), Min = 1, Max = 150, Default = 50 })

	-- Utility
	Tab:AddSectionTitle({ LocaleKey = "section_player_utility", Text = "Utility", Position = UDim2.new(0, 10, 0, 240) })
	Tab:AddToggle({ Id = "player_autorejoin", LocaleKey = "player_autorejoin", Position = P(290), Default = false })
	Tab:AddKeybind({ Id = "player_panic", LocaleKey = "player_panic", Position = P(350), Default = Enum.KeyCode.P })

	-- Safety
	Tab:AddSectionTitle({ LocaleKey = "section_player_safety", Text = "Safety", Position = UDim2.new(0, 10, 0, 420) })
	Tab:AddToggle({ Id = "player_safe_mode", LocaleKey = "player_safe_mode", Position = P(470), Default = true })
end
