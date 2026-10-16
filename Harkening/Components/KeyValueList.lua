local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local KeyValueList = {}; KeyValueList.__index = KeyValueList; setmetatable(KeyValueList, { __index = Base })
function KeyValueList.new(context, parent, options)
    options = options or {}; local theme = context.Theme
    local frame = Builder.Create("Frame", { Name = options.Name or "KeyValueList", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, parent)
    local layout = Builder.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, options.Spacing or 4) }, frame)
    local self = setmetatable({}, KeyValueList); Base.Initialize(self, context, frame); self.Data = {}; self._rows = {}
    function self:SetData(data)
        assert(type(data) == "table", "SetData espera una tabla")
        if self._destroyed then return end
        for _, row in pairs(self._rows) do if row.Parent then row:Destroy() end end; table.clear(self._rows); self.Data = table.clone(data)
        local entries = {}
        for key, value in pairs(data) do table.insert(entries, { Key = tostring(key), Value = tostring(value) }) end
        table.sort(entries, function(a, b) return a.Key < b.Key end)
        for index, entry in ipairs(entries) do
            local row = Builder.Create("Frame", { Name = "PropertyRow", BackgroundTransparency = index % 2 == 0 and 0.65 or 1,
                BackgroundColor3 = theme:Get("SurfaceRaised"), Size = UDim2.new(1, 0, 0, 26), LayoutOrder = index }, frame)
            local keyLabel = Builder.Label(row, "Key", entry.Key, UDim2.new(0.42, -8, 1, 0), UDim2.new(0, 5, 0, 0), theme:Get("MutedText"), 11, true)
            local valLabel = Builder.Label(row, "Value", entry.Value, UDim2.new(0.58, -8, 1, 0), UDim2.new(0.42, 3, 0, 0), theme:Get("Text"), 11)
            valLabel.TextXAlignment = Enum.TextXAlignment.Right; valLabel.TextTruncate = Enum.TextTruncate.AtEnd
            table.insert(self._rows, row)
        end
    end
    function self:GetData() return table.clone(self.Data) end
    self:SetData(options.Data or options.Items or {})
    return self
end
return KeyValueList
