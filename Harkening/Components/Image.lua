local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local Image = {}
Image.__index = Image
setmetatable(Image, { __index = Base })
function Image.new(context, parent, options)
	options = options or {}
	local width = options.Width or 120
	local height = options.Height or 90
	local image = Builder.Create("ImageLabel", { Name = options.Name or "Image", BackgroundColor3 = context.Theme:Get("Surface"),
		BackgroundTransparency = options.BackgroundTransparency == nil and 0 or options.BackgroundTransparency,
		BorderSizePixel = 0, Image = options.Image or "", Size = UDim2.new(1, 0, 0, height),
		ScaleType = options.ScaleType or Enum.ScaleType.Fit, ImageColor3 = options.ImageColor3 or Color3.new(1, 1, 1),
		ImageTransparency = options.ImageTransparency or 0, ResampleMode = options.ResampleMode or Enum.ResamplerMode.Default }, parent)
	if options.FixedWidth then image.Size = UDim2.fromOffset(width, height) end
	if options.CornerRadius then Builder.Corner(image, options.CornerRadius) end
	local self = setmetatable({}, Image); Base.Initialize(self, context, image); self.ImageObject = image
	function self:SetImage(contentId) if self._destroyed then return end; assert(type(contentId) == "string", "SetImage espera string"); image.Image = contentId end
	function self:GetImage() return image.Image end
	return self
end
return Image
