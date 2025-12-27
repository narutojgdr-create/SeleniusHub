local Signal = {}
Signal.__index = Signal

function Signal.new()
	local self = setmetatable({}, Signal)
	self._bindable = Instance.new("BindableEvent")
	return self
end

function Signal:Connect(fn)
	return self._bindable.Event:Connect(fn)
end

function Signal:Fire(...)
	self._bindable:Fire(...)
end

function Signal:Destroy()
	if self._bindable then
		self._bindable:Destroy()
		self._bindable = nil
	end
end

return Signal
