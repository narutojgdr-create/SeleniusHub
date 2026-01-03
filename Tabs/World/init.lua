return function(Tab)
	local function P(y)
		return UDim2.new(0, 20, 0, y)
	end

	-- =====================
	-- Geral
	-- =====================
	Tab:SubTab("general", "sub_world_general")
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

	-- =====================
	-- Teleporte
	-- =====================
	Tab:SubTab("teleport", "sub_world_teleport")
	Tab:AddSectionTitle({ LocaleKey = "section_world_teleport", Text = "Teleport", Position = UDim2.new(0, 10, 0, 10) })
	Tab:AddDropdown({
		Id = "world_tp_preset",
		LocaleKey = "world_tp_preset",
		Position = P(60),
		Options = { "Spawn", "Shop", "Quest", "Custom" },
		DefaultIndex = 1,
	})
	Tab:AddButton({ Id = "world_tp_go", LocaleKey = "world_tp_go", Position = P(110) })
	Tab:AddKeybind({ Id = "world_tp_key", LocaleKey = "world_tp_key", Position = P(156), Default = Enum.KeyCode.T })

	-- =====================
	-- Servidor
	-- =====================
	Tab:SubTab("server", "sub_world_server")
	Tab:AddSectionTitle({ LocaleKey = "section_world_server", Text = "Servidor", Position = UDim2.new(0, 10, 0, 10) })
	Tab:AddButton({ Id = "world_rejoin", LocaleKey = "world_rejoin", Position = P(60) })
	Tab:AddButton({ Id = "world_serverhop", LocaleKey = "world_serverhop", Position = P(106) })
end
