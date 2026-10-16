local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local Validation = require("../Utilities/Validation")
local Progress = {}
Progress.__index = Progress
setmetatable(Progress, { __index = Base })
function Progress.new(context, parent, options)
	options = options or {}
	local theme = context.Theme
	local min, max = Validation.Range(options.Min, options.Max, 0, 100)
	local initial = Validation.Number(options.Value, "Value", options.Default or min)
	local frame = Builder.Create("Frame", { Name = options.Name or "Progress", BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, options.Height or 42) }, parent)
	local title = Builder.Label(frame, "Title", tostring(options.Title or "Progress"), UDim2.new(0.75, 0, 0, 18), UDim2.new(0, 0, 0, 0), theme:Get("Text"), 12, true)
	local amount = Builder.Label(frame, "Value", "", UDim2.new(0.25, 0, 0, 18), UDim2.new(0.75, 0, 0, 0), theme:Get("MutedText"), 11)
	amount.TextXAlignment = Enum.TextXAlignment.Right
	local track = Builder.Create("Frame", { Name = "Track", BackgroundColor3 = theme:Get("Border"), BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 25), Size = UDim2.new(1, 0, 0, 8) }, frame); Builder.Corner(track, 4)
	local fill = Builder.Create("Frame", { Name = "Fill", BackgroundColor3 = options.Color or theme:Get("Accent"), BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0) }, track); Builder.Corner(fill, 4)
	local self = setmetatable({}, Progress); Base.Initialize(self, context, frame); self.TextObject = title
	self._value, self._min, self._max, self._fill, self._amount = initial, min, max, fill, amount
	function self:GetValue() return self._value end
	function self:SetValue(value)
		if self._destroyed then return end
		self._value = math.clamp(Validation.Number(value, "value"), min, max)
		local alpha = (self._value - min) / (max - min)
		context.Tweens:To(fill, { Size = UDim2.new(alpha, 0, 1, 0) }, { Time = 0.2 })
		amount.Text = options.ShowPercent == false and tostring(self._value) or (tostring(math.floor(alpha * 100 + 0.5)) .. "%")
	end
	self:SetValue(math.clamp(initial, min, max))
	return self
end
return Progress
