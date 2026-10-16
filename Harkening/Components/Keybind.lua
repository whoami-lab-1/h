local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local Validation = require("../Utilities/Validation")
local Keybind = {}
Keybind.__index = Keybind
setmetatable(Keybind, { __index = Base })
function Keybind.new(context, parent, options)
	options = options or {}
	local theme, callback = context.Theme, Validation.Callback(options.Callback)
	local userInputService = context.Services.UserInputService
	local initial = options.Value or options.Default or Enum.KeyCode.Unknown
	assert(typeof(initial) == "EnumItem" and initial.EnumType == Enum.KeyCode, "Keybind Value debe ser Enum.KeyCode")
	local frame = Builder.Create("Frame", { Name = options.Name or "Keybind", BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, options.Height or 42) }, parent); Builder.Corner(frame, theme:Get("CornerRadius"))
	local label = Builder.Label(frame, "Title", options.Title or "Keybind", UDim2.new(1, -112, 1, 0), UDim2.new(0, 12, 0, 0), theme:Get("Text"), 13, true)
	local capture = Builder.Create("TextButton", { Name = "Capture", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(94, 28), BackgroundColor3 = theme:Get("SurfaceRaised"), BorderSizePixel = 0,
		Text = initial == Enum.KeyCode.Unknown and "Unassigned" or initial.Name, TextColor3 = theme:Get("MutedText"),
		TextSize = 11, Font = Enum.Font.GothamMedium, AutoButtonColor = false }, frame); Builder.Corner(capture, 5)
	local self = setmetatable({}, Keybind); Base.Initialize(self, context, frame); self.TextObject = label
	self._value, self._callback, self._capturing = initial, callback, false
	function self:GetValue() return self._value end
	function self:SetValue(value, fireCallback)
		if self._destroyed then return end
		assert(typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode, "Keybind:SetValue espera Enum.KeyCode")
		local changed = self._value ~= value; self._value = value
		capture.Text = value == Enum.KeyCode.Unknown and "Unassigned" or value.Name
		if changed and fireCallback == true and self._callback then task.spawn(self._callback, value, self) end
	end
	function self:Capture()
		if self._destroyed then return end
		if not self.Enabled or self._capturing then return end
		self._capturing = true; capture.Text = "Press a key…"
	end
	self:Connect(capture.Activated, function() self:FocusWindow(); self:Capture() end)
	self._cleanup:Add(userInputService.InputBegan:Connect(function(input, processed)
		if not self._capturing or processed then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.Escape then self._capturing = false; self:SetValue(self._value, false); return end
			self._capturing = false; self:SetValue(input.KeyCode, true)
		end
	end))
	function self:SetEnabled(enabled)
		if self._destroyed then return end
		Base.SetEnabled(self, enabled); capture.Active = self.Enabled; capture.Selectable = self.Enabled
		if not self.Enabled then self._capturing = false; capture.BackgroundTransparency = 0.4 else capture.BackgroundTransparency = 0 end
	end
	self:SetEnabled(options.Enabled ~= false)
	return self
end
return Keybind
