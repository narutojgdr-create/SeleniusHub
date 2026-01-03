-- !!! ULTRA PROTEÇÃO !!!
local function safeGetService(name)
	local ok, svc = pcall(function() return game:GetService(name) end)
	if ok and svc then return svc end
	return nil
end

local TweenService = safeGetService("TweenService")

local Tween = {}

function Tween.Play(object, tweenInfo, properties)
	local tween = TweenService:Create(object, tweenInfo, properties)
	tween:Play()
	return tween
end

return Tween
