local Hub = require(script.Core.Hub)
local Lifecycle = require(script.Core.Lifecycle)

local Library = {}
Library.__index = Library

function Library.Init()
	return Hub.new()
end

Library.New = Library.Init

Library.Lifecycle = Lifecycle

return Library
