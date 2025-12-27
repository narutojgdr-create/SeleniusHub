local Registry = {}
Registry.__index = Registry

function Registry.new()
	local self = setmetatable({}, Registry)
	self._options = {}
	return self
end

function Registry:Register(option, widget)
	self._options[option.Id] = {
		Option = option,
		Widget = widget,
	}
end

function Registry:Get(id)
	local rec = self._options[id]
	return rec and rec.Option or nil
end

function Registry:GetWidget(id)
	local rec = self._options[id]
	return rec and rec.Widget or nil
end

function Registry:Set(id, ...)
	local rec = self._options[id]
	if not rec then
		return
	end

	if rec.Option then
		rec.Option.Value = select(1, ...)
	end

	local cb = rec.Option and rec.Option.Callback
	if cb then
		cb(...)
	end
end

return Registry
