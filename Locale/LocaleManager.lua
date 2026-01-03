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
	pcall(function()
		obj.Text = (prefix or "") .. self:GetText(key) .. (suffix or "")
	end)
end

function LocaleManager:RegisterLocalizedOptions(dropdown, keys)
	if not dropdown or type(keys) ~= "table" then
		return
	end
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

	for _, info in ipairs(self._localizedDropdowns) do
		local dd = info.Dropdown
		local keys = info.Keys
		if dd and type(dd.UpdateOptions) == "function" and type(keys) == "table" then
			local prevIdx = nil
			pcall(function()
				if type(dd.GetIndex) == "function" then
					prevIdx = dd.GetIndex()
				end
			end)

			local newOptions = {}
			for i, k in ipairs(keys) do
				newOptions[i] = self:GetText(k)
			end

			pcall(function()
				dd.UpdateOptions(newOptions)
			end)

			if prevIdx and type(dd.SetIndex) == "function" then
				pcall(function()
					dd.SetIndex(prevIdx, true)
				end)
			end
		end
	end
end

function LocaleManager.GetLocales()
	return Locales
end

return LocaleManager
