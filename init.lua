-- Suporte: se alguém executar este arquivo via loadstring direto (sem árvore `script`),
-- redireciona para o loader principal que monta o require virtual.
local function shouldRedirectToLoader()
	if script == nil then
		return true
	end
	-- Alguns executores criam um `script` fake/limitado. Se não tiver a árvore esperada,
	-- usamos o loader para montar a estrutura virtual.
	local ok, hasTree = pcall(function()
		return script and script.Parent and script.Parent.Core and script.Parent.Core.Hub and
			script.Parent.Core.Lifecycle
	end)
	return (not ok) or (not hasTree)
end

if shouldRedirectToLoader() then
	local _getgenv = (type(getgenv) == "function" and getgenv) or function()
		return _G
	end
	local gv = _getgenv()
	if type(rawget(gv, "SELENIUS_CACHE_BUSTER")) ~= "string" then
		local ok, buster = pcall(function()
			local t = (type(tick) == "function" and tick()) or (os and os.clock and os.clock()) or 0
			return tostring(math.floor(t * 1000)) .. "-" .. tostring(math.random(100000, 999999))
		end)
		rawset(gv, "SELENIUS_CACHE_BUSTER", ok and buster or tostring(math.random(100000000, 999999999)))
	end
	local base = rawget(gv, "SELENIUS_BASE_URL")
	if type(base) ~= "string" or base == "" then
		-- Default (pode ser sobrescrito via getgenv().SELENIUS_BASE_URL)
		base = "https://raw.githubusercontent.com/narutojgdr-create/SeleniusHub/main/"
	end
	if not base:match("/$") then
		base = base .. "/"
	end

	local function tryHttpGet(url)
		local ok, body = pcall(function()
			return game:HttpGet(url)
		end)
		if ok then
			return body
		end
		return nil
	end

	-- Se o usuário não definiu SELENIUS_BASE_URL, tentamos um fallback para 'master'
	-- porque alguns repositórios usam esse branch como padrão.
	local buster = rawget(gv, "SELENIUS_CACHE_BUSTER")
	local loaderUrl = base .. "loadstring.lua" .. (buster and ("?v=" .. tostring(buster)) or "")
	local loaderBody = tryHttpGet(loaderUrl)
	if (not loaderBody) and (base:find("/main/", 1, true) ~= nil) and (type(rawget(gv, "SELENIUS_BASE_URL")) ~= "string") then
		local fallbackBase = base:gsub("/main/$", "/master/")
		local fallbackUrl = fallbackBase .. "loadstring.lua" .. (buster and ("?v=" .. tostring(buster)) or "")
		loaderBody = tryHttpGet(fallbackUrl)
	end
	if not loaderBody then
		error(
			"Falha ao baixar loadstring.lua. Configure getgenv().SELENIUS_BASE_URL com a URL raw correta (main/master).")
	end
	return loadstring(loaderBody)()
end

-- !!! ULTRA PROTEÇÃO !!!
local function safeRequire(mod)
	local ok, result = pcall(function() return require(mod) end)
	if ok and result then return result end
	return {}
end

local Hub = safeRequire(script.Parent.Core.Hub)
local Lifecycle = safeRequire(script.Parent.Core.Lifecycle)

local Library = {}
Library.__index = Library

function Library.Init()
	return Hub.new()
end

Library.New = Library.Init

Library.Lifecycle = Lifecycle

return Library
