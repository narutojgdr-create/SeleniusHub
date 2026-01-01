local ClassHandlers = require(script.ClassHandlers.init)

return function(queryPoint: Vector2, gui: GuiObject): { number }
	return ClassHandlers[gui.ClassName](queryPoint, gui)
end
