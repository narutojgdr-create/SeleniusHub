local Logger = require(script.Parent.Parent.Utils.Logger)

local Safe = {}

function Safe.Trace(err)
    local msg = tostring(err)
    local ok, tb = pcall(function()
        if type(debug) == "table" and type(debug.traceback) == "function" then
            return debug.traceback(msg, 2)
        end
        return msg
    end)
    return ok and tb or msg
end

function Safe.Call(fn, ...)
    return pcall(fn, ...)
end

function Safe.XCall(fn, ...)
    return xpcall(fn, Safe.Trace, ...)
end

function Safe.Connect(signal, fn, onError)
    if not signal or type(signal.Connect) ~= "function" then
        return nil
    end
    return signal:Connect(function(...)
        local ok, err = xpcall(fn, Safe.Trace, ...)
        if not ok then
            if type(onError) == "function" then
                pcall(onError, err)
            else
                Logger.Error(err)
            end
        end
    end)
end

return Safe
