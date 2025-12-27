local Hub = require(script.Parent.Core.Hub)
local Lifecycle = require(script.Parent.Core.Lifecycle)

local Library = {}
Library.__index = Library

function Library.Init()
	return Hub.new()
end

Library.New = Library.Init

Library.Lifecycle = Lifecycle

return Library
