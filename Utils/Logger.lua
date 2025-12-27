local Logger = {}

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
end

return Logger
