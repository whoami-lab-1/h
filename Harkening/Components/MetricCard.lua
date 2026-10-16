local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local IconRenderer = require("../Utilities/IconRenderer")

local MetricCard = {}
MetricCard.__index = MetricCard
setmetatable(MetricCard, { __index = Base })

function MetricCard.new(context, parent, options)
    options = options or {}
    local theme = context.Theme
    local hasIcon = options.Icon ~= nil and options.Icon ~= false
    local frame = Builder.Create("Frame", {
        Name = options.Name or "MetricCard",
        BackgroundColor3 = theme:Get(options.BackgroundTheme or "Surface"),
        BackgroundTransparency = options.BackgroundTransparency or 0.02,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, options.Height or 96),
        ClipsDescendants = true,
    }, parent)
    Builder.Corner(frame, options.CornerRadius or math.min(theme:Get("CornerRadius"), 10))
    Builder.Stroke(frame, theme:Get("BorderSubtle"), 0.56, 1)
    Builder.Padding(frame, 12, 12, 9, 8)

    local iconTile, iconObject
    if hasIcon then
        iconTile = Builder.Create("Frame", {
            Name = "MetricIconTile", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.fromOffset(options.IconTileSize or 30, options.IconTileSize or 30),
            BackgroundColor3 = options.IconBackgroundColor or theme:Get("AccentSoft"),
            BackgroundTransparency = 0.12, BorderSizePixel = 0,
        }, frame)
        Builder.Corner(iconTile, 8)
        Builder.Stroke(iconTile, options.IconStrokeColor or theme:Get("BorderSubtle"), 0.45, 1)
        iconObject = IconRenderer.Create(iconTile, options.Icon, {
            Name = "MetricIcon", Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0.5, -8, 0.5, -8),
            Color = options.IconColor or theme:Get("Accent"), Fallback = "chart", TextSize = 16,
        })
    end

    local title = Builder.Label(frame, "MetricTitle", tostring(options.Title or "Metric"),
        UDim2.new(1, hasIcon and -40 or 0, 0, 17), UDim2.new(), theme:Get("MutedText"), 10, true)
    title.TextTruncate = Enum.TextTruncate.AtEnd

    local value = Builder.Label(frame, "MetricValue", tostring(options.Value == nil and "—" or options.Value),
        UDim2.new(1, hasIcon and -40 or 0, 0, 34), UDim2.new(0, 0, 0, 23),
        options.ValueColor or theme:Get("Text"), options.ValueSize or 23, true)
    value.TextTruncate = Enum.TextTruncate.AtEnd

    local description = Builder.Label(frame, "MetricDescription", tostring(options.Description or options.Change or ""),
        UDim2.new(1, 0, 0, 15), UDim2.new(0, 0, 1, -17), options.DescriptionColor or theme:Get("MutedText"), 10)
    description.TextTruncate = Enum.TextTruncate.AtEnd

    local self = setmetatable({}, MetricCard)
    Base.Initialize(self, context, frame)
    self.TitleObject = title
    self.ValueObject = value
    self.DescriptionObject = description
    self.IconObject = iconObject
    self.IconTile = iconTile

    function self:SetValue(nextValue, descriptionText)
        if self._destroyed then return end
        value.Text = tostring(nextValue)
        if descriptionText ~= nil then description.Text = tostring(descriptionText) end
    end

    function self:GetValue()
        return value.Text
    end

    function self:SetDescription(text)
        if not self._destroyed then description.Text = tostring(text) end
    end

    function self:SetTitle(text)
        if not self._destroyed then title.Text = tostring(text) end
    end

    function self:SetIcon(nextIcon, nextColor)
        if self._destroyed then return end
        if iconTile and iconTile.Parent then iconTile:Destroy() end
        iconTile, iconObject = nil, nil
        if nextIcon ~= nil and nextIcon ~= false then
            iconTile = Builder.Create("Frame", {
                Name = "MetricIconTile", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
                Size = UDim2.fromOffset(options.IconTileSize or 30, options.IconTileSize or 30),
                BackgroundColor3 = options.IconBackgroundColor or theme:Get("AccentSoft"), BackgroundTransparency = 0.12,
                BorderSizePixel = 0,
            }, frame)
            Builder.Corner(iconTile, 8)
            Builder.Stroke(iconTile, options.IconStrokeColor or theme:Get("BorderSubtle"), 0.45, 1)
            iconObject = IconRenderer.Create(iconTile, nextIcon, {
                Name = "MetricIcon", Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0.5, -8, 0.5, -8),
                Color = nextColor or options.IconColor or theme:Get("Accent"), Fallback = "chart", TextSize = 16,
            })
        end
        self.IconTile, self.IconObject = iconTile, iconObject
        title.Size = UDim2.new(1, iconTile and -40 or 0, 0, 17)
        value.Size = UDim2.new(1, iconTile and -40 or 0, 0, 34)
    end

    return self
end

return MetricCard
