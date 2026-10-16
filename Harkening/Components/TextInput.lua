local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local Validation = require("../Utilities/Validation")
local TextInput = {}
TextInput.__index = TextInput
setmetatable(TextInput, { __index = Base })

function TextInput.new(context, parent, options)
	options = Validation.Options(options, "TextInput options")
	local theme = context.Theme
	local title = Validation.String(options.Title, "Title", "Text input", true)
	local initial = Validation.String(options.Value, "Value", options.Default or "", true)
	local callback = Validation.Callback(options.Callback)
	local validator = Validation.Callback(options.Validator, "Validator")
	if options.MaxLength ~= nil then
		assert(type(options.MaxLength) == "number" and options.MaxLength >= 1 and options.MaxLength % 1 == 0,
			"MaxLength debe ser un entero positivo")
	end
	local multiline = options.MultiLine == true
	local height = options.Height or (multiline and (options.Description and 138 or 118) or (options.Description and 74 or 62))
	local frame = Builder.Create("Frame", { Name = options.Name or "TextInput", BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, options.Height or height) }, parent)
	Builder.Corner(frame, theme:Get("CornerRadius"))
	local label = Builder.Label(frame, "Title", title, UDim2.new(1, -20, 0, 20), UDim2.new(0, 10, 0, 4), theme:Get("Text"), 13, true)
	local y = 26
	if options.Description then
		Builder.Label(frame, "Description", tostring(options.Description), UDim2.new(1, -20, 0, 16), UDim2.new(0, 10, 0, 23), theme:Get("MutedText"), 10)
		y = 42
	end
	local box = Builder.Create("TextBox", { Name = "Input", Text = initial,
		PlaceholderText = options.Placeholder or "Type here…", PlaceholderColor3 = theme:Get("MutedText"),
		BackgroundColor3 = theme:Get("Background"), BorderSizePixel = 0, Size = UDim2.new(1, -20, 0, options.InputHeight or (multiline and (options.Description and 56 or 62) or 27)),
		Position = UDim2.new(0, 10, 0, y), Font = Enum.Font.Gotham, TextSize = 12,
		TextColor3 = theme:Get("Text"), TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false, MultiLine = options.MultiLine == true, TextWrapped = options.MultiLine == true }, frame)
	Builder.Corner(box, 5)
	Builder.Padding(box, 8, 8, 0, 0)
	local errorLabel = Builder.Label(frame, "ValidationMessage", "", UDim2.new(1, -20, 0, 15), UDim2.new(0, 10, 1, -16), theme:Get("Danger"), 10)
	errorLabel.Visible = false
	local self = setmetatable({}, TextInput)
	Base.Initialize(self, context, frame)
	self.TextObject = label
	self._box, self._error, self._callback, self._validator = box, errorLabel, callback, validator
	self._value, self._maxLength = initial, options.MaxLength
	self.Required = options.Required == true
	function self:GetValue() return self._value end
	function self:SetValue(value, fireCallback)
		if self._destroyed then return end
		assert(type(value) == "string", "TextInput:SetValue espera una cadena")
		if self._maxLength then value = string.sub(value, 1, self._maxLength) end
		self._value = value
		box.Text = value
		errorLabel.Visible = false
		if fireCallback == true and self._callback then task.spawn(self._callback, value, false, self) end
	end
	function self:SetText(value) self:SetValue(value, false) end
	function self:GetText() return self:GetValue() end
	function self:Validate()
		if self._destroyed then return false, "Component destroyed" end
		local textValue = box.Text
		if self.Required and textValue == "" then
			errorLabel.Text = "This field is required"
			errorLabel.Visible = true
			return false, errorLabel.Text
		end
		if self._validator then
			local ok, result, message = pcall(self._validator, textValue)
			if not ok or result == false then
				errorLabel.Text = ok and tostring(message or "Invalid value") or "Validation failed"
				errorLabel.Visible = true
				return false, errorLabel.Text
			end
		end
		self._value = textValue
		errorLabel.Visible = false
		return true, textValue
	end
	self:Connect(box.Focused, function() self:FocusWindow() end)
	self:Connect(box:GetPropertyChangedSignal("Text"), function()
		if self._maxLength and #box.Text > self._maxLength then
			local clipped = string.sub(box.Text, 1, self._maxLength)
			box.Text = clipped
		end
	end)
	self:Connect(box.FocusLost, function(enterPressed)
		if not self.Enabled then return end
		local valid = self:Validate()
		if not valid then box.Text = self._value; return end
		if self._callback then task.spawn(self._callback, self._value, enterPressed == true, self) end
	end)
	function self:SetEnabled(enabled)
		if self._destroyed then return end
		Base.SetEnabled(self, enabled)
		box.TextEditable = self.Enabled
		box.Active = self.Enabled
		box.BackgroundTransparency = self.Enabled and 0 or 0.4
	end
	self:SetEnabled(options.Enabled ~= false)
	return self
end

return TextInput
