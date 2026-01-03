-- Temas Modernos e Profissionais
-- PALETA: DEEP MIDNIGHT & ELECTRIC BLUE (Refined)

local Themes = {
	Midnight = {
		-- Escuro, porém um pouco mais claro (mais "premium" e legível)
		Background = Color3.fromRGB(14, 14, 20),
		Secondary = Color3.fromRGB(20, 20, 28),
		-- Transparências (sem blur)
		AcrylicTransparency = 0.08,
		PanelTransparency = 0.08,
		SurfaceTransparency = 0.08,
		ControlTransparency = 0.08,
		NotificationTransparency = 0.08,
		CardTransparency = 0.08,
		PageTransparency = 0.08,
		FloatingButtonTransparency = 0.08,
		SeparatorTransparency = 0.08,
		Separator = Color3.fromRGB(30, 30, 42),
		Accent = Color3.fromRGB(45, 105, 250),
		AccentDark = Color3.fromRGB(85, 90, 120),
		TextPrimary = Color3.fromRGB(245, 245, 255),
		TextSecondary = Color3.fromRGB(160, 165, 185),
		Button = Color3.fromRGB(26, 26, 38),
		ButtonHover = Color3.fromRGB(36, 36, 52),
		IndicatorOff = Color3.fromRGB(34, 34, 48),
		IndicatorOn = Color3.fromRGB(45, 105, 250),
		Border = Color3.fromRGB(0, 0, 0),
		Stroke = Color3.fromRGB(48, 48, 70),
		Error = Color3.fromRGB(255, 70, 70),
		Warning = Color3.fromRGB(255, 170, 40),
		Status = Color3.fromRGB(45, 105, 250),
	},

	-- Tema claro (Branco/Cinza/Preto) bem clean
	Monochrome = {
		Background = Color3.fromRGB(245, 245, 245),
		Secondary = Color3.fromRGB(235, 235, 235),
		AcrylicTransparency = 0.02,
		PanelTransparency = 0.02,
		SurfaceTransparency = 0.02,
		ControlTransparency = 0.02,
		NotificationTransparency = 0.02,
		CardTransparency = 0.02,
		PageTransparency = 0.02,
		FloatingButtonTransparency = 0.02,
		SeparatorTransparency = 0.04,
		Separator = Color3.fromRGB(210, 210, 210),
		Accent = Color3.fromRGB(25, 25, 25),
		AccentDark = Color3.fromRGB(70, 70, 70),
		TextPrimary = Color3.fromRGB(20, 20, 20),
		TextSecondary = Color3.fromRGB(95, 95, 95),
		Button = Color3.fromRGB(252, 252, 252),
		ButtonHover = Color3.fromRGB(240, 240, 240),
		IndicatorOff = Color3.fromRGB(205, 205, 205),
		IndicatorOn = Color3.fromRGB(25, 25, 25),
		Border = Color3.fromRGB(0, 0, 0),
		Stroke = Color3.fromRGB(195, 195, 195),
		Error = Color3.fromRGB(215, 55, 55),
		Warning = Color3.fromRGB(210, 135, 35),
		Status = Color3.fromRGB(25, 25, 25),
	},
}

return Themes
