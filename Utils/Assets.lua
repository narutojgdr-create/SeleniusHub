local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")

local Defaults = require(script.Parent.Parent.Assets.Defaults)

local LocalPlayer = Players.LocalPlayer

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
	if not isfolder(Defaults.CONFIG_FOLDER) then
		makefolder(Defaults.CONFIG_FOLDER)
	end
	if not isfolder(Defaults.CONFIGS_DIR) then
		makefolder(Defaults.CONFIGS_DIR)
	end
	if not isfolder(Defaults.IMAGE_FOLDER) then
		makefolder(Defaults.IMAGE_FOLDER)
	end
end

function Assets.GetConfigList()
	local files = {}
	if isfolder(Defaults.CONFIGS_DIR) then
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
