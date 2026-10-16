local Builder = require("../Utilities/InstanceBuilder")
local IconRenderer = require("../Utilities/IconRenderer")
local Section = {}
Section.__index = Section

local COMPONENT_ALIASES = {
    AddButton = "Button", AddToggle = "Toggle", AddSlider = "Slider", AddDropdown = "Dropdown",
    AddMultiSelect = "MultiSelect", AddTextInput = "TextInput", AddNumericInput = "NumericInput", AddLabel = "Label",
    AddParagraph = "Paragraph", AddDivider = "Divider", AddCard = "Card", AddProgress = "Progress", AddImage = "Image",
    AddKeybind = "Keybind", AddSegmented = "Segmented", AddCollapsible = "Collapsible", AddForm = "Form", AddBadge = "Badge",
    AddStatusIndicator = "StatusIndicator", AddMetricCard = "MetricCard", AddKeyValueList = "KeyValueList", AddDataTable = "DataTable",
    AddItemCatalog = "ItemCatalog", AddRadioGroup = "RadioGroup", AddRangeSlider = "RangeSlider", AddTextArea = "TextArea",
    AddColorPicker = "ColorPicker", AddEmptyState = "EmptyState", AddLogViewer = "LogViewer", AddTreeView = "TreeView",
    AddCarousel = "Carousel", AddCheckbox = "Checkbox", AddSearchableDropdown = "SearchableDropdown", AddMultiSelectDropdown = "MultiSelectDropdown",
    AddTagSelector = "TagSelector", AddCheckboxGroup = "CheckboxGroup", AddPrimaryButton = "PrimaryButton",
    AddSecondaryButton = "SecondaryButton", AddDestructiveButton = "DestructiveButton", AddIconButton = "IconButton",
    AddButtonGroup = "ButtonGroup", AddAccordion = "Accordion", AddProgressBar = "Progress",
}

function Section.new(context, parent, options)
    options = options or {}
    local theme = context.Theme
    local titleText = tostring(options.Title or options.Name or "")
    local descriptionText = tostring(options.Description or "")
    local frame = Builder.Create("Frame", {
        Name = options.Name or (titleText ~= "" and titleText or "Section"),
        BackgroundColor3 = options.BackgroundColor or theme:Get("Surface"),
        BackgroundTransparency = options.BackgroundTransparency == nil and 0.22 or options.BackgroundTransparency,
        BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = options.Collapsible == true,
    }, parent)
    Builder.Corner(frame, options.CornerRadius or math.max(8, theme:Get("CornerRadius") - 1))
    local stroke = Builder.Stroke(frame, theme:Get("BorderSubtle"), 0.64, 1)
    Builder.Padding(frame, 12, 12, 10, 12)
    Builder.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, options.Spacing or 8),
    }, frame)

    local orderOffset = 0
    if options.Accent == true then
        local accent = Builder.Create("Frame", {
            Name = "AccentRule", LayoutOrder = 0, Size = UDim2.new(1, 0, 0, 2),
            BackgroundColor3 = theme:Get("Accent"), BorderSizePixel = 0,
        }, frame)
        Builder.Corner(accent, 4)
        Builder.Create("UIGradient", { Color = ColorSequence.new(theme:Get("Accent"), theme:Get("AccentSecondary")),
            Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.08), NumberSequenceKeypoint.new(1, 0.7) }) }, accent)
        orderOffset = 1
    end

    local header = Builder.Create("Frame", {
        Name = "SectionHeader", LayoutOrder = orderOffset, Size = UDim2.new(1, 0, 0, descriptionText ~= "" and 39 or 25),
        BackgroundTransparency = 1, BorderSizePixel = 0,
    }, frame)
    local titleX = 0
    local iconHolder
    if options.Icon then
        iconHolder = Builder.Create("Frame", { Name = "IconHolder", Position = UDim2.new(0, 0, 0, 1), Size = UDim2.fromOffset(24, 24),
            BackgroundColor3 = theme:Get("AccentSoft"), BorderSizePixel = 0 }, header)
        Builder.Corner(iconHolder, 7)
        IconRenderer.Create(iconHolder, options.Icon, { Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0.5, -7, 0.5, -7),
            Color = theme:Get("Accent"), Fallback = "layers", TextSize = 14 })
        titleX = 32
    end
    local title = Builder.Label(header, "Title", titleText, UDim2.new(1, -(titleX + (options.Collapsible and 34 or 0)), 0, 23),
        UDim2.new(0, titleX, 0, 0), theme:Get("Text"), 13, true)
    title.TextTruncate = Enum.TextTruncate.AtEnd
    local description
    if descriptionText ~= "" then
        description = Builder.Label(header, "Description", descriptionText,
            UDim2.new(1, -(titleX + (options.Collapsible and 34 or 0)), 0, 16), UDim2.new(0, titleX, 0, 22), theme:Get("MutedText"), 10)
        description.TextTruncate = Enum.TextTruncate.AtEnd
    end
    local collapseButton, collapseIcon
    if options.Collapsible then
        collapseButton = Builder.Create("TextButton", { Name = "Collapse", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.fromOffset(27, 25), BackgroundColor3 = theme:Get("SurfaceRaised"), BorderSizePixel = 0,
            Text = "", AutoButtonColor = false }, header)
        Builder.Corner(collapseButton, 7)
        collapseIcon = IconRenderer.Create(collapseButton, "chevron-down", { Size = UDim2.fromOffset(14, 14),
            Position = UDim2.new(0.5, -7, 0.5, -7), Color = theme:Get("MutedText"), Fallback = "chevron-down", TextSize = 14 })
    end

    local content = Builder.Create("Frame", {
        Name = "Components", LayoutOrder = orderOffset + 1, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    }, frame)
    Builder.Create("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, options.Spacing or 8) }, content)

    local self = setmetatable({ Frame = frame, Content = content, Header = header, TitleObject = title,
        DescriptionObject = description, Context = context, Components = {}, _destroyed = false,
        Expanded = options.Expanded ~= false, _collapsible = options.Collapsible == true, _stroke = stroke,
    }, Section)
    function self:Add(kind, componentOptions)
        assert(not self._destroyed, "No se pueden agregar componentes a una sección destruida")
        local component = context.Factory:Create(kind, content, componentOptions or {}, context)
        table.insert(self.Components, component)
        if component.Frame then component.Frame.LayoutOrder = #self.Components end
        if context.Window and context.Window._ApplyZIndex then context.Window:_ApplyZIndex() end
        return component
    end
    function self:SetExpanded(expanded)
        if self._destroyed or not self._collapsible then return end
        self.Expanded = expanded == true
        content.Visible = self.Expanded
        if collapseIcon then
            local targetRotation = self.Expanded and 0 or -90
            if collapseIcon:IsA("GuiObject") then context.Tweens:To(collapseIcon, { Rotation = targetRotation }, { Time = 0.13 }) end
        end
        context.Tweens:To(stroke, { Transparency = self.Expanded and 0.28 or 0.52 }, { Time = 0.13 })
    end
    function self:ToggleExpanded() self:SetExpanded(not self.Expanded) end
    function self:SetTitle(value)
        if self._destroyed then return end
        assert(type(value) == "string", "SetTitle espera string")
        title.Text = value
    end
    function self:Destroy()
        if self._destroyed then return end
        self._destroyed = true
        for _, component in ipairs(self.Components) do if component.Destroy then component:Destroy() end end
        table.clear(self.Components)
        if frame.Parent then frame:Destroy() end
    end
    for method, kind in pairs(COMPONENT_ALIASES) do
        local componentKind = kind
        self[method] = function(section, componentOptions) return section:Add(componentKind, componentOptions) end
    end
    if collapseButton then
        collapseButton.Activated:Connect(function() self:ToggleExpanded() end)
        self:SetExpanded(self.Expanded)
    end
    return self
end

return Section
