local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local LogViewer = {}; LogViewer.__index = LogViewer; setmetatable(LogViewer, { __index = Base })
local function color(theme, level)
    level = string.upper(tostring(level or "INFO"))
    if level == "ERROR" then return theme:Get("Danger") end
    if level == "WARN" or level == "WARNING" then return Color3.fromRGB(241, 184, 75) end
    if level == "SUCCESS" then return theme:Get("Success") end
    return theme:Get("MutedText")
end
function LogViewer.new(context, parent, options)
    options = options or {}; local theme = context.Theme
    local frame = Builder.Create("Frame", { Name = options.Name or "LogViewer", BackgroundColor3 = theme:Get("Background"), BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, options.Height or 190), ClipsDescendants = true }, parent)
    Builder.Corner(frame, theme:Get("CornerRadius")); Builder.Stroke(frame, theme:Get("Border"), 0.4, 1)
    local body = Builder.Create("ScrollingFrame", { Name = "Logs", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.new(0, 0, 0, 4),
        Size = UDim2.new(1, 0, 1, -8), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 4 }, frame)
    Builder.Padding(body, 8, 6, 3, 3)
    Builder.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3) }, body)
    local self = setmetatable({}, LogViewer); Base.Initialize(self, context, frame); self.Lines = {}; self._lineFrames = {}; self._maxLines = math.clamp(tonumber(options.MaxLines) or 200, 10, 2000); self._body = body
    local function redraw()
        for _, row in ipairs(self._lineFrames) do if row.Parent then row:Destroy() end end; table.clear(self._lineFrames)
        for index, line in ipairs(self.Lines) do
            local row = Builder.Create("Frame", { Name = "LogLine", LayoutOrder = index, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 17) }, body)
            local timestamp = Builder.Label(row, "Timestamp", tostring(line.Time or ""), UDim2.new(0, 58, 1, 0), UDim2.new(), theme:Get("MutedText"), 9)
            local level = Builder.Label(row, "Level", string.upper(tostring(line.Level or "INFO")), UDim2.new(0, 46, 1, 0), UDim2.new(0, 60, 0, 0), color(theme, line.Level), 9, true)
            local message = Builder.Label(row, "Message", tostring(line.Message or ""), UDim2.new(1, -112, 1, 0), UDim2.new(0, 109, 0, 0), theme:Get("Text"), 10)
            message.TextTruncate = Enum.TextTruncate.AtEnd; table.insert(self._lineFrames, row)
        end
        task.defer(function() if body.Parent then body.CanvasPosition = Vector2.new(0, math.max(0, body.AbsoluteCanvasSize.Y - body.AbsoluteSize.Y)) end end)
    end
    function self:Append(message, level)
        if self._destroyed then return end
        table.insert(self.Lines, { Time = os.date("%H:%M:%S"), Level = level or "INFO", Message = tostring(message) })
        while #self.Lines > self._maxLines do table.remove(self.Lines, 1) end
        redraw()
    end
    function self:SetLines(lines)
        assert(type(lines) == "table", "SetLines espera una tabla")
        self.Lines = {}
        for _, line in ipairs(lines) do
            if type(line) == "table" then table.insert(self.Lines, { Time = tostring(line.Time or os.date("%H:%M:%S")), Level = line.Level or "INFO", Message = tostring(line.Message or line.Text or "") })
            else table.insert(self.Lines, { Time = os.date("%H:%M:%S"), Level = "INFO", Message = tostring(line) }) end
        end
        while #self.Lines > self._maxLines do table.remove(self.Lines, 1) end; redraw()
    end
    function self:GetLines() local out = {}; for i, row in ipairs(self.Lines) do out[i] = table.clone(row) end; return out end
    function self:Clear() self.Lines = {}; redraw() end
    self:SetLines(options.Lines or {})
    return self
end
return LogViewer
