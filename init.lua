-- Suporte: se alguém executar este arquivo via loadstring direto (sem árvore `script`),
-- redireciona para o loader principal que monta o require virtual.
if script == nil then
	local _getgenv = (type(getgenv) == "function" and getgenv) or function()
		return _G
	end
	local gv = _getgenv()
	local base = rawget(gv, "SELENIUS_BASE_URL")
	if type(base) ~= "string" or base == "" then
		base = "https://raw.githubusercontent.com/dsajdiajifdwa85/SeleniusHub/main/"
	end
	if not base:match("/$") then
		base = base .. "/"
	end
	return loadstring(game:HttpGet(base .. "loadstring.lua"))()
end

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
