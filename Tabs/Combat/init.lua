return function(Tab)
	local function P(y)
		return UDim2.new(0, 20, 0, y)
	end

	Tab:SubTab("aim", "sub_combat_aim")
	Tab:AddSectionTitle({ LocaleKey = "section_combat_aim", Text = "Aim", Position = UDim2.new(0, 10, 0, 10) })
	Tab:AddToggle({ Id = "combat_aim_enabled", LocaleKey = "combat_aim_enabled", Position = P(60), Default = false })
	Tab:AddSlider({ Id = "combat_aim_fov", LocaleKey = "combat_aim_fov", Position = P(110), Min = 10, Max = 360, Default = 120 })
	Tab:AddSlider({ Id = "combat_aim_smooth", LocaleKey = "combat_aim_smooth", Position = P(170), Min = 0, Max = 100, Default = 35 })
	Tab:AddDropdown({
		Id = "combat_aim_mode",
		LocaleKey = "combat_aim_mode",
		Position = P(230),
		Options = { "Closest", "FOV", "Priority" },
		DefaultIndex = 2,
	})

	Tab:SubTab("dashboard", "sub_combat_dashboard")
	Tab:AddSectionTitle({ LocaleKey = "section_combat_dashboard", Text = "Dashboard", Position = UDim2.new(0, 10, 0, 10) })
	Tab:AddToggle({ Id = "combat_dash_enabled", LocaleKey = "combat_dash_enabled", Position = P(60), Default = true })
	Tab:AddMultiDropdown({
		Id = "combat_dash_widgets",
		LocaleKey = "combat_dash_widgets",
		Position = P(110),
		Options = { "FPS", "Ping", "Time", "Server" },
		DefaultList = { "FPS", "Ping" },
	})
	Tab:AddToggle({ Id = "combat_dash_compact", LocaleKey = "combat_dash_compact", Position = P(160), Default = false })
end
