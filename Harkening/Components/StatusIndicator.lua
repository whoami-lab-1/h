local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local StatusIndicator = {}; StatusIndicator.__index = StatusIndicator; setmetatable(StatusIndicator, { __index = Base })
local function colorFor(theme, status)
    local s = string.lower(tostring(status or "offline"))
    if s == "ready" or s == "running" or s == "online" or s == "success" or s == "connected" then return theme:Get("Success") end
    if s == "warning" or s == "pending" or s == "loading" or s == "initializing" then return theme:Get("Warning") end
    if s == "error" or s == "failed" or s == "offline" or s == "disconnected" then return theme:Get("Danger") end
    return theme:Get("Accent")
end
function StatusIndicator.new(context, parent, options)
    options = options or {}; local theme = context.Theme
    local frame = Builder.Create("Frame", { Name = options.Name or "StatusIndicator", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, options.Height or 24) }, parent)
    local dot = Builder.Create("Frame", { Name = "Dot", BackgroundColor3 = colorFor(theme, options.Status or "READY"), BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(8, 8) }, frame); Builder.Corner(dot, 5)
    local label = Builder.Label(frame, "Label", tostring(options.Text or options.Status or "READY"), UDim2.new(1, -20, 1, 0), UDim2.new(0, 18, 0, 0), theme:Get("Text"), options.TextSize or 12, options.Bold == true)
    local self = setmetatable({}, StatusIndicator); Base.Initialize(self, context, frame); self.TextObject = label; self._dot = dot
    function self:SetStatus(status, text)
        if self._destroyed then return end
        status = tostring(status or "READY"); dot.BackgroundColor3 = colorFor(theme, status); label.Text = tostring(text or status)
    end
    function self:SetText(text) if not self._destroyed then label.Text = tostring(text) end end
    return self
end
return StatusIndicator
