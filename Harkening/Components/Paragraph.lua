local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local Paragraph = {}
Paragraph.__index = Paragraph
setmetatable(Paragraph, { __index = Base })
function Paragraph.new(context, parent, options)
	options = options or {}
	local theme = context.Theme
	local frame = Builder.Create("Frame", { Name = options.Name or "Paragraph", BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, parent)
	local layout = Builder.Create("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 3) }, frame)
	local title
	if options.Title and options.Title ~= "" then
		title = Builder.Label(frame, "Title", tostring(options.Title), UDim2.new(1, -4, 0, 20), UDim2.new(), theme:Get("Text"), 13, true)
		title.LayoutOrder = 1
	end
	local body = Builder.Label(frame, "Text", tostring(options.Text or options.Description or ""), UDim2.new(1, -4, 0, 0), UDim2.new(),
		options.Color or theme:Get("MutedText"), options.TextSize or 12, false)
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.TextYAlignment = Enum.TextYAlignment.Top
	body.LayoutOrder = 2
	local self = setmetatable({}, Paragraph); Base.Initialize(self, context, frame); self.TextObject = body; self.TitleObject = title
	function self:SetText(value) if self._destroyed then return end; assert(type(value) == "string", "SetText espera string"); body.Text = value end
	function self:SetTitle(value)
		if self._destroyed then return end
		assert(type(value) == "string", "SetTitle espera string")
		if not title then title = Builder.Label(frame, "Title", value, UDim2.new(1, -4, 0, 20), UDim2.new(), theme:Get("Text"), 13, true); title.LayoutOrder = 1; self.TitleObject = title
		else title.Text = value end
	end
	return self
end
return Paragraph
