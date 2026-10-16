local Validation = {}

function Validation.Options(value, name)
	if value == nil then return {} end
	assert(type(value) == "table", (name or "options") .. " debe ser una tabla")
	return value
end

function Validation.String(value, name, default, allowEmpty)
	if value == nil then return default end
	assert(type(value) == "string", (name or "value") .. " debe ser una cadena")
	assert(allowEmpty or value ~= "", (name or "value") .. " no puede estar vacía")
	return value
end

function Validation.Number(value, name, default, minValue, maxValue)
	if value == nil then value = default end
	assert(type(value) == "number" and value == value and value > -math.huge and value < math.huge,
		(name or "value") .. " debe ser un número finito")
	if minValue ~= nil then assert(value >= minValue, (name or "value") .. " debe ser >= " .. tostring(minValue)) end
	if maxValue ~= nil then assert(value <= maxValue, (name or "value") .. " debe ser <= " .. tostring(maxValue)) end
	return value
end

function Validation.Callback(callback, name)
	if callback == nil then return nil end
	assert(type(callback) == "function", (name or "Callback") .. " debe ser una función")
	return callback
end

function Validation.Range(minimum, maximum, minDefault, maxDefault)
	minimum = Validation.Number(minimum, "Min", minDefault)
	maximum = Validation.Number(maximum, "Max", maxDefault)
	assert(maximum > minimum, "Max debe ser mayor que Min")
	return minimum, maximum
end

function Validation.Step(value, default)
	value = Validation.Number(value, "Step", default or 1)
	assert(value > 0, "Step debe ser mayor que cero")
	return value
end

function Validation.EnumItem(value, enumType, default, name)
	if value == nil then return default end
	assert(typeof(value) == "EnumItem" and value.EnumType == enumType,
		(name or "value") .. " debe ser un valor de " .. tostring(enumType))
	return value
end

return Validation
