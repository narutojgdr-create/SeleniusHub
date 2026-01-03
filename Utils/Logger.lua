local Logger = {}

local function getGlobalEnv()
	local ok, gv = pcall(function()
		if type(getgenv) == "function" then
			return getgenv()
		end
		return nil
	end)
	if ok and type(gv) == "table" then
		return gv
	end
	return _G
end

local _errorState = { lastMsg = nil, lastCopyAt = 0 }
local function nowClock()
	return (type(os) == "table" and type(os.clock) == "function" and os.clock()) or 0
end
local function canSetClipboard()
	return (type(typeof) == "function" and typeof(setclipboard) == "function") or (type(setclipboard) == "function")
end
local function toMessage(...)
	local parts = { ... }
	for i = 1, #parts do
		parts[i] = tostring(parts[i])
	end
	return table.concat(parts, " ")
end

function Logger.Info(...)
	-- Mantém o comportamento atual (sem logs extras automáticos).
	-- Chamadas explícitas continuam funcionando.
	print(...)
end

function Logger.Warn(...)
	warn(...)
end

function Logger.Error(...)
	warn(...)

	local msg = toMessage(...)
	local gv = getGlobalEnv()
	pcall(function()
		gv.SELENIUS_LAST_ERROR = msg
	end)

	pcall(function()
		if gv and rawget(gv, "SELENIUS_COPY_ERRORS") == false then
			return
		end
		if not canSetClipboard() then
			return
		end
		local now = nowClock()
		if _errorState.lastMsg == msg and (now - (_errorState.lastCopyAt or 0) < 3) then
			return
		end
		_errorState.lastMsg = msg
		_errorState.lastCopyAt = now
		local payload = msg
		local maxLen = 15000
		if #payload > maxLen then
			payload = payload:sub(1, maxLen) .. "\n... (truncado)"
		end
		setclipboard(payload)
	end)
end

return Logger
