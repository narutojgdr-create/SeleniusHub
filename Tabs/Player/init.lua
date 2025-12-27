local Logic = require(script.Parent.logic)

return function(Tab)
	Tab:AddSectionTitle({
		LocaleKey = "section_player",
		Text = nil,
		Position = UDim2.new(0, 10, 0, 10),
	})

	Tab:AddSlider({
		Id = "player_walkspeed",
		LocaleKey = "WalkSpeed",
		Min = 16,
		Max = 200,
		Default = 16,
		Position = UDim2.new(0, 10, 0, 50),
		Callback = Logic.SetWalkSpeed,
	})

	Tab:AddSlider({
		Id = "player_jumppower",
		LocaleKey = "JumpPower",
		Min = 50,
		Max = 500,
		Default = 50,
		Position = UDim2.new(0, 10, 0, 110),
		Callback = Logic.SetJumpPower,
	})

	Tab:AddButton({
		Id = "player_respawn",
		LocaleKey = "Respawn Character",
		Position = UDim2.new(0, 10, 0, 170),
		Callback = Logic.Respawn,
	})
end
