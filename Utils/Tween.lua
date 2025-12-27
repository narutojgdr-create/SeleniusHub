local TweenService = game:GetService("TweenService")

local Tween = {}

function Tween.Play(object, tweenInfo, properties)
	local tween = TweenService:Create(object, tweenInfo, properties)
	tween:Play()
	return tween
end

return Tween
