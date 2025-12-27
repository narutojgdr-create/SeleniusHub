local State = {}
State.__index = State

function State.new()
	local self = setmetatable({}, State)

	self.Settings = { AntiAFK = false }
	self.Combat = {}
	self.Visuals = {}
	self.Player = {}

	return self
end

return State
