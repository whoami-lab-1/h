local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local Form = {}
Form.__index = Form
setmetatable(Form, { __index = Base })
function Form.new(context, parent, options)
	options = options or {}
	assert(type(options) == "table", "Form options debe ser una tabla")
	local fields = options.Fields
	if fields == nil then fields = {} end
	assert(type(fields) == "table", "Fields debe ser una tabla")
	if options.OnSubmit ~= nil then assert(type(options.OnSubmit) == "function", "OnSubmit debe ser una función") end
	if options.SubmitText ~= nil then assert(type(options.SubmitText) == "string", "SubmitText debe ser una cadena") end
	local seenFields = {}
	for _, fieldConfig in ipairs(fields) do
		assert(type(fieldConfig) == "table", "Cada field debe ser una tabla")
		local fieldName = fieldConfig.Name or fieldConfig.Key or fieldConfig.Title
		assert(type(fieldName) == "string" and fieldName ~= "", "Cada campo del Form necesita Name, Key o Title")
		assert(not seenFields[fieldName], "Nombre de campo duplicado: " .. fieldName)
		seenFields[fieldName] = true
		assert(fieldConfig.Type == nil or type(fieldConfig.Type) == "string", "Type de cada field debe ser string")
	end
	local theme = context.Theme
	local frame = Builder.Create("Frame", { Name = options.Name or "Form", BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, parent)
	Builder.Corner(frame, theme:Get("CornerRadius")); Builder.Padding(frame, 10, 10, 10, 10)
	local layout = Builder.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 7) }, frame)
	local self = setmetatable({}, Form); Base.Initialize(self, context, frame); self.Fields, self._fieldConfig, self._fieldOrder = {}, fields, {}
	local button
	local buildOk, buildError = pcall(function()
		for _, fieldConfig in ipairs(self._fieldConfig) do
			local field = table.clone(fieldConfig)
			local fieldName = field.Name or field.Key or field.Title
			local kind = field.Type or "TextInput"
			field.Type = nil
			local component = context.Factory:Create(kind, frame, field, context)
			self.Fields[fieldName] = component
			table.insert(self._fieldOrder, fieldName)
			self._children = self._children or {}; table.insert(self._children, component)
			if component.Frame then component.Frame.LayoutOrder = #self._children end
		end
		button = context.Factory:Create("Button", frame, { Title = options.SubmitText or "Submit", Callback = function()
			self:Submit()
		end }, context)
		button.Frame.LayoutOrder = 10000
		self.SubmitButton = button
		self._children = self._children or {}; table.insert(self._children, button)
	end)
	if not buildOk then
		for index = #(self._children or {}), 1, -1 do
			local component = self._children[index]
			if component and component.Destroy then pcall(component.Destroy, component) end
		end
		self._cleanup:Destroy()
		if frame.Parent then frame:Destroy() end
		error(buildError, 2)
	end
	function self:GetValues()
		local result = {}
		for _, name in ipairs(self._fieldOrder) do
			local component = self.Fields[name]
			if component and component.GetValue then result[name] = component:GetValue() end
		end
		return result
	end
	function self:Submit()
		if self._destroyed then return nil, false, nil, "Form destroyed" end
		for _, fieldName in ipairs(self._fieldOrder) do
			local component = self.Fields[fieldName]
			if component and type(component.Validate) == "function" then
				local valid, message = component:Validate()
				if not valid then return nil, false, fieldName, message end
			end
		end
		local values = self:GetValues()
		if type(options.OnSubmit) == "function" then task.spawn(options.OnSubmit, values, self) end
		return values, true
	end
	function self:GetField(name) return self.Fields[name] end
	function self:SetEnabled(enabled)
		if self._destroyed then return end
		Base.SetEnabled(self, enabled)
		for _, component in pairs(self.Fields) do if component.SetEnabled then component:SetEnabled(enabled) end end
		if button.SetEnabled then button:SetEnabled(enabled) end
	end
	self:SetEnabled(options.Enabled ~= false)
	return self
end
return Form
