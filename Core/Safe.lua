--[[
    Safe.lua - Ultra-Protected Module for Maximum Executor Compatibility
    Prevents ANY crash on ANY executor (including VOLT, Fluxus, etc.)
]]

local Safe = {}

-- Logger fallback (não depende de require pra evitar crash circular)
local function safeLog(msg)
    pcall(function()
        if type(warn) == "function" then
            warn("[SeleniusHub] " .. tostring(msg))
        elseif type(print) == "function" then
            print("[SeleniusHub][WARN]", tostring(msg))
        end
    end)
end

-- Fallback para task API (VOLT e outros podem não ter)
local function getTaskApi()
    local ok, t = pcall(function()
        if type(task) == "table" then
            return task
        end
        return nil
    end)
    if ok and t then
        return t
    end
    return nil
end

Safe.Task = getTaskApi()

-- Safe wait que NUNCA crasha
function Safe.Wait(seconds)
    seconds = tonumber(seconds) or 0
    if seconds <= 0 then
        return true
    end

    local ok = pcall(function()
        local t = Safe.Task
        if t and type(t.wait) == "function" then
            t.wait(seconds)
            return
        end
        if type(wait) == "function" then
            wait(seconds)
            return
        end
        -- Último recurso: yield via RunService se disponível
        local rs
        pcall(function() rs = game:GetService("RunService") end)
        if rs then
            local elapsed = 0
            local conn
            conn = rs.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                if elapsed >= seconds and conn then
                    conn:Disconnect()
                end
            end)
            while elapsed < seconds do
                pcall(function()
                    if rs.Heartbeat then
                        rs.Heartbeat:Wait()
                    end
                end)
            end
        end
    end)
    return ok
end

-- Safe spawn que NUNCA crasha
function Safe.Spawn(fn, ...)
    if type(fn) ~= "function" then
        return false
    end
    local args = { ... }
    local ok = pcall(function()
        local t = Safe.Task
        if t and type(t.spawn) == "function" then
            t.spawn(function()
                pcall(fn, unpack(args))
            end)
            return
        end
        if type(spawn) == "function" then
            spawn(function()
                pcall(fn, unpack(args))
            end)
            return
        end
        if type(coroutine) == "table" and type(coroutine.create) == "function" then
            local co = coroutine.create(function()
                pcall(fn, unpack(args))
            end)
            coroutine.resume(co)
            return
        end
        -- Último recurso: executa direto
        pcall(fn, unpack(args))
    end)
    return ok
end

-- Safe delay que NUNCA crasha
function Safe.Delay(seconds, fn)
    if type(fn) ~= "function" then
        return false
    end
    seconds = tonumber(seconds) or 0
    local ok = pcall(function()
        local t = Safe.Task
        if t and type(t.delay) == "function" then
            t.delay(seconds, function()
                pcall(fn)
            end)
            return
        end
        if type(delay) == "function" then
            delay(seconds, function()
                pcall(fn)
            end)
            return
        end
        -- Fallback
        Safe.Spawn(function()
            Safe.Wait(seconds)
            pcall(fn)
        end)
    end)
    return ok
end

-- Safe traceback
function Safe.Trace(err)
    local msg = tostring(err or "unknown error")
    local ok, tb = pcall(function()
        if type(debug) == "table" and type(debug.traceback) == "function" then
            return debug.traceback(msg, 2)
        end
        return msg
    end)
    return ok and tb or msg
end

-- Safe pcall wrapper
function Safe.Call(fn, ...)
    if type(fn) ~= "function" then
        return false, "not a function"
    end
    return pcall(fn, ...)
end

-- Safe xpcall wrapper
function Safe.XCall(fn, ...)
    if type(fn) ~= "function" then
        return false, "not a function"
    end
    return xpcall(fn, Safe.Trace, ...)
end

-- Safe Connect que NUNCA crasha e auto-desconecta após erros repetidos
function Safe.Connect(signal, fn, onError)
    if not signal then
        return nil
    end

    local hasConnect = false
    pcall(function()
        hasConnect = type(signal.Connect) == "function"
    end)
    if not hasConnect then
        return nil
    end

    local errorCount = 0
    local maxErrors = 3
    local conn

    local ok, result = pcall(function()
        conn = signal:Connect(function(...)
            local args = { ... }
            local success, err = xpcall(function()
                fn(unpack(args))
            end, Safe.Trace)

            if not success then
                errorCount = errorCount + 1

                if type(onError) == "function" then
                    pcall(onError, err)
                else
                    safeLog(err)
                end

                if errorCount >= maxErrors then
                    pcall(function()
                        if conn and type(conn.Disconnect) == "function" then
                            conn:Disconnect()
                        end
                    end)
                end
            end
        end)
    end)

    if ok then
        return conn
    end
    return nil
end

-- Safe tween wait (Completed:Wait() pode crashar em alguns executors)
function Safe.WaitForTween(tween, timeout)
    if not tween then
        return false
    end
    timeout = tonumber(timeout) or 5

    local completed = false
    local conn

    pcall(function()
        conn = tween.Completed:Connect(function()
            completed = true
        end)
    end)

    pcall(function()
        if type(tween.Play) == "function" then
            tween:Play()
        end
    end)

    local start = 0
    pcall(function()
        start = (type(os) == "table" and type(os.clock) == "function" and os.clock()) or 0
    end)

    local iterations = 0
    local maxIterations = math.ceil(timeout / 0.05)

    while not completed and iterations < maxIterations do
        iterations = iterations + 1
        Safe.Wait(0.05)

        local now = 0
        pcall(function()
            now = (type(os) == "table" and type(os.clock) == "function" and os.clock()) or 0
        end)
        if now - start >= timeout then
            break
        end
    end

    pcall(function()
        if conn and type(conn.Disconnect) == "function" then
            conn:Disconnect()
        end
    end)

    return completed
end

-- Safe destroy
function Safe.Destroy(instance)
    pcall(function()
        if instance and type(instance.Destroy) == "function" then
            instance:Destroy()
        end
    end)
end

-- Safe property set
function Safe.SetProperty(instance, property, value)
    return pcall(function()
        instance[property] = value
    end)
end

-- Safe property get
function Safe.GetProperty(instance, property)
    local ok, val = pcall(function()
        return instance[property]
    end)
    return ok and val or nil
end

return Safe
