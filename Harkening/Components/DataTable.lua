local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local DataTable = {}; DataTable.__index = DataTable; setmetatable(DataTable, { __index = Base })

local function shallowData(data)
    local out = {}; for i, row in ipairs(data or {}) do out[i] = table.clone(row) end; return out
end

function DataTable.new(context, parent, options)
    options = options or {}; local theme = context.Theme
    assert(type(options.Columns or {}) == "table", "DataTable.Columns debe ser una tabla")
    local columns = options.Columns or {}
    local frame = Builder.Create("Frame", { Name = options.Name or "DataTable", BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, options.Height or 230), ClipsDescendants = true }, parent)
    Builder.Corner(frame, theme:Get("CornerRadius")); Builder.Stroke(frame, theme:Get("Border"), 0.45, 1)
    local header = Builder.Create("Frame", { Name = "Header", BackgroundColor3 = theme:Get("SurfaceRaised"), Size = UDim2.new(1, 0, 0, 32), BorderSizePixel = 0 }, frame)
    local body = Builder.Create("ScrollingFrame", { Name = "Rows", BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 32),
        Size = UDim2.new(1, 0, 1, -32), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 4, BorderSizePixel = 0 }, frame)
    Builder.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 1) }, body)
    local empty = Builder.Label(body, "Empty", options.EmptyText or "No data available", UDim2.new(1, -16, 0, 36), UDim2.new(0, 8, 0, 0), theme:Get("MutedText"), 11)
    empty.TextXAlignment = Enum.TextXAlignment.Center
    local self = setmetatable({}, DataTable); Base.Initialize(self, context, frame)
    self.Columns, self.Data, self._selected, self._selectedRecord, self._sortKey, self._sortDescending = columns, {}, nil, nil, nil, false
    self._rowConnections, self._rowObjects, self._headerButtons = {}, {}, {}

    local function colKey(column) return column.Key or column.Field or column.Title end
    local function colWidth(column)
        local width = tonumber(column.Width)
        if width and width > 0 and width <= 1 then return width end
        return 1 / math.max(1, #columns)
    end
    for i, column in ipairs(columns) do
        local button = Builder.Create("TextButton", { Name = "Column_" .. tostring(colKey(column)), BackgroundTransparency = 1,
            Size = UDim2.new(colWidth(column), -6, 1, 0), Position = UDim2.new(0, 0, 0, 0),
            Text = tostring(column.Title or colKey(column) or "Column"), Font = Enum.Font.GothamSemibold, TextSize = 10,
            TextColor3 = theme:Get("MutedText"), TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false,
            LayoutOrder = i }, header)
        -- Use layout for deterministic widths even when the column widths are equal.
        button.Position = UDim2.new(0, 0, 0, 0)
        button.Size = UDim2.new(colWidth(column), -8, 1, 0)
        button.AnchorPoint = Vector2.new(0, 0)
        button.Position = UDim2.new(0, 0, 0, 0)
        Builder.Padding(button, 6, 2, 0, 0)
        self._headerButtons[i] = button
    end
    local headerLayout = Builder.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0) }, header)

    local function disconnectRows()
        for _, conn in ipairs(self._rowConnections) do if conn.Connected then conn:Disconnect() end end
        table.clear(self._rowConnections)
        for _, row in ipairs(self._rowObjects) do if row.Parent then row:Destroy() end end
        table.clear(self._rowObjects)
    end
    local function orderedData()
        local rows = shallowData(self.Data)
        if self._sortKey then
            local key, desc = self._sortKey, self._sortDescending
            table.sort(rows, function(a, b)
                local av, bv = a[key], b[key]
                if av == bv then return tostring(a.Id or a.ID or "") < tostring(b.Id or b.ID or "") end
                if av == nil then return false end; if bv == nil then return true end
                if type(av) == "number" and type(bv) == "number" then return desc and av > bv or (not desc and av < bv) end
                av, bv = string.lower(tostring(av)), string.lower(tostring(bv))
                return desc and av > bv or (not desc and av < bv)
            end)
        end
        return rows
    end
    local function render()
        if self._destroyed then return end
        disconnectRows()
        local rows = orderedData(); empty.Visible = #rows == 0
        empty.Size = UDim2.new(1, -16, 0, #rows == 0 and 36 or 0)
        for index, record in ipairs(rows) do
            local rowId = record.Id or record.ID or index
            local row = Builder.Create("TextButton", { Name = "Row_" .. tostring(index), LayoutOrder = index,
                BackgroundColor3 = self._selected == rowId and theme:Get("SurfaceRaised") or theme:Get("Surface"),
                BackgroundTransparency = self._selected == rowId and 0 or (index % 2 == 0 and 0.24 or 0.48), BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, options.RowHeight or 30), Text = "", AutoButtonColor = false }, body)
            table.insert(self._rowObjects, row)
            local xScale = 0
            for colIndex, column in ipairs(columns) do
                local share = colWidth(column)
                local key = colKey(column)
                local value = record[key]
                if type(column.Render) == "function" then
                    local ok, rendered = pcall(column.Render, value, record, index)
                    if ok then value = rendered else value = "[render error]" end
                end
                local cell = Builder.Label(row, "Cell_" .. tostring(colIndex), value == nil and "—" or tostring(value),
                    UDim2.new(share, -8, 1, 0), UDim2.new(xScale, 0, 0, 0), theme:Get("Text"), 10)
                cell.TextTruncate = Enum.TextTruncate.AtEnd
                Builder.Padding(cell, 6, 1, 0, 0)
                xScale += share
            end
            local connection = row.Activated:Connect(function()
                if self._destroyed then return end
                self._selected = rowId; self._selectedRecord = table.clone(record)
                if type(options.OnRowSelected) == "function" then task.spawn(options.OnRowSelected, table.clone(record), index, self) end
                render()
            end)
            table.insert(self._rowConnections, connection)
        end
    end
    for index, button in ipairs(self._headerButtons) do
        local column = columns[index]
        local connection = button.Activated:Connect(function()
            local key = colKey(column); if key == nil then return end
            if self._sortKey == key then self._sortDescending = not self._sortDescending
            else self._sortKey = key; self._sortDescending = false end
            render()
        end)
        self._cleanup:Add(connection)
    end
    function self:SetData(data)
        assert(type(data) == "table", "SetData espera una tabla")
        if self._destroyed then return end
        self.Data = shallowData(data); self._selected = nil; self._selectedRecord = nil; render()
    end
    function self:GetData() return shallowData(self.Data) end
    function self:SetSort(key, descending)
        if self._destroyed then return end
        self._sortKey = key; self._sortDescending = descending == true; render()
    end
    function self:GetSelectedRow()
        return self._selectedRecord and table.clone(self._selectedRecord) or nil
    end
    function self:Destroy()
        if self._destroyed then return end
        disconnectRows(); Base.Destroy(self)
    end
    self:SetData(options.Data or {})
    return self
end
return DataTable
