local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local RadioGroup = {}; RadioGroup.__index = RadioGroup; setmetatable(RadioGroup, { __index = Base })
local function normalize(option)
    if type(option) ~= "table" then return { Value = option, Text = tostring(option), Disabled = false } end
    local value = option.Value; if value == nil then value = option.Text end
    assert(value ~= nil, "RadioGroup option necesita Value o Text")
    return { Value = value, Text = tostring(option.Text or value), Description = option.Description, Disabled = option.Disabled == true }
end
function RadioGroup.new(context, parent, options)
    options = options or {}; local theme = context.Theme; local callback = options.Callback
    assert(callback == nil or type(callback) == "function", "Callback debe ser función")
    local frame = Builder.Create("Frame", { Name = options.Name or "RadioGroup", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, parent)
    local layout = Builder.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, options.Spacing or 4),
        FillDirection = options.Direction == "Horizontal" and Enum.FillDirection.Horizontal or Enum.FillDirection.Vertical }, frame)
    local self = setmetatable({}, RadioGroup); Base.Initialize(self, context, frame); self.Options = {}; self._buttons = {}; self._value = options.Value
    if options.Title then Builder.Label(frame, "Title", tostring(options.Title), UDim2.new(1, 0, 0, 20), UDim2.new(), theme:Get("Text"), 12, true).LayoutOrder = 0 end
    local function update()
        for _, record in ipairs(self._buttons) do
            local selected = record.Option.Value == self._value
            record.Dot.BackgroundColor3 = selected and theme:Get("Accent") or theme:Get("SurfaceRaised")
            record.Stroke.Transparency = selected and 0 or 1
            record.Label.TextColor3 = record.Option.Disabled and theme:Get("Disabled") or theme:Get("Text")
        end
    end
    function self:SetValue(value, fireCallback)
        if self._destroyed then return end
        local valid = false
        for _, option in ipairs(self.Options) do if option.Value == value and not option.Disabled then valid = true; break end end
        assert(valid or value == nil, "Valor no válido para RadioGroup: " .. tostring(value))
        local changed = self._value ~= value; self._value = value; update()
        if changed and fireCallback == true and callback then task.spawn(callback, value, self) end
    end
    function self:GetValue() return self._value end
    function self:SetOptions(newOptions)
        assert(type(newOptions) == "table", "SetOptions espera tabla")
        for _, record in ipairs(self._buttons) do if record.Frame.Parent then record.Frame:Destroy() end end
        table.clear(self.Options); table.clear(self._buttons)
        for index, raw in ipairs(newOptions) do
            local option = normalize(raw)
            for _, prior in ipairs(self.Options) do assert(prior.Value ~= option.Value, "RadioGroup contiene valores duplicados") end
            table.insert(self.Options, option)
            local row = Builder.Create("TextButton", { Name = "Radio_" .. tostring(index), BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0,
                Size = options.Direction == "Horizontal" and UDim2.new(0, options.OptionWidth or 130, 0, 34) or UDim2.new(1, 0, 0, option.Description and 49 or 34),
                Text = "", AutoButtonColor = false, LayoutOrder = index }, frame)
            Builder.Corner(row, 6)
            local dot = Builder.Create("Frame", { Name = "Dot", BackgroundColor3 = theme:Get("SurfaceRaised"), BorderSizePixel = 0,
                Position = UDim2.new(0, 9, 0, option.Description and 14 or 10), Size = UDim2.fromOffset(14, 14) }, row); Builder.Corner(dot, 10)
            local stroke = Builder.Stroke(dot, theme:Get("Accent"), 1, 2)
            local label = Builder.Label(row, "Label", option.Text, UDim2.new(1, -38, 0, option.Description and 19 or 34), UDim2.new(0, 31, 0, 0), theme:Get("Text"), 11, true)
            if option.Description then Builder.Label(row, "Description", tostring(option.Description), UDim2.new(1, -38, 0, 16), UDim2.new(0, 31, 0, 23), theme:Get("MutedText"), 9) end
            local record = { Option = option, Frame = row, Dot = dot, Stroke = stroke, Label = label }; table.insert(self._buttons, record)
            self:Connect(row.Activated, function() if self.Enabled and not option.Disabled then self:FocusWindow(); self:SetValue(option.Value, true) end end)
            row.Active = not option.Disabled
        end
        if self._value ~= nil then
            local valid = false; for _, option in ipairs(self.Options) do if option.Value == self._value and not option.Disabled then valid = true end end
            if not valid then self._value = nil end
        end
        update()
    end
    self:SetOptions(options.Options or {})
    return self
end
return RadioGroup
