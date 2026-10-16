local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local Validation = require("../Utilities/Validation")
local Checkbox = {}; Checkbox.__index = Checkbox; setmetatable(Checkbox, { __index = Base })
function Checkbox.new(context, parent, options)
    options = Validation.Options(options, "Checkbox options"); local theme = context.Theme
    local initial = options.Value; if initial == nil then initial = options.Default end; if initial == nil then initial = false end
    assert(type(initial) == "boolean", "Checkbox.Value debe ser booleano")
    local callback = Validation.Callback(options.Callback)
    local height = options.Description and 58 or 38
    local frame = Builder.Create("Frame", { Name = options.Name or "Checkbox", BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, options.Height or height) }, parent); Builder.Corner(frame, theme:Get("CornerRadius"))
    local action = Builder.Create("TextButton", { Name = "Action", Size = UDim2.fromScale(1,1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, frame)
    local box = Builder.Create("Frame", { Name = "Box", BackgroundColor3 = theme:Get("Background"), BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0.5, -8), Size = UDim2.fromOffset(16,16) }, frame)
    Builder.Corner(box, 4); local outline = Builder.Stroke(box, theme:Get("Border"), 0, 1)
    local mark = Builder.Label(box, "Check", "✓", UDim2.fromScale(1,1), UDim2.new(), theme:Get("AccentText"), 12, true)
    mark.TextXAlignment = Enum.TextXAlignment.Center; mark.Visible = initial
    local title = Builder.Label(frame, "Title", tostring(options.Title or "Checkbox"), UDim2.new(1, -40, 0, 20), UDim2.new(0, 35, 0, options.Description and 5 or 0), theme:Get("Text"), 12, true)
    if options.Description then Builder.Label(frame, "Description", tostring(options.Description), UDim2.new(1, -42, 0, 20), UDim2.new(0, 35, 0, 28), theme:Get("MutedText"), 10) end
    local self = setmetatable({}, Checkbox); Base.Initialize(self, context, frame); self.TextObject = title; self._value = initial; self._callback = callback; self._mark = mark; self._box = box; self._outline = outline
    local function render(animated)
        local targetColor = self._value and theme:Get("Accent") or theme:Get("Background")
        if animated then context.Tweens:To(box, { BackgroundColor3 = targetColor }, { Time = 0.12 }) else box.BackgroundColor3 = targetColor end
        outline.Color = self._value and theme:Get("Accent") or theme:Get("Border"); mark.Visible = self._value
    end
    function self:GetValue() return self._value end
    function self:SetValue(value, fireCallback)
        assert(type(value) == "boolean", "Checkbox:SetValue espera booleano"); if self._destroyed then return end
        local changed = self._value ~= value; self._value = value; render(true)
        if changed and fireCallback == true and callback then task.spawn(callback, value, self) end
    end
    function self:Get() return self:GetValue() end
    function self:Set(value, fireCallback) return self:SetValue(value, fireCallback) end
    self:Connect(action.Activated, function() if self.Enabled then self:FocusWindow(); self:SetValue(not self._value, true) end end)
    self:Connect(action.MouseEnter, function() if self.Enabled then context.Tweens:To(frame, { BackgroundColor3 = theme:Get("SurfaceRaised") }, { Time = 0.1 }) end end)
    self:Connect(action.MouseLeave, function() if self.Enabled then context.Tweens:To(frame, { BackgroundColor3 = theme:Get("Surface") }, { Time = 0.1 }) end end)
    function self:SetEnabled(enabled) Base.SetEnabled(self, enabled); action.Active = self.Enabled; action.Selectable = self.Enabled; frame.BackgroundTransparency = self.Enabled and 0 or 0.4 end
    render(false); self:SetEnabled(options.Enabled ~= false); return self
end
return Checkbox
