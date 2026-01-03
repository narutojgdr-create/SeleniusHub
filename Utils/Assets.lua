-- !!! ULTRA PROTEÇÃO !!!
local function safeGetService(name)
	local ok, svc = pcall(function() return game:GetService(name) end)
	if ok and svc then return svc end
	return nil
end
local function safeRequire(mod)
	local ok, result = pcall(function() return require(mod) end)
	if ok and result then return result end
	return {}
end

local Players = safeGetService("Players")
local CoreGui = safeGetService("CoreGui")
local MarketplaceService = safeGetService("MarketplaceService")
local Defaults = safeRequire(script.Parent.Parent.Assets.Defaults)
local LocalPlayer = Players and Players.LocalPlayer or nil

local Assets = {}

function Assets.RandomString(length)
	local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	local str = ""
	local random = math.random
	for _ = 1, length or 10 do
		local r = random(1, #chars)
		str = str .. string.sub(chars, r, r)
	end
	return str
end

function Assets.GetSecureParent()
	local success, result = pcall(function()
		return gethui()
	end)
	if success and result then
		return result
	end

	success, result = pcall(function()
		return CoreGui
	end)
	if success and result then
		return result
	end

	return LocalPlayer:WaitForChild("PlayerGui")
end

function Assets.GetGameName()
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfo(game.PlaceId)
	end)
	if success and info then
		return info.Name
	end
	return "Unknown Game"
end

function Assets.SafeWriteFile(path, data)
	pcall(writefile, path, data)
end

function Assets.SafeReadFile(path)
	local s, r = pcall(readfile, path)
	return s and r or nil
end

function Assets.SafeIsFile(path)
	local s, r = pcall(isfile, path)
	return s and r
end

function Assets.EnsureFolders()
	-- Alguns executores não suportam FS (isfolder/makefolder).
	-- Nesses casos, apenas não criamos pastas (sem crash).
	if type(isfolder) ~= "function" or type(makefolder) ~= "function" then
		return false
	end

	pcall(function()
		if not isfolder(Defaults.CONFIG_FOLDER) then
			makefolder(Defaults.CONFIG_FOLDER)
		end
	end)
	pcall(function()
		if not isfolder(Defaults.CONFIGS_DIR) then
			makefolder(Defaults.CONFIGS_DIR)
		end
	end)
	pcall(function()
		if not isfolder(Defaults.IMAGE_FOLDER) then
			makefolder(Defaults.IMAGE_FOLDER)
		end
	end)
	return true
end

function Assets.GetConfigList()
	local files = {}
	if type(isfolder) == "function" and isfolder(Defaults.CONFIGS_DIR) and type(listfiles) == "function" then
		local success, result = pcall(function()
			return listfiles(Defaults.CONFIGS_DIR)
		end)
		if success then
			for _, path in pairs(result) do
				local name = path:match("([^/\\]+)%.json$") or path:match("([^/\\]+)$")
				if name then
					local clean = (name:gsub("%.json", ""))
					table.insert(files, clean)
				end
			end
		end
	end
	if #files == 0 then
		table.insert(files, "default")
	end
	return files
end

function Assets.GetIcon(path)
	if typeof(getcustomasset) == "function" and Assets.SafeIsFile(path) then
		local ok, res = pcall(getcustomasset, path)
		if ok then
			return res
		end
	end
	return "rbxassetid://6034509993"
end

return Assets
