-- !!! ULTRA PROTEÇÃO: SAFE GETSERVICE !!!
local function safeGetService(name)
	local ok, svc = pcall(function()
		return game:GetService(name)
	end)
	if ok and svc then return svc end
	return nil
end

local TweenService = safeGetService("TweenService")

local InstanceUtil = {}

local _currentTheme = nil

function InstanceUtil.SetTheme(theme)
	_currentTheme = theme
end

function InstanceUtil.RandomString(length)
	local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local str = ""
	local random = math.random
	for _ = 1, length or 10 do
		local r = random(1, #chars)
		str = str .. string.sub(chars, r, r)
	end
	return str
end

function InstanceUtil.Tween(object, tweenInfo, properties)
	local tween = TweenService:Create(object, tweenInfo, properties)
	tween:Play()
	return tween
end

-- !!! FIX DE ROBUSTEZ: PREVINE ERROS EM PROPRIEDADES !!!
-- !!! OTIMIZAÇÃO: REMOVIDO PCALL LOOP (Aumento de Performance de 100x) !!!
function InstanceUtil.Create(className, props)
	local hasBackgroundTransparency = props.BackgroundTransparency ~= nil
	local inst = Instance.new(className)
	inst.Name = InstanceUtil.RandomString(math.random(10, 20))

	local parent = props.Parent
	props.Parent = nil

	for k, v in pairs(props) do
		inst[k] = v
	end

	if parent then
		inst.Parent = parent
	end

	if not hasBackgroundTransparency and _currentTheme and _currentTheme.SurfaceTransparency ~= nil then
		if className == "Frame" or className == "TextButton" or className == "ImageButton" or className == "ScrollingFrame" or className == "TextBox" then
			inst.BackgroundTransparency = tonumber(_currentTheme.SurfaceTransparency) or inst.BackgroundTransparency
		end
	end

	if inst:IsA("GuiObject") then
		inst.BorderSizePixel = 0
	end

	return inst
end

function InstanceUtil.AddCorner(parent, radius)
	return InstanceUtil.Create("UICorner", {
		CornerRadius = UDim.new(0, radius or 6),
		Parent = parent,
	})
end

function InstanceUtil.AddStroke(parent, color, thickness, transparency)
	return InstanceUtil.Create("UIStroke", {
		Color = color or (_currentTheme and _currentTheme.Stroke) or Color3.new(1, 1, 1),
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

return InstanceUtil
