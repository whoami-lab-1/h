local TextInput = require("./TextInput")
local NumericInput = {}
function NumericInput.new(context, parent, options)
	options = options or {}
	local config = table.clone(options)
	config.Name = options.Name or "NumericInput"
	local minimum, maximum = options.Min, options.Max
	local function isFinite(value)
		return type(value) == "number" and value == value and value > -math.huge and value < math.huge
	end
	if minimum ~= nil then assert(isFinite(minimum), "Min debe ser un número finito") end
	if maximum ~= nil then assert(isFinite(maximum), "Max debe ser un número finito") end
	if options.Integer ~= nil then assert(type(options.Integer) == "boolean", "Integer debe ser booleano") end
	if minimum ~= nil and maximum ~= nil then assert(maximum >= minimum, "Max debe ser mayor o igual a Min") end
	config.Validator = function(text)
		local value = tonumber(text)
		if not value then return false, "Enter a valid number" end
		if minimum ~= nil and value < minimum then return false, "Minimum is " .. tostring(minimum) end
		if maximum ~= nil and value > maximum then return false, "Maximum is " .. tostring(maximum) end
		if options.Integer and value % 1 ~= 0 then return false, "Enter a whole number" end
		if type(options.Validator) == "function" then return options.Validator(value) end
		return true
	end
	local originalCallback = options.Callback
	config.Callback = function(text, enterPressed, component)
		if type(originalCallback) == "function" then originalCallback(tonumber(text), enterPressed, component) end
	end
	local initial = options.Value
	if initial == nil then initial = options.Default end
	if initial ~= nil then
		assert(isFinite(initial), "NumericInput Value debe ser un número finito")
		if minimum ~= nil then initial = math.max(minimum, initial) end
		if maximum ~= nil then initial = math.min(maximum, initial) end
		if options.Integer then assert(initial % 1 == 0, "NumericInput Value debe ser entero") end
		config.Value = tostring(initial)
	end
	local result = TextInput.new(context, parent, config)
	local oldGet = result.GetValue
	local oldSet = result.SetValue
	function result:GetValue() return tonumber(oldGet(self)) end
	function result:SetValue(value, fireCallback)
		if self._destroyed then return end
		assert(isFinite(value), "NumericInput:SetValue espera un número finito")
		if options.Integer then assert(value % 1 == 0, "NumericInput:SetValue espera un entero") end
		if minimum ~= nil then value = math.max(minimum, value) end
		if maximum ~= nil then value = math.min(maximum, value) end
		return oldSet(self, tostring(value), fireCallback)
	end
	function result:GetNumber() return self:GetValue() end
	return result
end
return NumericInput
