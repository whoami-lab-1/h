local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local Validation = require("../Utilities/Validation")
local RangeSlider = {}; RangeSlider.__index = RangeSlider; setmetatable(RangeSlider, { __index = Base })
function RangeSlider.new(context, parent, options)
    options = options or {}; local theme = context.Theme
    local min, max = Validation.Range(options.Min, options.Max, 0, 100); assert(max > min, "RangeSlider Max debe ser mayor que Min")
    local step = tonumber(options.Step) or 1; assert(step > 0, "Step debe ser positivo")
    local initialMin = math.clamp(tonumber(options.MinValue) or min, min, max)
    local initialMax = math.clamp(tonumber(options.MaxValue) or max, min, max)
    if initialMin > initialMax then initialMin, initialMax = initialMax, initialMin end
    local frame = Builder.Create("Frame", { Name = options.Name or "RangeSlider", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 58) }, parent)
    local title = Builder.Label(frame, "Title", tostring(options.Title or "Range"), UDim2.new(0.65, 0, 0, 18), UDim2.new(), theme:Get("Text"), 12, true)
    local valueLabel = Builder.Label(frame, "Value", "", UDim2.new(0.35, 0, 0, 18), UDim2.new(0.65, 0, 0, 0), theme:Get("MutedText"), 10)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    local track = Builder.Create("Frame", { Name = "Track", BackgroundColor3 = theme:Get("Border"), BorderSizePixel = 0, Position = UDim2.new(0, 4, 0, 34), Size = UDim2.new(1, -8, 0, 5) }, frame); Builder.Corner(track, 4)
    local fill = Builder.Create("Frame", { Name = "SelectedRange", BackgroundColor3 = theme:Get("Accent"), BorderSizePixel = 0, Size = UDim2.new(1, 0, 1, 0) }, track); Builder.Corner(fill, 4)
    local function makeHandle(name)
        local handle = Builder.Create("TextButton", { Name = name, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(14, 14), BackgroundColor3 = theme:Get("Text"), BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 3 }, track)
        Builder.Corner(handle, 9); Builder.Stroke(handle, theme:Get("Accent"), 0, 2); return handle
    end
    local lowHandle, highHandle = makeHandle("MinimumHandle"), makeHandle("MaximumHandle")
    local self = setmetatable({}, RangeSlider); Base.Initialize(self, context, frame)
    self.MinValue, self.MaxValue = initialMin, initialMax; self._min, self._max, self._step, self._callback = min, max, step, options.Callback
    local function snap(value) return math.clamp(min + math.floor((value - min) / step + 0.5) * step, min, max) end
    local function update()
        local a, b = (self.MinValue - min) / (max - min), (self.MaxValue - min) / (max - min)
        lowHandle.Position = UDim2.new(a, 0, 0.5, 0); highHandle.Position = UDim2.new(b, 0, 0.5, 0)
        fill.Position = UDim2.new(a, 0, 0, 0); fill.Size = UDim2.new(math.max(0, b - a), 0, 1, 0)
        valueLabel.Text = tostring(self.MinValue) .. " – " .. tostring(self.MaxValue)
    end
    function self:GetValue() return self.MinValue, self.MaxValue end
    function self:SetValue(low, high, fireCallback)
        if self._destroyed then return end
        low = snap(tonumber(low) or self.MinValue); high = snap(tonumber(high) or self.MaxValue)
        if low > high then low, high = high, low end
        local changed = low ~= self.MinValue or high ~= self.MaxValue; self.MinValue, self.MaxValue = low, high; update()
        if changed and fireCallback == true and type(self._callback) == "function" then task.spawn(self._callback, low, high, self) end
    end
    local function beginDrag(handle, isLow, input)
        if not self.Enabled then return end
        self:FocusWindow()
        local UIS = context.Services.UserInputService
        local changedConnection, endedConnection
        local function setFromX(x)
            local width = math.max(track.AbsoluteSize.X, 1)
            local alpha = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
            local value = snap(min + alpha * (max - min))
            if isLow then self:SetValue(math.min(value, self.MaxValue), self.MaxValue, true)
            else self:SetValue(self.MinValue, math.max(value, self.MinValue), true) end
        end
        setFromX(input.Position.X)
        changedConnection = UIS.InputChanged:Connect(function(moved)
            if moved.UserInputType == Enum.UserInputType.MouseMovement or moved.UserInputType == Enum.UserInputType.Touch then setFromX(moved.Position.X) end
        end)
        endedConnection = UIS.InputEnded:Connect(function(ended)
            if ended.UserInputType == Enum.UserInputType.MouseButton1 or ended.UserInputType == Enum.UserInputType.Touch then
                if changedConnection then changedConnection:Disconnect(); self._cleanup:Remove(changedConnection, false) end; if endedConnection then endedConnection:Disconnect(); self._cleanup:Remove(endedConnection, false) end
            end
        end)
        self._cleanup:Add(changedConnection); self._cleanup:Add(endedConnection)
    end
    self:Connect(lowHandle.InputBegan, function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then beginDrag(lowHandle, true, input) end end)
    self:Connect(highHandle.InputBegan, function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then beginDrag(highHandle, false, input) end end)
    function self:SetEnabled(enabled) Base.SetEnabled(self, enabled); lowHandle.Active = self.Enabled; highHandle.Active = self.Enabled; lowHandle.BackgroundTransparency = self.Enabled and 0 or 0.5; highHandle.BackgroundTransparency = lowHandle.BackgroundTransparency end
    update(); self:SetEnabled(options.Enabled ~= false); return self
end
return RangeSlider
