local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local Validation = require("../Utilities/Validation")
local Slider = {}
Slider.__index = Slider
setmetatable(Slider, { __index = Base })

function Slider.new(context, parent, options)
	options = Validation.Options(options, "Slider options")
	local theme = context.Theme
	local minimum, maximum = Validation.Range(options.Min, options.Max, 0, 100)
	local step = Validation.Step(options.Step, 1)
	local initial = Validation.Number(options.Value, "Value", options.Default or minimum)
	local callback = Validation.Callback(options.Callback)
	local frame = Builder.Create("Frame", { Name = options.Name or "Slider", BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, options.Height or 60) }, parent)
	Builder.Corner(frame, theme:Get("CornerRadius"))
	local titleLabel = Builder.Label(frame, "Title", options.Title or "Slider", UDim2.new(0.7, -12, 0, 22), UDim2.new(0, 12, 0, 4), theme:Get("Text"), 14, true)
	local valueLabel = Builder.Label(frame, "Value", "", UDim2.new(0, 90, 0, 22), UDim2.new(1, -102, 0, 4), theme:Get("MutedText"), 12)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	local track = Builder.Create("TextButton", { Name = "Track", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
		BackgroundColor3 = theme:Get("Border"), Position = UDim2.new(0, 12, 0, 36), Size = UDim2.new(1, -24, 0, 8) }, frame)
	Builder.Corner(track, 4)
	local fill = Builder.Create("Frame", { Name = "Fill", BackgroundColor3 = theme:Get("Accent"), BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0) }, track)
	Builder.Corner(fill, 4)
	local knob = Builder.Create("Frame", { Name = "Knob", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(14, 14), BackgroundColor3 = theme:Get("Text"), BorderSizePixel = 0 }, track)
	Builder.Corner(knob, 7)
	local pointer = Builder.Create("TextButton", { Name = "InputArea", BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
		Size = UDim2.new(1, 12, 1, 18), Position = UDim2.new(0, -6, 0, -5), ZIndex = track.ZIndex + 1 }, track)
	local self = setmetatable({}, Slider)
	Base.Initialize(self, context, frame)
	self.TextObject = titleLabel
	self._valueLabel, self._track, self._fill, self._knob, self._pointer = valueLabel, track, fill, knob, pointer
	self._minimum, self._maximum, self._step, self._callback = minimum, maximum, step, callback
	local function quantize(value)
		value = math.clamp(value, minimum, maximum)
		local steps = math.floor(((value - minimum) / step) + 0.5)
		return math.clamp(minimum + steps * step, minimum, maximum)
	end
	local function render()
		local alpha = (self._value - minimum) / (maximum - minimum)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		knob.Position = UDim2.new(alpha, 0, 0.5, 0)
		valueLabel.Text = tostring(self._value)
	end
	function self:GetValue() return self._value end
	function self:SetValue(value, fireCallback)
		if self._destroyed then return end
		value = quantize(Validation.Number(value, "value"))
		local changed = value ~= self._value
		self._value = value
		render()
		if changed and fireCallback == true and self._callback then task.spawn(self._callback, value, self) end
	end
	function self:Set(value, fireCallback) return self:SetValue(value, fireCallback) end
	local function moveTo(position)
		if not self.Enabled then return end
		local width = track.AbsoluteSize.X
		if width <= 0 then return end
		local alpha = math.clamp((position.X - track.AbsolutePosition.X) / width, 0, 1)
		self:SetValue(minimum + alpha * (maximum - minimum), true)
	end
	self:Connect(pointer.InputBegan, function(input)
		if not self.Enabled then return end
		self:FocusWindow()
		if context.Input:BeginDrag(input, moveTo, nil, self, context.Window) then moveTo(input.Position) end
	end)
	self._value = quantize(initial)
	function self:SetEnabled(enabled)
		if self._destroyed then return end
		Base.SetEnabled(self, enabled)
		self._pointer.Active = self.Enabled
		self._pointer.Selectable = self.Enabled
		self.Frame.BackgroundTransparency = self.Enabled and 0 or 0.4
	end
	render()
	self:SetEnabled(options.Enabled ~= false)
	return self
end

return Slider
