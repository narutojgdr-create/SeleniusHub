return function(Tab)
	local function P(y)
		return UDim2.new(0, 20, 0, y)
	end

	-- World General
	Tab:AddSectionTitle({ LocaleKey = "section_world_general", Text = "World", Position = UDim2.new(0, 10, 0, 10) })
	Tab:AddToggle({ Id = "world_enabled", LocaleKey = "world_enabled", Position = P(60), Default = false })
	Tab:AddDropdown({
		Id = "world_target",
		LocaleKey = "world_target",
		Position = P(110),
		Options = { "Nearest", "Objective", "Custom" },
		DefaultIndex = 1,
	})
	Tab:AddSlider({ Id = "world_range", LocaleKey = "world_range", Position = P(170), Min = 50, Max = 5000, Default = 800 })

	-- Teleport
	Tab:AddSectionTitle({ LocaleKey = "section_world_teleport", Text = "Teleport", Position = UDim2.new(0, 10, 0, 240) })
	Tab:AddDropdown({
		Id = "world_tp_preset",
		LocaleKey = "world_tp_preset",
		Position = P(290),
		Options = { "Spawn", "Shop", "Quest", "Custom" },
		DefaultIndex = 1,
	})
	Tab:AddButton({ Id = "world_tp_go", LocaleKey = "world_tp_go", Position = P(340) })
	Tab:AddKeybind({ Id = "world_tp_key", LocaleKey = "world_tp_key", Position = P(386), Default = Enum.KeyCode.T })

	-- Server
	Tab:AddSectionTitle({ LocaleKey = "section_world_server", Text = "Servidor", Position = UDim2.new(0, 10, 0, 456) })
	Tab:AddButton({ Id = "world_rejoin", LocaleKey = "world_rejoin", Position = P(506) })
	Tab:AddButton({ Id = "world_serverhop", LocaleKey = "world_serverhop", Position = P(552) })
end
