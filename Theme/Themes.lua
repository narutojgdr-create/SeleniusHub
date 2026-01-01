-- Temas Modernos e Profissionais
-- PALETA: DEEP MIDNIGHT & ELECTRIC BLUE (Refined)

local Themes = {
	Midnight = {
		-- Escuro, porém um pouco mais claro (mais "premium" e legível)
		Background = Color3.fromRGB(14, 14, 20),
		Secondary = Color3.fromRGB(20, 20, 28),
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
		-- Blur LOCALIZADO (GlassmorphicUI) - só dentro da interface
		GlassBlurRadius = 6,
		GlassTransparency = 0.18,
		NotifBlurRadius = 5,
		NotifGlassTransparency = 0.14,
		-- (compat) antigo Blur global; não usado mais
		BlurSize = 26,
	},
}

return Themes
