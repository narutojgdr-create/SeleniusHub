local Math = {}

function Math.Lerp(a, b, t)
	return a + (b - a) * t
end

return Math
