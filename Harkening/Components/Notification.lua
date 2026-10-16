local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local IconRenderer = require("../Utilities/IconRenderer")

local Notification = {}
Notification.__index = Notification
setmetatable(Notification, { __index = Base })

local TYPE_STYLE = {
    Success = { Color = "Success", Icon = "success" },
    Error = { Color = "Danger", Icon = "error" },
    Warning = { Color = "Warning", Icon = "warning" },
    Info = { Color = "Info", Icon = "info" },
    Default = { Color = "Accent", Icon = "bell" },
}

function Notification.new(context, options)
    options = options or {}
    local theme = context.Theme
    local kind = TYPE_STYLE[options.Type or options.Variant or "Default"] and (options.Type or options.Variant or "Default") or "Default"
    local style = TYPE_STYLE[kind]
    local color = options.Color or theme:Get(style.Color)
    local width = math.clamp(tonumber(options.Width) or 336, 240, 480)
    local hasDescription = options.Description ~= nil and tostring(options.Description) ~= ""
    local height = math.clamp(tonumber(options.Height) or (hasDescription and 92 or 70), 62, 160)
    local offscreen = UDim2.new(1, width + 30, 0, options.OffsetY or 24)
    local frame = Builder.Create("Frame", { Name = "Notification", AnchorPoint = Vector2.new(1, 0),
        Position = offscreen, Size = UDim2.fromOffset(width, height), BackgroundColor3 = theme:Get("Surface"),
        BorderSizePixel = 0, ZIndex = 11000, ClipsDescendants = true }, context.Gui)
    Builder.Corner(frame, 11); Builder.Stroke(frame, theme:Get("Border"), 0.12, 1)
    Builder.Create("UIGradient", { Rotation = 90, Color = ColorSequence.new(theme:Get("SurfaceRaised"), theme:Get("Surface")) }, frame)
    Builder.Create("Frame", { Name = "AccentBar", BackgroundColor3 = color, BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, -16), Position = UDim2.new(0, 0, 0, 8), ZIndex = 11001 }, frame)
    local iconHolder = Builder.Create("Frame", { Name = "IconHolder", Position = UDim2.new(0, 13, 0, 14),
        Size = UDim2.fromOffset(34, 34), BackgroundColor3 = color, BackgroundTransparency = 0.86,
        BorderSizePixel = 0, ZIndex = 11001 }, frame)
    Builder.Corner(iconHolder, 9); Builder.Stroke(iconHolder, color, 0.62, 1)
    IconRenderer.Create(iconHolder, options.Icon or style.Icon, { Size = UDim2.fromOffset(17, 17),
        Position = UDim2.new(0.5, -8.5, 0.5, -8.5), Color = color, TextSize = 17 })
    local title = Builder.Label(frame, "Title", tostring(options.Title or "Notification"),
        UDim2.new(1, -104, 0, 20), UDim2.new(0, 57, 0, 13), theme:Get("Text"), 12, true)
    title.ZIndex = 11002; title.TextTruncate = Enum.TextTruncate.AtEnd
    local badge = Builder.Label(frame, "Type", tostring(options.Label or string.upper(kind)), UDim2.new(1, -104, 0, 13),
        UDim2.new(0, 57, 0, 33), color, 8, true)
    badge.ZIndex = 11002; badge.TextTruncate = Enum.TextTruncate.AtEnd
    local body
    if hasDescription then
        body = Builder.Label(frame, "Description", tostring(options.Description), UDim2.new(1, -70, 0, math.max(18, height - 58)),
            UDim2.new(0, 13, 0, 55), theme:Get("MutedText"), 10, false)
        body.ZIndex = 11002; body.TextYAlignment = Enum.TextYAlignment.Top
    end
    local close = Builder.Create("TextButton", { Name = "Close", AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -8, 0, 8), Size = UDim2.fromOffset(24, 24), BackgroundColor3 = theme:Get("SurfaceRaised"),
        BackgroundTransparency = 0.1, BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 11003 }, frame)
    Builder.Corner(close, 7)
    IconRenderer.Create(close, "close", { Size = UDim2.fromOffset(12, 12), Position = UDim2.new(0.5, -6, 0.5, -6), Color = theme:Get("MutedText"), TextSize = 13 })
    local progress = Builder.Create("Frame", { Name = "Lifetime", Position = UDim2.new(0, 0, 1, -2), Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = color, BorderSizePixel = 0, ZIndex = 11004 }, frame)

    local self = setmetatable({}, Notification)
    Base.Initialize(self, context, frame)
    self.TextObject = title; self._offsetY = options.OffsetY or 24; self._closing = false
    self._timer = nil; self._closeThread = nil
    self._cleanup:Add(function()
        for _, key in ipairs({ "_timer", "_closeThread" }) do
            local thread = self[key]; self[key] = nil
            if thread then pcall(task.cancel, thread) end
        end
    end)
    self:Connect(close.Activated, function() self:Close() end)
    self:Connect(close.MouseEnter, function() context.Tweens:To(close, { BackgroundColor3 = theme:Get("SurfaceHover") }, { Time = 0.1 }) end)
    self:Connect(close.MouseLeave, function() context.Tweens:To(close, { BackgroundColor3 = theme:Get("SurfaceRaised") }, { Time = 0.1 }) end)
    context.Tweens:To(frame, { Position = UDim2.new(1, -18, 0, self._offsetY) }, { Time = 0.24, Style = Enum.EasingStyle.Quint })

    function self:SetOffsetY(value)
        if self._destroyed then return end
        self._offsetY = tonumber(value) or 24
        if frame.Parent then context.Tweens:To(frame, { Position = UDim2.new(1, -18, 0, self._offsetY) }, { Time = 0.16 }) end
    end
    function self:SetType(nextType)
        if self._destroyed then return end
        local nextStyle = TYPE_STYLE[nextType] or TYPE_STYLE.Default
        local nextColor = theme:Get(nextStyle.Color)
        badge.Text = string.upper(nextType or "Default"); badge.TextColor3 = nextColor
        progress.BackgroundColor3 = nextColor
        iconHolder.BackgroundColor3 = nextColor
        color = nextColor
    end
    function self:Close()
        if self._destroyed or self._closing then return end
        self._closing = true
        if self._timer then pcall(task.cancel, self._timer); self._timer = nil end
        context.Tweens:To(frame, { Position = UDim2.new(1, width + 30, 0, self._offsetY), BackgroundTransparency = 1 }, { Time = 0.16 })
        self._closeThread = task.delay(0.18, function()
            self._closeThread = nil
            if not self._destroyed then self:Destroy() end
        end)
    end
    local duration = tonumber(options.Duration)
    if duration == nil then duration = 4 end
    if duration > 0 then
        context.Tweens:To(progress, { Size = UDim2.new(0, 0, 0, 2) }, { Time = duration, EasingStyle = Enum.EasingStyle.Linear })
        self._timer = task.delay(duration, function() self._timer = nil; if not self._destroyed then self:Close() end end)
    else
        progress.Visible = false
    end
    return self
end
return Notification
