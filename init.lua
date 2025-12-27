-- Suporte: se alguém executar este arquivo via loadstring direto (sem árvore `script`),
-- redireciona para o loader principal que monta o require virtual.
local function shouldRedirectToLoader()
	if script == nil then
		return true
	end
	-- Alguns executores criam um `script` fake/limitado. Se não tiver a árvore esperada,
	-- usamos o loader para montar a estrutura virtual.
	local ok, hasTree = pcall(function()
		return script and script.Parent and script.Parent.Core and script.Parent.Core.Hub and script.Parent.Core.Lifecycle
	end)
	return (not ok) or (not hasTree)
end

if shouldRedirectToLoader() then
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
