local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local Validation = require("../Utilities/Validation")
local Segmented = {}
Segmented.__index = Segmented
setmetatable(Segmented, { __index = Base })
function Segmented.new(context, parent, options)
	options = Validation.Options(options, "Segmented options")
	assert(type(options.Options) == "table" and #options.Options > 0, "Segmented necesita Options")
	local theme, callback = context.Theme, Validation.Callback(options.Callback)
	local function optionValue(option)
		if type(option) ~= "table" then return option end
		if option.Value ~= nil then return option.Value end
		return option.Text
	end
	local seenValues = {}
	for _, option in ipairs(options.Options) do
		local value = optionValue(option)
		assert(value ~= nil and (type(value) == "string" or type(value) == "number" or type(value) == "boolean"),
			"Cada opción de Segmented necesita Value/Text string, number o boolean")
		if type(value) == "number" then assert(value == value and value > -math.huge and value < math.huge, "Value numérico debe ser finito") end
		assert(not seenValues[value], "Valor duplicado en Segmented: " .. tostring(value))
		seenValues[value] = true
	end
	local initialCandidate = options.Value
	if initialCandidate == nil then initialCandidate = options.Default end
	assert(initialCandidate == nil or seenValues[initialCandidate], "Valor inicial no disponible en Segmented")
	local frame = Builder.Create("Frame", { Name = options.Name or "Segmented", BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, options.Height or 38) }, parent); Builder.Corner(frame, theme:Get("CornerRadius")); Builder.Padding(frame, 3, 3, 3, 3)
	local layout = Builder.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 3) }, frame)
	local self = setmetatable({}, Segmented); Base.Initialize(self, context, frame); self.TextObject = nil
	self._buttons, self._options, self._callback = {}, {}, callback
	local initial = initialCandidate
	local function val(option)
		if type(option) ~= "table" then return option end
		if option.Value ~= nil then return option.Value end
		return option.Text
	end
	local function txt(option)
		if type(option) ~= "table" then return tostring(option) end
		if option.Text ~= nil then return tostring(option.Text) end
		return tostring(option.Value)
	end
	for index, option in ipairs(options.Options) do
		local value = val(option); table.insert(self._options, value)
		local button = Builder.Create("TextButton", { Name = "Option", LayoutOrder = index, Size = UDim2.new(1 / #options.Options, -3, 1, 0),
			BackgroundColor3 = theme:Get("SurfaceRaised"), BorderSizePixel = 0, AutoButtonColor = false,
			Text = txt(option), TextSize = 12, Font = Enum.Font.GothamMedium, TextColor3 = theme:Get("MutedText") }, frame)
		Builder.Corner(button, 5); self._buttons[value] = button
		self:Connect(button.Activated, function() if self.Enabled then self:FocusWindow(); self:SetValue(value, true) end end)
	end
	function self:GetValue() return self._value end
	function self:SetValue(value, fireCallback)
		if self._destroyed then return end
		local valid = false; for _, candidate in ipairs(self._options) do if candidate == value then valid = true; break end end
		assert(valid, "Valor no disponible en Segmented")
		local changed = self._value ~= value; self._value = value
		for candidate, button in pairs(self._buttons) do
			local selected = candidate == value
			button.BackgroundColor3 = selected and theme:Get("Accent") or theme:Get("SurfaceRaised")
			button.TextColor3 = selected and theme:Get("AccentText") or theme:Get("MutedText")
		end
		if changed and fireCallback == true and self._callback then task.spawn(self._callback, value, self) end
	end
	if initial == nil then initial = self._options[1] end
	self._value = initial; self:SetValue(self._value, false)
	function self:SetEnabled(enabled)
		if self._destroyed then return end
		Base.SetEnabled(self, enabled)
		for _, button in pairs(self._buttons) do
			button.Active = self.Enabled; button.Selectable = self.Enabled
			button.TextTransparency = self.Enabled and 0 or 0.4
		end
	end
	self:SetEnabled(options.Enabled ~= false)
	return self
end
return Segmented
