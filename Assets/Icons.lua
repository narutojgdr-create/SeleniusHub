-- !!! ULTRA PROTEÇÃO !!!
local function safeRequire(mod)
	local ok, result = pcall(function() return require(mod) end)
	if ok and result then return result end
	return {}
end

local Defaults = safeRequire(script.Parent.Defaults)
local Assets = safeRequire(script.Parent.Parent.Utils.Assets)

if Assets.EnsureFolders then
	pcall(Assets.EnsureFolders)
end

local IconPaths = {
	Combat = Defaults.IMAGE_FOLDER .. "/combat.png",
	Visuals = Defaults.IMAGE_FOLDER .. "/visuals.png",
	Player = Defaults.IMAGE_FOLDER .. "/player.png",
	Settings = Defaults.IMAGE_FOLDER .. "/settings.png",
	Logo = Defaults.IMAGE_FOLDER .. "/logo.png",
	Home = Defaults.IMAGE_FOLDER .. "/home.png",
	Key = Defaults.IMAGE_FOLDER .. "/key.png",
}

for _, path in pairs(IconPaths) do
	if not Assets.SafeIsFile(path) then
		Assets.SafeWriteFile(path, "")
	end
end

return IconPaths
