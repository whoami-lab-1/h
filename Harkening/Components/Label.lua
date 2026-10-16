local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local Label = {}
Label.__index = Label
setmetatable(Label, { __index = Base })
function Label.new(context, parent, options)
	options = options or {}
	local theme = context.Theme
	local frame = Builder.Create("Frame", { Name = options.Name or "Label", BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, options.Height or 24) }, parent)
	local text = Builder.Label(frame, "Text", tostring(options.Text or options.Title or "Label"), UDim2.new(1, -4, 1, 0), UDim2.new(0, 2, 0, 0),
		options.Color or theme:Get("Text"), options.TextSize or 13, options.Bold == true)
	text.TextWrapped = options.TextWrapped ~= false
	local self = setmetatable({}, Label); Base.Initialize(self, context, frame); self.TextObject = text
	function self:SetText(value) if self._destroyed then return end; assert(type(value) == "string", "SetText espera string"); text.Text = value end
	function self:GetText() return text.Text end
	return self
end
return Label
