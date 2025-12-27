local Option = {}
Option.__index = Option

function Option.new(def)
	local self = setmetatable({}, Option)
	for k, v in pairs(def or {}) do
		self[k] = v
	end
	return self
end

return Option
