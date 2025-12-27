local PT = require(script.Parent.pt)
local EN = require(script.Parent.en)

local Locales = {
	pt = PT,
	en = EN,
}

local LocaleManager = {}
LocaleManager.__index = LocaleManager

function LocaleManager.new()
	local self = setmetatable({}, LocaleManager)
	self._locale = "pt"
	self._localizedObjects = {}
	self._localizedDropdowns = {}
	return self
end

function LocaleManager:GetLocale()
	return self._locale
end

function LocaleManager:GetText(key)
	local langTable = Locales[self._locale] or Locales.pt
	return langTable[key] or key
end

function LocaleManager:Register(obj, key, prefix, suffix)
	table.insert(self._localizedObjects, {
		Object = obj,
		Key = key,
		Prefix = prefix or "",
		Suffix = suffix or "",
	})
	obj.Text = (prefix or "") .. self:GetText(key) .. (suffix or "")
end

function LocaleManager:RegisterLocalizedOptions(dropdown, keys)
	table.insert(self._localizedDropdowns, { Dropdown = dropdown, Keys = keys })
end

function LocaleManager:SetLanguage(lang)
	if not Locales[lang] then
		return
	end

	self._locale = lang

	for _, info in ipairs(self._localizedObjects) do
		local obj = info.Object
		local text = self:GetText(info.Key)
		if obj and obj.Parent then
			obj.Text = (info.Prefix or "") .. text .. (info.Suffix or "")
		end
	end
end

function LocaleManager.GetLocales()
	return Locales
end

return LocaleManager
