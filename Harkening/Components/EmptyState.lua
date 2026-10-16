local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local IconRenderer = require("../Utilities/IconRenderer")

local EmptyState = {}
EmptyState.__index = EmptyState
setmetatable(EmptyState, { __index = Base })

function EmptyState.new(context, parent, options)
    options = options or {}
    local theme = context.Theme
    local frame = Builder.Create("Frame", {
        Name = options.Name or "EmptyState", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, options.Height or (options.ActionText and 132 or 94)),
    }, parent)

    local iconTile = Builder.Create("Frame", {
        Name = "IconTile", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0),
        Size = UDim2.fromOffset(options.IconTileSize or 34, options.IconTileSize or 34),
        BackgroundColor3 = theme:Get("SurfaceRaised"), BackgroundTransparency = 0.26, BorderSizePixel = 0,
    }, frame)
    Builder.Corner(iconTile, 11)
    Builder.Stroke(iconTile, theme:Get("BorderSubtle"), 0.52, 1)
    local icon = IconRenderer.Create(iconTile, options.Icon or "search", {
        Name = "Icon", Size = UDim2.fromOffset(18, 18), Position = UDim2.new(0.5, -9, 0.5, -9),
        Color = options.IconColor or theme:Get("MutedText"), Fallback = "search", TextSize = 18,
    })

    local titleY = 42
    local title = Builder.Label(frame, "Title", tostring(options.Title or "Nothing here yet"),
        UDim2.new(1, -12, 0, 20), UDim2.new(0, 6, 0, titleY), theme:Get("Text"), 12, true)
    title.TextXAlignment = Enum.TextXAlignment.Center

    local desc = Builder.Label(frame, "Description", tostring(options.Description or "Items will appear here when available."),
        UDim2.new(1, -24, 0, 30), UDim2.new(0, 12, 0, titleY + 22), theme:Get("MutedText"), 10)
    desc.TextXAlignment = Enum.TextXAlignment.Center
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.TextTruncate = Enum.TextTruncate.AtEnd

    local actionButton
    if type(options.ActionText) == "string" and options.ActionText ~= "" then
        actionButton = Builder.Create("TextButton", {
            Name = "ActionButton", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, titleY + 55),
            Size = UDim2.fromOffset(options.ActionWidth or math.clamp(32 + #options.ActionText * 6, 90, 210), 28),
            BackgroundColor3 = theme:Get("AccentSoft"), BorderSizePixel = 0,
            Text = options.ActionText, TextColor3 = theme:Get("Accent"), TextSize = 10,
            Font = Enum.Font.GothamSemibold, AutoButtonColor = false,
        }, frame)
        Builder.Corner(actionButton, 8)
        Builder.Stroke(actionButton, theme:Get("Accent"), 0.58, 1)
    end

    local self = setmetatable({}, EmptyState)
    Base.Initialize(self, context, frame)
    self.TitleObject = title
    self._description = desc
    self.IconObject = icon
    self.IconTile = iconTile
    self.ActionButton = actionButton

    function self:SetTitle(value)
        if not self._destroyed then title.Text = tostring(value) end
    end

    function self:SetDescription(value)
        if not self._destroyed then desc.Text = tostring(value) end
    end

    function self:SetIcon(value)
        if self._destroyed then return end
        if icon and icon.Parent then icon:Destroy() end
        icon = IconRenderer.Create(iconTile, value or "search", {
            Name = "Icon", Size = UDim2.fromOffset(18, 18), Position = UDim2.new(0.5, -9, 0.5, -9),
            Color = options.IconColor or theme:Get("MutedText"), Fallback = "search", TextSize = 18,
        })
        self.IconObject = icon
    end

    function self:SetAction(text, callback)
        if self._destroyed then return end
        if not actionButton and type(text) == "string" and text ~= "" then
            actionButton = Builder.Create("TextButton", {
                Name = "ActionButton", AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, titleY + 55),
                Size = UDim2.fromOffset(options.ActionWidth or math.clamp(32 + #text * 6, 90, 210), 28),
                BackgroundColor3 = theme:Get("AccentSoft"), BorderSizePixel = 0,
                Text = text, TextColor3 = theme:Get("Accent"), TextSize = 10,
                Font = Enum.Font.GothamSemibold, AutoButtonColor = false,
            }, frame)
            Builder.Corner(actionButton, 8)
            Builder.Stroke(actionButton, theme:Get("Accent"), 0.58, 1)
            self.ActionButton = actionButton
        elseif actionButton then
            actionButton.Text = tostring(text or "")
            actionButton.Visible = text ~= nil and text ~= ""
        end
        if actionButton then
            if self._actionConnection then self._actionConnection:Disconnect(); self._actionConnection = nil end
            if type(callback) == "function" then
                self._actionConnection = self:Connect(actionButton.Activated, function()
                    if self.Enabled and not self._destroyed then task.spawn(callback, self) end
                end)
            end
        end
    end

    if actionButton and type(options.Callback) == "function" then
        self._actionConnection = self:Connect(actionButton.Activated, function()
            if self.Enabled and not self._destroyed then task.spawn(options.Callback, self) end
        end)
    end

    return self
end

return EmptyState
