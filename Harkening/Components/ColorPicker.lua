local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local ColorPicker = {}; ColorPicker.__index = ColorPicker; setmetatable(ColorPicker, { __index = Base })
local function toHex(color)
    return string.format("#%02X%02X%02X", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
end
local function fromHex(text)
    text = string.gsub(text, "#", "")
    if #text ~= 6 or not string.match(text, "^%x%x%x%x%x%x$") then return nil end
    return Color3.fromRGB(tonumber(string.sub(text, 1, 2), 16), tonumber(string.sub(text, 3, 4), 16), tonumber(string.sub(text, 5, 6), 16))
end
function ColorPicker.new(context, parent, options)
    options = options or {}; local theme = context.Theme; local callback = options.Callback
    assert(callback == nil or type(callback) == "function", "Callback debe ser función")
    local initial = typeof(options.Value) == "Color3" and options.Value or Color3.fromRGB(104, 164, 255)
    local frame = Builder.Create("Frame", { Name = options.Name or "ColorPicker", BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, options.Height or 54) }, parent)
    Builder.Corner(frame, theme:Get("CornerRadius"))
    local title = Builder.Label(frame, "Title", tostring(options.Title or "Color"), UDim2.new(1, -110, 0, 20), UDim2.new(0, 10, 0, 5), theme:Get("Text"), 12, true)
    local swatch = Builder.Create("TextButton", { Name = "Swatch", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(35, 28), BackgroundColor3 = initial, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, frame)
    Builder.Corner(swatch, 6); Builder.Stroke(swatch, theme:Get("Border"), 0, 1)
    local hex = Builder.Create("TextBox", { Name = "HexInput", Position = UDim2.new(0, 10, 0, 27), Size = UDim2.new(1, -65, 0, 20),
        BackgroundColor3 = theme:Get("Background"), BorderSizePixel = 0, Text = toHex(initial), ClearTextOnFocus = false,
        Font = Enum.Font.Code, TextSize = 11, TextColor3 = theme:Get("Text"),
        TextXAlignment = Enum.TextXAlignment.Left }, frame)
    Builder.Corner(hex, 4); Builder.Padding(hex, 6, 3, 0, 0)
    local self = setmetatable({}, ColorPicker); Base.Initialize(self, context, frame); self.TitleObject = title; self._value = initial; self._swatch = swatch; self._hex = hex; self._callback = callback
    function self:GetValue() return self._value end
    function self:SetValue(value, fireCallback)
        if self._destroyed then return end
        assert(typeof(value) == "Color3", "ColorPicker:SetValue espera Color3")
        local changed = value ~= self._value; self._value = value; swatch.BackgroundColor3 = value; hex.Text = toHex(value)
        if changed and fireCallback == true and self._callback then task.spawn(self._callback, value, self) end
    end
    self:Connect(swatch.Activated, function()
        if not self.Enabled then return end
        -- A lightweight inline editor avoids unexpected global popups; hex remains keyboard-editable.
        hex:CaptureFocus(); self:FocusWindow()
    end)
    self:Connect(hex.FocusLost, function()
        local parsed = fromHex(hex.Text)
        if parsed then self:SetValue(parsed, true) else hex.Text = toHex(self._value) end
    end)
    function self:SetEnabled(enabled) Base.SetEnabled(self, enabled); hex.TextEditable = self.Enabled; swatch.Active = self.Enabled end
    self:SetEnabled(options.Enabled ~= false)
    return self
end
return ColorPicker
