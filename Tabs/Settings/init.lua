return function(Tab)
	Tab:SubTab("Geral")
	Tab:AddSectionTitle({
		Text = "Geral",
		Position = UDim2.new(0, 10, 0, 10),
	})

	Tab:SubTab("Sobre")
	Tab:AddSectionTitle({
		Text = "Sobre",
		Position = UDim2.new(0, 10, 0, 10),
	})
end
