local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local IconRenderer = require("../Utilities/IconRenderer")

local Badge = {}
Badge.__index = Badge
setmetatable(Badge, { __index = Base })

local VARIANTS = {
    Accent = { Theme = "Accent", Text = "Accent", Transparency = 0.86 },
    Success = { Theme = "Success", Text = "Success", Transparency = 0.87 },
    Warning = { Theme = "Warning", Text = "Warning", Transparency = 0.87 },
    Danger = { Theme = "Danger", Text = "Danger", Transparency = 0.87 },
    Info = { Theme = "Info", Text = "Info", Transparency = 0.87 },
    Neutral = { Theme = "BorderSubtle", Text = "MutedText", Transparency = 0.18 },
}

function Badge.new(context, parent, options)
    options = options or {}
    local theme = context.Theme
    local variantName = VARIANTS[options.Variant] and options.Variant or "Neutral"
    local variant = VARIANTS[variantName]
    local textValue = tostring(options.Text or options.Title or "Badge")
    local textSize = options.TextSize or 10
    local hasIcon = options.Icon ~= nil and options.Icon ~= false
    local horizontalPadding = hasIcon and 31 or 18
    local width = options.Width or math.max(42, #textValue * textSize * 0.61 + horizontalPadding)
    local frame = Builder.Create("Frame", {
        Name = options.Name or "Badge",
        Size = UDim2.fromOffset(width, options.Height or 24),
        BackgroundColor3 = options.BackgroundColor or theme:Get(variant.Theme),
        BackgroundTransparency = options.BackgroundTransparency == nil and variant.Transparency or options.BackgroundTransparency,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, parent)
    Builder.Corner(frame, options.Radius or 8)
    local stroke = Builder.Stroke(frame, options.StrokeColor or theme:Get(variant.Theme), options.StrokeTransparency or 0.64, 1)

    local icon
    if hasIcon then
        icon = IconRenderer.Create(frame, options.Icon, {
            Name = "BadgeIcon", Size = UDim2.fromOffset(12, 12), Position = UDim2.new(0, 7, 0.5, -6),
            Color = options.IconColor or theme:Get(variant.Text), Fallback = "tag", TextSize = 12,
        })
    end
    local label = Builder.Label(frame, "Text", textValue,
        UDim2.new(1, -(hasIcon and 25 or 12), 1, 0), UDim2.new(0, hasIcon and 23 or 6, 0, 0),
        options.TextColor or theme:Get(variant.Text), textSize, options.Bold ~= false)
    label.TextXAlignment = options.TextXAlignment or Enum.TextXAlignment.Center
    label.TextTruncate = Enum.TextTruncate.AtEnd

    local self = setmetatable({}, Badge)
    Base.Initialize(self, context, frame)
    self.TextObject = label
    self.IconObject = icon
    self.StrokeObject = stroke
    self._variant = variantName
    self._options = options

    local function updateWidth()
        frame.Size = UDim2.fromOffset(options.Width or math.max(42, #label.Text * textSize * 0.61 + horizontalPadding), options.Height or 24)
    end

    function self:SetText(value)
        if self._destroyed then return end
        label.Text = tostring(value)
        updateWidth()
    end

    function self:SetVariant(nextVariant)
        if self._destroyed then return end
        variantName = VARIANTS[nextVariant] and nextVariant or "Neutral"
        variant = VARIANTS[variantName]
        self._variant = variantName
        frame.BackgroundColor3 = options.BackgroundColor or theme:Get(variant.Theme)
        frame.BackgroundTransparency = options.BackgroundTransparency == nil and variant.Transparency or options.BackgroundTransparency
        label.TextColor3 = options.TextColor or theme:Get(variant.Text)
        stroke.Color = options.StrokeColor or theme:Get(variant.Theme)
        if icon then
            if icon:IsA("ImageLabel") then icon.ImageColor3 = options.IconColor or theme:Get(variant.Text)
            else icon.TextColor3 = options.IconColor or theme:Get(variant.Text) end
        end
    end

    function self:SetIcon(value)
        if self._destroyed then return end
        if icon and icon.Parent then icon:Destroy() end
        icon = nil
        hasIcon = value ~= nil and value ~= false
        horizontalPadding = hasIcon and 31 or 18
        if hasIcon then
            icon = IconRenderer.Create(frame, value, { Name = "BadgeIcon", Size = UDim2.fromOffset(12, 12),
                Position = UDim2.new(0, 7, 0.5, -6), Color = options.IconColor or theme:Get(variant.Text), Fallback = "tag", TextSize = 12 })
        end
        self.IconObject = icon
        label.Position = UDim2.new(0, hasIcon and 23 or 6, 0, 0)
        label.Size = UDim2.new(1, -(hasIcon and 25 or 12), 1, 0)
        updateWidth()
    end

    function self:GetVariant()
        return self._variant
    end

    return self
end

return Badge
