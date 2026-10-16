local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local IconRenderer = require("../Utilities/IconRenderer")
local TreeView = {}; TreeView.__index = TreeView; setmetatable(TreeView, { __index = Base })

local function copyNode(raw, path, seen)
    if type(raw) == "string" or type(raw) == "number" then raw = { Name = tostring(raw) } end
    assert(type(raw) == "table", "Cada nodo debe ser una tabla, string o number")
    local node = table.clone(raw)
    node.Name = tostring(node.Name or node.Title or "Node")
    node.Id = tostring(node.Id or node.ID or (path .. "/" .. node.Name))
    assert(not seen[node.Id], "TreeView contiene IDs duplicados: " .. node.Id); seen[node.Id] = true
    node.Children = node.Children or {}
    assert(type(node.Children) == "table", "Node.Children debe ser una tabla")
    local children = {}
    for index, child in ipairs(node.Children) do children[index] = copyNode(child, node.Id .. "/" .. index, seen) end
    node.Children = children
    return node
end
local function normalize(nodes)
    assert(type(nodes) == "table", "Nodes debe ser una tabla")
    local seen, result = {}, {}
    for index, node in ipairs(nodes) do result[index] = copyNode(node, "root/" .. index, seen) end
    return result
end
function TreeView.new(context, parent, options)
    options = options or {}; local theme = context.Theme
    local frame = Builder.Create("Frame", { Name = options.Name or "TreeView", BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, options.Height or 230), ClipsDescendants = true }, parent)
    Builder.Corner(frame, theme:Get("CornerRadius")); Builder.Stroke(frame, theme:Get("Border"), 0.45, 1)
    local body = Builder.Create("ScrollingFrame", { Name = "Nodes", BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 4), Size = UDim2.new(1, 0, 1, -8), CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 4 }, frame)
    Builder.Padding(body, 5, 5, 3, 3)
    Builder.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }, body)
    local self = setmetatable({}, TreeView); Base.Initialize(self, context, frame)
    self.Nodes, self.Expanded, self.SelectedId = {}, {}, nil; self._rows, self._connections = {}, {}; self._onSelect = options.OnNodeSelected
    local function cleanupRows()
        for _, connection in ipairs(self._connections) do if connection.Connected then connection:Disconnect() end end
        table.clear(self._connections)
        for _, row in ipairs(self._rows) do if row.Parent then row:Destroy() end end
        table.clear(self._rows)
    end
    local function flatten(nodes, depth, output)
        for _, node in ipairs(nodes) do
            output[#output + 1] = { Node = node, Depth = depth }
            if #node.Children > 0 and self.Expanded[node.Id] then flatten(node.Children, depth + 1, output) end
        end
    end
    local render
    render = function()
        if self._destroyed then return end
        cleanupRows()
        local flat = {}; flatten(self.Nodes, 0, flat)
        for index, entry in ipairs(flat) do
            local node, depth = entry.Node, entry.Depth
            local selected = self.SelectedId == node.Id
            local row = Builder.Create("Frame", { Name = "NodeRow", LayoutOrder = index,
                BackgroundColor3 = selected and theme:Get("AccentSoft") or theme:Get("Surface"),
                BackgroundTransparency = selected and 0 or 1, BorderSizePixel = 0, Size = UDim2.new(1, -3, 0, 29) }, body)
            Builder.Corner(row, 6)
            if selected then Builder.Stroke(row, theme:Get("Accent"), 0.6, 1) end
            table.insert(self._rows, row)
            local left = depth * 15
            local arrow = Builder.Create("TextButton", { Name = "Expand", BackgroundTransparency = 1, Position = UDim2.new(0, left, 0, 0),
                Size = UDim2.fromOffset(23, 29), Text = #node.Children == 0 and "" or (self.Expanded[node.Id] and "⌄" or "›"),
                TextColor3 = theme:Get("MutedText"), Font = Enum.Font.GothamSemibold, TextSize = 15, AutoButtonColor = false, Active = #node.Children > 0 }, row)
            local selectButton = Builder.Create("TextButton", { Name = "Select", BackgroundTransparency = 1,
                Position = UDim2.new(0, left + 24, 0, 0), Size = UDim2.new(1, -(left + 29), 1, 0), Text = "",
                AutoButtonColor = false, Active = true }, row)
            local iconValue = node.Icon or (#node.Children > 0 and (self.Expanded[node.Id] and "folder" or "folder") or "file")
            IconRenderer.Create(selectButton, iconValue, { Name = "Icon", Size = UDim2.fromOffset(15, 15),
                Position = UDim2.new(0, 1, 0.5, -7.5), Color = node.Color or theme:Get("Accent"), Fallback = #node.Children > 0 and "folder" or "file", TextSize = 14 })
            local label = Builder.Label(selectButton, "Name", node.Name, UDim2.new(1, -24, 1, 0), UDim2.new(0, 22, 0, 0), theme:Get("Text"), 11, selected)
            label.TextTruncate = Enum.TextTruncate.AtEnd
            table.insert(self._connections, row.MouseEnter:Connect(function()
                if self.Enabled and self.SelectedId ~= node.Id then context.Tweens:To(row, { BackgroundTransparency = 0.45, BackgroundColor3 = theme:Get("SurfaceHover") }, { Time = 0.10 }) end
            end))
            table.insert(self._connections, row.MouseLeave:Connect(function()
                if row.Parent and not self._destroyed and self.SelectedId ~= node.Id then context.Tweens:To(row, { BackgroundTransparency = 1, BackgroundColor3 = theme:Get("Surface") }, { Time = 0.10 }) end
            end))
            table.insert(self._connections, arrow.Activated:Connect(function()
                if self._destroyed or #node.Children == 0 then return end
                self.Expanded[node.Id] = not self.Expanded[node.Id]; render()
            end))
            table.insert(self._connections, selectButton.Activated:Connect(function()
                if self._destroyed then return end
                self.SelectedId = node.Id; self:FocusWindow(); render()
                if type(self._onSelect) == "function" then task.spawn(self._onSelect, table.clone(node), self) end
            end))
        end
    end
    function self:SetNodes(nodes)
        assert(not self._destroyed, "TreeView destruido")
        self.Nodes = normalize(nodes); self.Expanded = {}
        local function seed(nodesList)
            for _, node in ipairs(nodesList) do
                if node.Expanded == true or options.ExpandAll == true then self.Expanded[node.Id] = true end
                seed(node.Children)
            end
        end
        seed(self.Nodes); self.SelectedId = nil; render()
    end
    function self:GetNodes() return normalize(self.Nodes) end
    function self:SetExpanded(id, expanded) if self._destroyed then return false end; self.Expanded[tostring(id)] = expanded == true; render(); return true end
    function self:ExpandAll()
        local function visit(nodes) for _, node in ipairs(nodes) do if #node.Children > 0 then self.Expanded[node.Id] = true end; visit(node.Children) end end
        visit(self.Nodes); render()
    end
    function self:CollapseAll() table.clear(self.Expanded); render() end
    function self:Select(id, fireCallback)
        local found
        local function visit(nodes) for _, node in ipairs(nodes) do if node.Id == tostring(id) then found = node; return end; visit(node.Children); if found then return end end end
        visit(self.Nodes); if not found then return false end
        self.SelectedId = found.Id; render(); if fireCallback == true and type(self._onSelect) == "function" then task.spawn(self._onSelect, table.clone(found), self) end; return true
    end
    function self:GetSelected() 
        local found; local function visit(nodes) for _, node in ipairs(nodes) do if node.Id == self.SelectedId then found = node; return end; visit(node.Children); if found then return end end end
        visit(self.Nodes); return found and table.clone(found) or nil
    end
    function self:Destroy() if self._destroyed then return end; cleanupRows(); Base.Destroy(self) end
    self:SetNodes(options.Nodes or {})
    return self
end
return TreeView
