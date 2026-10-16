local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local Divider = {}
Divider.__index = Divider
setmetatable(Divider, { __index = Base })
function Divider.new(context, parent, options)
	options = options or {}
	local frame = Builder.Create("Frame", { Name = options.Name or "Divider", BorderSizePixel = 0,
		BackgroundColor3 = options.Color or context.Theme:Get("Border"),
		Size = UDim2.new(1, 0, 0, options.Thickness or 1) }, parent)
	local self = setmetatable({}, Divider); Base.Initialize(self, context, frame); return self
end
return Divider
