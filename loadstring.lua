--[[
SeleniusHub Loadstring Loader

Uso (exemplo):
loadstring(game:HttpGet("https://raw.githubusercontent.com/narutojgdr-create/SeleniusHub/main/loadstring.lua"))()

Config:
getgenv().SELENIUS_BASE_URL = "https://raw.githubusercontent.com/narutojgdr-create/SeleniusHub/main/"
getgenv().SELENIUS_LOCAL_ROOT = "SeleniusHub" -- (opcional) se você tiver os arquivos localmente e quiser usar readfile

Este loader mantém compatibilidade com módulos que usam `script.Parent.Parent...`.
]]

local function normalizePath(p)
	p = tostring(p or "")
	p = p:gsub("\\\\", "/")
	p = p:gsub("^/+", "")
	return p
end

local _getgenv = (type(getgenv) == "function" and getgenv) or function()
	return _G
end

local _gv = _getgenv()
local function gvGet(key)
	return rawget(_gv, key)
end
local function gvSet(key, value)
	rawset(_gv, key, value)
end

-- Cache-buster por execução para evitar que o GitHub Raw entregue arquivos de commits diferentes
-- (isso causa erros aleatórios quando só parte dos módulos atualiza).
if type(gvGet("SELENIUS_CACHE_BUSTER")) ~= "string" then
	local ok, buster = pcall(function()
		local t = (type(tick) == "function" and tick()) or (os and os.clock and os.clock()) or 0
		return tostring(math.floor(t * 1000)) .. "-" .. tostring(math.random(100000, 999999))
	end)
	gvSet("SELENIUS_CACHE_BUSTER", ok and buster or tostring(math.random(100000000, 999999999)))
end

local _task = task
if type(_task) ~= "table" then
	_task = {
		wait = wait,
		delay = delay,
		spawn = spawn,
	}
end

local MANIFEST = {
	"init.lua",
	"Scriptparaseparacao.lua",
	"Assets/Defaults.lua",
	"Assets/Fonts.lua",
	"Assets/Icons.lua",
	"Components/Button.lua",
	"Components/Checkbox.lua",
	"Components/ColorPicker.lua",
	"Components/Dropdown.lua",
	"Components/Keybind.lua",
	"Components/Label.lua",
	"Components/MultiDropdown.lua",
	"Components/Section.lua",
	"Components/Slider.lua",
	"Components/Toggle.lua",
	"Core/Config.lua",
	"Core/Hub.lua",
	"Core/Lifecycle.lua",
	"Core/Option.lua",
	"Core/Permissions.lua",
	"Core/Registry.lua",
	"Core/State.lua",
	"Core/Tab.lua",
	"Locale/en.lua",
	"Locale/LocaleManager.lua",
	"Locale/pt.lua",
	"Tabs/Combat/init.lua",
	"Tabs/Combat/logic.lua",
	"Tabs/Player/init.lua",
	"Tabs/Player/logic.lua",
	"Tabs/Settings/init.lua",
	"Tabs/Visual/init.lua",
	"Tabs/Visual/logic.lua",
	"Tabs/World/init.lua",
	"Theme/Acrylic.lua",
	"Theme/ThemeManager.lua",
	"Theme/Themes.lua",
	"UI/Builder.lua",
	"UI/Drag.lua",
	"UI/Footer.lua",
	"UI/Header.lua",
	"UI/Page.lua",
	"UI/Resize.lua",
	"UI/Sidebar.lua",
	"UI/Window.lua",
	"Utils/Assets.lua",
	"Utils/Instance.lua",
	"Utils/Logger.lua",
	"Utils/Math.lua",
	"Utils/Signal.lua",
	"Utils/Tween.lua",
}

local function hasHttpGet()
	return (type(game) == "userdata" or type(game) == "table")
		and type(game.HttpGet) == "function"
end

local function httpGet(url)
	if hasHttpGet() then
		return game:HttpGet(url)
	end
	local gv = _getgenv()
	local req = rawget(gv, "request") or rawget(gv, "http_request") or (rawget(gv, "syn") and rawget(gv.syn, "request"))
	if type(req) == "function" then
		local res = req({ Url = url, Method = "GET" })
		if res and (res.Body or res.body) then
			return res.Body or res.body
		end
	end
	error("Nenhuma API HTTP disponível (game:HttpGet/request/http_request)")
end

local function tryHttpGet(url)
	local ok, body = pcall(function()
		return httpGet(url)
	end)
	if ok then
		return body
	end
	return nil
end

local function tryReadFile(path)
	if type(readfile) ~= "function" then
		return nil
	end
	local ok, content = pcall(readfile, path)
	if ok then
		return content
	end
	return nil
end

local function getSourceFor(path)
	path = normalizePath(path)

	local localRoot = normalizePath(rawget(_getgenv(), "SELENIUS_LOCAL_ROOT") or "")
	if localRoot ~= "" then
		local localPath = (localRoot .. "/" .. path)
		local content = tryReadFile(localPath)
		if content then
			return content
		end
	end

	local userBase = rawget(_getgenv(), "SELENIUS_BASE_URL")
	local bases
	if type(userBase) == "string" and userBase ~= "" then
		bases = { userBase }
	else
		bases = {
			"https://raw.githubusercontent.com/narutojgdr-create/SeleniusHub/main/",
			"https://raw.githubusercontent.com/narutojgdr-create/SeleniusHub/master/",
		}
	end

	local buster = gvGet("SELENIUS_CACHE_BUSTER")
	for _, base in ipairs(bases) do
		base = normalizePath(base)
		if not base:match("^https?://") then
			base = "https://" .. base
		end
		if not base:match("/$") then
			base = base .. "/"
		end

		local url = base .. path
		if type(buster) == "string" and buster ~= "" then
			url = url .. "?v=" .. buster
		end

		local body = tryHttpGet(url)
		if type(body) == "string" then
			return body
		end
	end

	error("Falha ao baixar '" .. path .. "'. Defina getgenv().SELENIUS_BASE_URL para a URL raw correta (main/master).")
end

-- =====================
-- Virtual tree
-- =====================

local function splitPath(p)
	local parts = {}
	for part in tostring(p):gmatch("[^/]+") do
		parts[#parts + 1] = part
	end
	return parts
end

local function stripExt(filename)
	return filename:gsub("%.lua$", "")
end

local function newNode(name, className)
	local node = { Name = name, ClassName = className, Parent = nil, _children = {}, _path = nil }
	setmetatable(node, {
		__index = function(self, key)
			return rawget(self, key) or self._children[key]
		end,
	})
	return node
end

local ROOT = newNode("SeleniusHub", "Folder")
ROOT._path = "" -- virtual root

local function ensureFolder(parent, name)
	local existing = parent._children[name]
	if existing then
		return existing
	end
	local folder = newNode(name, "Folder")
	folder.Parent = parent
	parent._children[name] = folder
	return folder
end

local function ensureModule(parent, name, path)
	local mod = parent._children[name]
	if mod then
		mod._path = path
		return mod
	end
	mod = newNode(name, "ModuleScript")
	mod.Parent = parent
	mod._path = path
	parent._children[name] = mod
	return mod
end

for _, p in ipairs(MANIFEST) do
	p = normalizePath(p)
	local parts = splitPath(p)
	local folder = ROOT
	for i = 1, #parts do
		local part = parts[i]
		local isLast = (i == #parts)
		if isLast then
			local name = stripExt(part)
			ensureModule(folder, name, p)
		else
			folder = ensureFolder(folder, part)
		end
	end
end

-- =====================
-- Custom require
-- =====================

local MODULE_CACHE = {}
local SOURCE_CACHE = {}

local function resolveRequireArg(arg)
	if type(arg) == "string" then
		return normalizePath(arg)
	end
	if type(arg) == "table" and arg.ClassName == "ModuleScript" and type(arg._path) == "string" then
		return normalizePath(arg._path)
	end
	error("require() recebeu um argumento inválido")
end

local function setFunctionEnv(fn, env)
	if type(setfenv) == "function" then
		setfenv(fn, env)
		return
	end
	local okDebug = type(debug) == "table" and type(debug.getupvalue) == "function" and type(debug.setupvalue) == "function"
	if okDebug then
		local i = 1
		while true do
			local name = debug.getupvalue(fn, i)
			if not name then
				break
			end
			if name == "_ENV" then
				debug.setupvalue(fn, i, env)
				break
			end
			i = i + 1
		end
	end
end

local function customRequire(mod)
	local path = resolveRequireArg(mod)
	if MODULE_CACHE[path] ~= nil then
		return MODULE_CACHE[path]
	end

	local source = SOURCE_CACHE[path]
	if not source then
		source = getSourceFor(path)
		SOURCE_CACHE[path] = source
	end

	local chunkName = "=" .. path
	-- Wrapper para não depender de setfenv/debug (muitos executores bloqueiam)
	local wrapped = "return function(__script, __require)\nlocal script = __script\nlocal require = __require\n" .. source .. "\nend"
	local factory, err = loadstring(wrapped, chunkName)
	if not factory then
		error("Falha ao compilar módulo (wrapper): " .. path .. "\n" .. tostring(err))
	end
	local fn = factory()
	if type(fn) ~= "function" then
		error("Falha ao carregar módulo (factory não retornou função): " .. path)
	end

	-- script virtual para compatibilidade com script.Parent...
	local scriptNode = nil
	-- achar o node correspondente no tree
	local parts = splitPath(path)
	local cur = ROOT
	for i = 1, #parts do
		local part = parts[i]
		if i == #parts then
			cur = cur[stripExt(part)]
		else
			cur = cur[part]
		end
		if not cur then
			break
		end
	end
	scriptNode = cur

	local ok, result = pcall(fn, scriptNode, customRequire)
	if not ok then
		error("Erro ao executar módulo: " .. path .. "\n" .. tostring(result))
	end
	MODULE_CACHE[path] = result
	return result
end

-- =====================
-- Bootstrap
-- =====================

local function destroyOldInstance(inst)
	pcall(function()
		if inst and type(inst.Destroy) == "function" then
			inst:Destroy()
		end
	end)
end

-- Se o Hub já estiver ativo, não recria (evita abrir/loading duplicado quando o loadstring roda 2x).
do
	local existing = gvGet("SeleniusHubInstance") or rawget(_G, "SeleniusHubInstance")
	if existing ~= nil then
		local okVisible = pcall(function()
			if type(existing.SetVisible) == "function" then
				existing:SetVisible(true, true)
			end
		end)
		gvSet("SeleniusHubInstance", existing)
		rawset(_G, "SeleniusHubInstance", existing)
		if okVisible then
			return existing
		end
	end
end

-- Alguns executores podem divergir entre _G e getgenv(); destruímos em ambos.
destroyOldInstance(gvGet("SeleniusHubInstance"))
destroyOldInstance(rawget(_G, "SeleniusHubInstance"))

-- Carrega a library (init.lua)
local lib = customRequire(ROOT["init"])

-- Cria o hub
local hub = lib.Init()

-- Inicia KeySystem primeiro e, ao concluir, Loading mostra o Hub
lib.Lifecycle.CreateKeySystem(hub)

-- Reload compatível com o monólito
rawset(_G, "SeleniusHubReload", function()
	pcall(function()
		if hub and type(hub.Destroy) == "function" then
			hub:Destroy()
		end
	end)
	_task.wait(0.1)
	local lib2 = customRequire(ROOT["init"])
	hub = lib2.Init()
	lib2.Lifecycle.CreateKeySystem(hub)
	gvSet("SeleniusHubInstance", hub)
	rawset(_G, "SeleniusHubInstance", hub)
end)

gvSet("SeleniusHubInstance", hub)
rawset(_G, "SeleniusHubInstance", hub)
return hub
