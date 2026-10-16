local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local Validation = require("../Utilities/Validation")
local Toggle = {}
Toggle.__index = Toggle
setmetatable(Toggle, { __index = Base })

function Toggle.new(context, parent, options)
	options = Validation.Options(options, "Toggle options")
	local theme = context.Theme
	local title = Validation.String(options.Title, "Title", "Toggle", true)
	local description = Validation.String(options.Description, "Description", "", true)
	local callback = Validation.Callback(options.Callback)
	local initial = options.Value
	if initial == nil then initial = options.Default end
	if initial == nil then initial = false end
	assert(type(initial) == "boolean", "Toggle Value debe ser booleano")
	local height = description ~= "" and 58 or 42
	local frame = Builder.Create("Frame", { Name = options.Name or "Toggle", BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, options.Height or height) }, parent)
	Builder.Corner(frame, theme:Get("CornerRadius"))
	local action = Builder.Create("TextButton", { Name = "Action", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Text = "", AutoButtonColor = false }, frame)
	local titleLabel = Builder.Label(frame, "Title", title, UDim2.new(1, -78, 0, 22), UDim2.new(0, 12, 0, description ~= "" and 6 or 0), theme:Get("Text"), 14, true)
	local descLabel
	if description ~= "" then descLabel = Builder.Label(frame, "Description", description,
		UDim2.new(1, -78, 0, 20), UDim2.new(0, 12, 0, 30), theme:Get("MutedText"), 11) end
	local track = Builder.Create("Frame", { Name = "Track", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(40, 22), BackgroundColor3 = theme:Get("Disabled"), BorderSizePixel = 0 }, frame)
	Builder.Corner(track, 11)
	local knob = Builder.Create("Frame", { Name = "Knob", Position = UDim2.new(0, 3, 0.5, -8), Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0 }, track)
	Builder.Corner(knob, 8)
	local self = setmetatable({}, Toggle)
	Base.Initialize(self, context, frame)
	self.TextObject = titleLabel
	self.DescriptionObject = descLabel
	self._action, self._track, self._knob = action, track, knob
	self._callback = callback
	self._value = initial
	local function render(animated)
		local knobPosition = self._value and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
		local trackColor = self._value and theme:Get("Accent") or theme:Get("Disabled")
		if animated then
			context.Tweens:To(knob, { Position = knobPosition }, { Time = 0.14 })
			context.Tweens:To(track, { BackgroundColor3 = trackColor }, { Time = 0.14 })
		else knob.Position = knobPosition; track.BackgroundColor3 = trackColor end
	end
	function self:GetValue() return self._value end
	function self:SetValue(value, fireCallback)
		if self._destroyed then return end
		assert(type(value) == "boolean", "Toggle:SetValue espera booleano")
		local changed = value ~= self._value
		self._value = value
		render(true)
		if changed and fireCallback == true and self._callback then task.spawn(self._callback, value, self) end
	end
	function self:Set(value, fireCallback) return self:SetValue(value, fireCallback) end
	function self:Get() return self:GetValue() end
	self:Connect(action.Activated, function()
		if not self.Enabled then return end
		self:FocusWindow()
		self:SetValue(not self._value, true)
	end)
	self:Connect(action.MouseEnter, function() if self.Enabled then context.Tweens:To(frame, { BackgroundColor3 = theme:Get("SurfaceRaised") }, { Time = 0.1 }) end end)
	self:Connect(action.MouseLeave, function() if self.Enabled then context.Tweens:To(frame, { BackgroundColor3 = theme:Get("Surface") }, { Time = 0.1 }) end end)
	function self:SetEnabled(enabled)
		if self._destroyed then return end
		Base.SetEnabled(self, enabled)
		self._action.Active = self.Enabled
		self._action.Selectable = self.Enabled
		self.Frame.BackgroundTransparency = self.Enabled and 0 or 0.4
	end
	render(false)
	self:SetEnabled(options.Enabled ~= false)
	return self
end

return Toggle
