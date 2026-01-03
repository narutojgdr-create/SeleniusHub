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
	"Core/Safe.lua",
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
	"UI/Notifications.lua",
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

	-- IMPORTANTE:
	-- Muitos executores/usuários acabam deixando SELENIUS_LOCAL_ROOT setado e
	-- isso faz carregar arquivos LOCAIS desatualizados (mesmo após update no GitHub).
	-- Por padrão, só usamos local se SELENIUS_PREFER_LOCAL == true.
	local preferLocal = (rawget(_getgenv(), "SELENIUS_PREFER_LOCAL") == true)
	local localRoot = normalizePath(rawget(_getgenv(), "SELENIUS_LOCAL_ROOT") or "")
	if preferLocal and localRoot ~= "" then
		local localPath = (localRoot .. "/" .. path)
		local content = tryReadFile(localPath)
		if content then
			return content
		end
	elseif (not preferLocal) and localRoot ~= "" then
		pcall(function()
			warn("[SeleniusHub] SELENIUS_LOCAL_ROOT ignorado (use SELENIUS_PREFER_LOCAL=true para habilitar).")
		end)
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
	local okDebug = type(debug) == "table" and type(debug.getupvalue) == "function" and
		type(debug.setupvalue) == "function"
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
	local wrapped = "return function(__script, __require)\nlocal script = __script\nlocal require = __require\n" ..
		source .. "\nend"
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
	local forceReload = (gvGet("SELENIUS_ALWAYS_UPDATE") == true) or (gvGet("SELENIUS_FORCE_RELOAD") == true)
	if existing ~= nil and not forceReload then
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

-- Mostrar uma notificação ANTES de tudo (antes de baixar/carregar os módulos do Hub).
-- Isso garante que o usuário veja feedback imediato, e só depois o resto começa a carregar.
local function getBootstrapParent()
	local okHui, hui = pcall(function()
		return gethui()
	end)
	if okHui and hui then
		return hui
	end

	local okCoreGui, coreGui = pcall(function()
		return game:GetService("CoreGui")
	end)
	if okCoreGui and coreGui then
		return coreGui
	end

	local okPlayers, players = pcall(function()
		return game:GetService("Players")
	end)
	if okPlayers and players and players.LocalPlayer then
		local okPg, pg = pcall(function()
			return players.LocalPlayer:WaitForChild("PlayerGui")
		end)
		if okPg and pg then
			return pg
		end
	end

	return nil
end

local function showBootstrapNotice(text)
	local parent = getBootstrapParent()
	if not parent then
		return nil
	end

	pcall(function()
		local old = parent:FindFirstChild("SeleniusHub_BootstrapNotice")
		if old and old.Destroy then
			old:Destroy()
		end
	end)

	local ok, gui = pcall(function()
		local g = Instance.new("ScreenGui")
		g.Name = "SeleniusHub_BootstrapNotice"
		g.ResetOnSpawn = false
		g.DisplayOrder = 9999
		g.IgnoreGuiInset = true
		g.Parent = parent

		local holder = Instance.new("Frame")
		holder.BackgroundTransparency = 1
		holder.Position = UDim2.new(1, -20, 1, -20)
		holder.AnchorPoint = Vector2.new(1, 1)
		holder.Size = UDim2.new(0, 340, 0, 58)
		holder.Parent = g
		holder.Name = "Holder"

		local card = Instance.new("Frame")
		card.Name = "Card"
		card.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
		card.BackgroundTransparency = 0.08
		card.Size = UDim2.new(1, 0, 1, 0)
		card.ClipsDescendants = true
		card.Parent = holder
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = card
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(55, 65, 90)
		stroke.Thickness = 1
		stroke.Transparency = 1
		stroke.Parent = card

		-- "Pauzinho" (barra de severidade): azul (normal/ativo)
		local severity = Instance.new("Frame")
		severity.Name = "Severity"
		severity.BackgroundColor3 = Color3.fromRGB(45, 105, 250)
		severity.BorderSizePixel = 0
		severity.Position = UDim2.new(0, 12, 0, 10)
		severity.Size = UDim2.new(0, 5, 1, -20)
		severity.Parent = card
		local sevCorner = Instance.new("UICorner")
		sevCorner.CornerRadius = UDim.new(0, 8)
		sevCorner.Parent = severity

		local title = Instance.new("TextLabel")
		title.Name = "Title"
		title.BackgroundTransparency = 1
		title.Position = UDim2.new(0, 28, 0, 10)
		title.Size = UDim2.new(1, -40, 0, 14)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 12
		title.TextColor3 = Color3.fromRGB(160, 165, 185)
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Text = "ATIVO"
		title.TextTransparency = 1
		title.Parent = card

		local msg = Instance.new("TextLabel")
		msg.Name = "Message"
		msg.BackgroundTransparency = 1
		msg.Position = UDim2.new(0, 28, 0, 26)
		msg.Size = UDim2.new(1, -40, 0, 18)
		msg.Font = Enum.Font.GothamMedium
		msg.TextSize = 13
		msg.TextColor3 = Color3.fromRGB(235, 235, 235)
		msg.TextXAlignment = Enum.TextXAlignment.Left
		msg.TextYAlignment = Enum.TextYAlignment.Top
		msg.TextWrapped = true
		msg.TextTruncate = Enum.TextTruncate.AtEnd
		msg.Text = tostring(text or "Inicializando Selenius...")
		msg.TextTransparency = 1
		msg.Parent = card

		local scale = Instance.new("UIScale")
		scale.Scale = 0.92
		scale.Parent = card

		pcall(function()
			local TweenService = game:GetService("TweenService")
			local ti = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(scale, ti, { Scale = 1 }):Play()
			TweenService:Create(stroke, ti, { Transparency = 0.55 }):Play()
			TweenService:Create(title, ti, { TextTransparency = 0 }):Play()
			TweenService:Create(msg, ti, { TextTransparency = 0 }):Play()
		end)

		return g
	end)

	if ok then
		return gui
	end
	return nil
end

-- Marca para o Lifecycle não tentar duplicar uma notificação "antes de tudo".
gvSet("SELENIUS_BOOT_NOTIFIED", true)
local bootstrapGui = nil
pcall(function()
	bootstrapGui = showBootstrapNotice("Inicializando Selenius...")
end)

-- Deixa renderizar pelo menos 1 frame antes de carregar o resto.
pcall(function()
	if _task and _task.wait then
		_task.wait(0.05)
	elseif type(wait) == "function" then
		wait(0.05)
	end
end)

-- Carrega a library (init.lua) com proteção total
local lib = nil
local libOk = pcall(function()
	lib = customRequire(ROOT["init"])
end)

if not lib or not libOk then
	pcall(function()
		warn("[SeleniusHub] Falha ao carregar library principal")
	end)
	return nil
end

-- Cria o hub com proteção
local hub = nil
pcall(function()
	hub = lib.Init()
end)

pcall(function()
	if bootstrapGui and bootstrapGui.Parent then
		bootstrapGui:Destroy()
	end
end)

-- Inicia KeySystem primeiro e, ao concluir, Loading mostra o Hub
pcall(function()
	if lib and lib.Lifecycle and type(lib.Lifecycle.CreateKeySystem) == "function" then
		lib.Lifecycle.CreateKeySystem(hub)
	end
end)

-- Reload compatível com o monólito
pcall(function()
	rawset(_G, "SeleniusHubReload", function()
		local boot2 = nil
		pcall(function()
			boot2 = showBootstrapNotice("Inicializando Selenius...")
		end)
		pcall(function()
			if _task and _task.wait then
				_task.wait(0.05)
			elseif type(wait) == "function" then
				wait(0.05)
			end
		end)
		pcall(function()
			if hub and type(hub.Destroy) == "function" then
				hub:Destroy()
			end
		end)
		pcall(function()
			if _task and _task.wait then
				_task.wait(0.1)
			elseif type(wait) == "function" then
				wait(0.1)
			end
		end)
		local lib2 = nil
		pcall(function()
			lib2 = customRequire(ROOT["init"])
		end)
		pcall(function()
			if lib2 and lib2.Init then
				hub = lib2.Init()
			end
		end)
		pcall(function()
			if boot2 and boot2.Parent then
				boot2:Destroy()
			end
		end)
		pcall(function()
			if lib2 and lib2.Lifecycle and type(lib2.Lifecycle.CreateKeySystem) == "function" then
				lib2.Lifecycle.CreateKeySystem(hub)
			end
		end)
		gvSet("SeleniusHubInstance", hub)
		rawset(_G, "SeleniusHubInstance", hub)
	end)
end)

gvSet("SeleniusHubInstance", hub)
pcall(function()
	rawset(_G, "SeleniusHubInstance", hub)
end)
return hub
