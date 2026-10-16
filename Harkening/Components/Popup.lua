local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local IconRenderer = require("../Utilities/IconRenderer")

local Popup = {}
Popup.__index = Popup
setmetatable(Popup, { __index = Base })

local COMPONENTS = {
    AddButton = "Button", AddToggle = "Toggle", AddSlider = "Slider", AddDropdown = "Dropdown",
    AddMultiSelect = "MultiSelect", AddTextInput = "TextInput", AddNumericInput = "NumericInput",
    AddLabel = "Label", AddParagraph = "Paragraph", AddDivider = "Divider", AddCard = "Card",
    AddProgress = "Progress", AddImage = "Image", AddKeybind = "Keybind", AddSegmented = "Segmented",
    AddCollapsible = "Collapsible", AddForm = "Form", AddBadge = "Badge", AddStatusIndicator = "StatusIndicator",
    AddMetricCard = "MetricCard", AddKeyValueList = "KeyValueList", AddDataTable = "DataTable", AddItemCatalog = "ItemCatalog",
    AddRadioGroup = "RadioGroup", AddRangeSlider = "RangeSlider", AddTextArea = "TextArea", AddColorPicker = "ColorPicker",
    AddEmptyState = "EmptyState", AddLogViewer = "LogViewer", AddTreeView = "TreeView", AddCarousel = "Carousel",
    AddCheckbox = "Checkbox", AddSearchableDropdown = "SearchableDropdown", AddMultiSelectDropdown = "MultiSelectDropdown",
    AddTagSelector = "TagSelector", AddCheckboxGroup = "CheckboxGroup", AddPrimaryButton = "PrimaryButton",
    AddSecondaryButton = "SecondaryButton", AddDestructiveButton = "DestructiveButton", AddIconButton = "IconButton",
    AddButtonGroup = "ButtonGroup", AddAccordion = "Accordion", AddProgressBar = "Progress",
}

function Popup.new(context, options)
    options = options or {}
    assert(type(options) == "table", "Popup options debe ser una tabla")
    local theme = context.Theme
    local parent = options.Parent or context.Gui
    local titleText = tostring(options.Title or "")
    local descriptionText = tostring(options.Description or "")
    local hasHeader = titleText ~= "" or descriptionText ~= "" or options.Icon ~= nil or options.ShowCloseButton == true
    local headerHeight = hasHeader and (descriptionText ~= "" and 58 or 44) or 0
    local popupPosition = options.Position or UDim2.fromScale(0.5, 0.5)
    local popupSize = options.Size or UDim2.fromOffset(310, 230)
    local popupZIndex = options.ZIndex or 9000
    local shadow = Builder.Create("ImageLabel", { Name = (options.Name or "Popup") .. "_Shadow",
        AnchorPoint = options.AnchorPoint or Vector2.new(0, 0), Position = popupPosition,
        Size = UDim2.new(popupSize.X.Scale, popupSize.X.Offset + 38, popupSize.Y.Scale, popupSize.Y.Offset + 38),
        BackgroundTransparency = 1, BorderSizePixel = 0, Image = "rbxassetid://6015897843",
        ImageColor3 = theme:Get("Shadow") or Color3.new(0, 0, 0), ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450),
        Visible = options.Visible == true, ZIndex = math.max(1, popupZIndex - 1),
    }, parent)
    local frame = Builder.Create("Frame", {
        Name = options.Name or "Popup", AnchorPoint = options.AnchorPoint or Vector2.new(0, 0),
        Position = popupPosition, Size = popupSize,
        BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0, Visible = options.Visible == true,
        ZIndex = popupZIndex, ClipsDescendants = true,
    }, parent)
    Builder.Corner(frame, theme:Get("CornerRadius") + 1)
    Builder.Stroke(frame, theme:Get("Border"), 0.26, 1)
    Builder.Create("UIGradient", { Rotation = 90, Color = ColorSequence.new(theme:Get("SurfaceRaised"), theme:Get("Surface")) }, frame)
    local accent = Builder.Create("Frame", { Name = "AccentRule", Size = UDim2.new(0.16, 0, 0, 2),
        BackgroundColor3 = theme:Get("Accent"), BorderSizePixel = 0, ZIndex = frame.ZIndex + 1 }, frame)
    Builder.Create("UIGradient", { Color = ColorSequence.new(theme:Get("Accent"), theme:Get("AccentSecondary")),
        Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.04), NumberSequenceKeypoint.new(1, 0.72) }) }, accent)
    local header
    if hasHeader then
        header = Builder.Create("Frame", { Name = "Header", Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, 0, 0, headerHeight),
            BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = frame.ZIndex + 1 }, frame)
        local titleX = 14
        if options.Icon then
            local iconBox = Builder.Create("Frame", { Name = "IconBox", Position = UDim2.new(0, 12, 0, 10), Size = UDim2.fromOffset(28, 28),
                BackgroundColor3 = theme:Get("AccentSoft"), BorderSizePixel = 0, ZIndex = frame.ZIndex + 2 }, header)
            Builder.Corner(iconBox, 8)
            IconRenderer.Create(iconBox, options.Icon, { Size = UDim2.fromOffset(15, 15), Position = UDim2.new(0.5, -7.5, 0.5, -7.5), Color = theme:Get("Accent"), TextSize = 15 })
            titleX = 49
        end
        if titleText ~= "" then
            local title = Builder.Label(header, "Title", titleText, UDim2.new(1, -(titleX + (options.ShowCloseButton and 48 or 20)), 0, 21),
                UDim2.new(0, titleX, 0, descriptionText ~= "" and 7 or 11), theme:Get("Text"), 13, true)
            title.TextTruncate = Enum.TextTruncate.AtEnd
        end
        if descriptionText ~= "" then
            local desc = Builder.Label(header, "Description", descriptionText, UDim2.new(1, -(titleX + 22), 0, 19), UDim2.new(0, titleX, 0, 29), theme:Get("MutedText"), 9)
            desc.TextTruncate = Enum.TextTruncate.AtEnd
        end
        if options.ShowCloseButton == true then
            local close = Builder.Create("TextButton", { Name = "Close", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 9),
                Size = UDim2.fromOffset(26, 26), BackgroundColor3 = theme:Get("SurfaceRaised"), BorderSizePixel = 0,
                Text = "", AutoButtonColor = false, ZIndex = frame.ZIndex + 2 }, header)
            Builder.Corner(close, 7); Builder.Stroke(close, theme:Get("BorderSubtle"), 0.5, 1)
            IconRenderer.Create(close, "close", { Size = UDim2.fromOffset(13, 13), Position = UDim2.new(0.5, -6.5, 0.5, -6.5), Color = theme:Get("MutedText"), TextSize = 14 })
            close.Activated:Connect(function() self:Close() end)
        end
        Builder.Create("Frame", { Name = "HeaderDivider", Position = UDim2.new(0, 12, 1, -1), Size = UDim2.new(1, -24, 0, 1),
            BackgroundColor3 = theme:Get("BorderSubtle"), BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = frame.ZIndex + 2 }, header)
    end
    local content = Builder.Create("ScrollingFrame", { Name = "Content", BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, headerHeight + 4), Size = UDim2.new(1, 0, 1, -(headerHeight + 8)),
        ZIndex = frame.ZIndex + 1, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3, ScrollBarImageColor3 = theme:Get("Border"), BorderSizePixel = 0 }, frame)
    Builder.Padding(content, 12, 12, 8, 12)
    Builder.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 7) }, content)

    local self = setmetatable({}, Popup)
    Base.Initialize(self, context, frame)
    self.Content = content; self.Header = header; self._openGeneration = 0; self.Shadow = shadow
    local function syncShadow()
        if not shadow.Parent or not frame.Parent then return end
        shadow.AnchorPoint = frame.AnchorPoint
        shadow.Position = frame.Position
        shadow.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset + 38, frame.Size.Y.Scale, frame.Size.Y.Offset + 38)
        shadow.Visible = frame.Visible
        shadow.ZIndex = math.max(1, frame.ZIndex - 1)
    end
    self:Connect(frame:GetPropertyChangedSignal("Position"), syncShadow)
    self:Connect(frame:GetPropertyChangedSignal("Size"), syncShadow)
    self:Connect(frame:GetPropertyChangedSignal("Visible"), syncShadow)
    function self:_ApplyZIndex()
        if self._destroyed or not frame.Parent then return end
        frame.ZIndex = options.ZIndex or 9000
        if shadow.Parent then shadow.ZIndex = math.max(1, frame.ZIndex - 1) end
        for _, descendant in ipairs(frame:GetDescendants()) do
            if descendant:IsA("GuiObject") then
                local depth, current = 1, descendant.Parent
                while current and current ~= frame do depth += 1; current = current.Parent end
                descendant.ZIndex = frame.ZIndex + math.clamp(depth, 1, 50)
            end
        end
    end
    function self:Add(kind, componentOptions)
        assert(not self._destroyed, "Popup destruido")
        local component = context.Factory:Create(kind, content, componentOptions or {}, context)
        self._children = self._children or {}; table.insert(self._children, component)
        if component.Frame then component.Frame.LayoutOrder = #self._children end
        self:_ApplyZIndex()
        return component
    end
    for method, kind in pairs(COMPONENTS) do
        local componentKind = kind
        self[method] = function(item, componentOptions) return item:Add(componentKind, componentOptions) end
    end
    function self:SetTitle(value)
        if self._destroyed then return end
        local label = header and header:FindFirstChild("Title")
        if label and label:IsA("TextLabel") then label.Text = tostring(value or "") end
    end
    function self:Open()
        if self._destroyed then return false end
        self._openGeneration += 1
        frame.Visible = true
        shadow.Visible = true
        frame.BackgroundTransparency = 1
        local targetPosition = options.Position or UDim2.fromScale(0.5, 0.5)
        frame.Position = UDim2.new(targetPosition.X.Scale, targetPosition.X.Offset, targetPosition.Y.Scale, targetPosition.Y.Offset + 6)
        context.Tweens:To(frame, { BackgroundTransparency = 0, Position = targetPosition }, { Time = 0.16 })
        self:_ApplyZIndex()
        return true
    end
    function self:Close()
        if self._destroyed or not frame.Visible then return end
        self._openGeneration += 1
        local generation = self._openGeneration
        local pos = options.Position or UDim2.fromScale(0.5, 0.5)
        context.Tweens:To(frame, { BackgroundTransparency = 1, Position = UDim2.new(pos.X.Scale, pos.X.Offset, pos.Y.Scale, pos.Y.Offset + 6) }, { Time = 0.12 })
        task.delay(0.13, function()
            if not self._destroyed and generation == self._openGeneration then frame.Visible = false; shadow.Visible = false end
        end)
    end
    function self:Destroy()
        if self._destroyed then return end
        if shadow.Parent then shadow:Destroy() end
        Base.Destroy(self)
    end
    self._closeConnections = {}
    self:_ApplyZIndex()
    syncShadow()
    if options.Visible == true then self:Open() end
    return self
end
return Popup
