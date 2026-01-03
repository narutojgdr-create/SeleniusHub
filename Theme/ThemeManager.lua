local Themes = require(script.Parent.Themes)

local ThemeManager = {}
ThemeManager.__index = ThemeManager

function ThemeManager.new(instanceUtil)
	local self = setmetatable({}, ThemeManager)
	self._instanceUtil = instanceUtil
	self._themes = Themes
	self._currentName = "Midnight"
	self._currentTheme = self._themes[self._currentName] or self._themes.Midnight
	self._themedObjects = {}
	self._callbacks = {}

	if self._instanceUtil and self._instanceUtil.SetTheme then
		self._instanceUtil.SetTheme(self._currentTheme)
	end

	return self
end

function ThemeManager.GetThemes()
	return Themes
end

function ThemeManager:GetTheme()
	return self._currentTheme
end

function ThemeManager:GetThemeName()
	return self._currentName
end

function ThemeManager:Register(obj, prop, key)
	table.insert(self._themedObjects, { Object = obj, Property = prop, Key = key })
end

function ThemeManager:AddCallback(fn)
	table.insert(self._callbacks, fn)
end

function ThemeManager:SetTheme(name)
	local t = self._themes[name]
	if not t then
		return
	end

	self._currentTheme = t
	self._currentName = name

	if self._instanceUtil and self._instanceUtil.SetTheme then
		self._instanceUtil.SetTheme(self._currentTheme)
	end

	for _, info in ipairs(self._themedObjects) do
		local obj = info.Object
		if obj and obj.Parent and self._currentTheme[info.Key] then
			obj[info.Property] = self._currentTheme[info.Key]
		end
	end

	for _, callback in ipairs(self._callbacks) do
		pcall(function()
			if type(task) == "table" and type(task.spawn) == "function" then
				task.spawn(callback)
			elseif type(spawn) == "function" then
				spawn(callback)
			elseif type(coroutine) == "table" then
				local co = coroutine.create(callback)
				coroutine.resume(co)
			else
				pcall(callback)
			end
		end)
	end
end

return ThemeManager
