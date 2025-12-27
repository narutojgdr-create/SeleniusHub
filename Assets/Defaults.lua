local Defaults = {}

Defaults.CONFIG_FOLDER = "SeleniusHub"
Defaults.CONFIGS_DIR = Defaults.CONFIG_FOLDER .. "/Configs"
Defaults.IMAGE_FOLDER = Defaults.CONFIG_FOLDER .. "/imagens"

Defaults.Tween = {
	AnimConfig = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	DropdownTween = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
	SliderTween = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	PopTween = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	PopReturnTween = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}

return Defaults
