local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local IconRenderer = require("../Utilities/IconRenderer")
local Card = {}
Card.__index = Card
setmetatable(Card, { __index = Base })

function Card.new(context, parent, options)
	options = options or {}
	local theme = context.Theme
	local frame = Builder.Create("Frame", { Name = options.Name or "Card", BackgroundColor3 = options.BackgroundColor or theme:Get("Surface"),
        BackgroundTransparency = options.BackgroundTransparency == nil and 0.03 or options.BackgroundTransparency,
		BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y }, parent)
	Builder.Corner(frame, theme:Get("CornerRadius")); Builder.Stroke(frame, theme:Get("BorderSubtle"), 0.60, 1)
    local order = 0
    if options.Accent == true then
        local topAccent = Builder.Create("Frame", { Name = "AccentRule", Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = theme:Get("Accent"), BorderSizePixel = 0 }, frame)
        topAccent.LayoutOrder = 0
        Builder.Create("UIGradient", { Color = ColorSequence.new(theme:Get("Accent"), theme:Get("AccentSecondary")),
            Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.08), NumberSequenceKeypoint.new(1, 0.72) }) }, topAccent)
        order = 1
    end
	Builder.Create("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 7) }, frame)
	Builder.Padding(frame, 12, 12, 11, 12)
	order += 1
    if options.Image and options.Image ~= "" then
        local imageFrame = Builder.Create("Frame", { Name = "ImageContainer", BackgroundColor3 = theme:Get("SurfaceRaised"), BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, options.ImageHeight or 104), ClipsDescendants = true, LayoutOrder = order }, frame)
        Builder.Corner(imageFrame, math.max(0, theme:Get("CornerRadius") - 2))
        local image = Builder.Create("ImageLabel", { Name = "Image", BackgroundTransparency = 1, Size = UDim2.fromScale(1,1),
            Image = tostring(options.Image), ScaleType = options.ImageScaleType or Enum.ScaleType.Crop }, imageFrame)
        order += 1 -- image resources are parent-owned
    end
	if options.Title and options.Title ~= "" then
        local titleRow = Builder.Create("Frame", { Name = "TitleRow", Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = order }, frame)
        if options.Icon then
            IconRenderer.Create(titleRow, options.Icon, { Size = UDim2.fromOffset(17, 17), Position = UDim2.new(0, 0, 0.5, -8.5),
                Color = theme:Get("Accent"), Fallback = "layers", TextSize = 17 })
        end
        local title = Builder.Label(titleRow, "Title", options.Title, UDim2.new(1, options.Icon and -25 or 0, 1, 0),
            UDim2.new(0, options.Icon and 25 or 0, 0, 0), theme:Get("Text"), 13, true)
        title.TextTruncate = Enum.TextTruncate.AtEnd
        order += 1
	end
	if options.Description and options.Description ~= "" then
		local desc = Builder.Label(frame, "Description", options.Description, UDim2.new(1, 0, 0, 0), UDim2.new(), theme:Get("MutedText"), 11)
		desc.AutomaticSize = Enum.AutomaticSize.Y; desc.LayoutOrder = order; order += 1
	end
	local content = Builder.Create("Frame", { Name = "Content", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, LayoutOrder = order }, frame)
	Builder.Create("UIListLayout", { FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 7) }, content)
	local self = setmetatable({}, Card); Base.Initialize(self, context, frame)
	self.Content = content
	function self:Add(kind, componentOptions)
		assert(not self._destroyed, "Card destruida")
		local component = context.Factory:Create(kind, content, componentOptions or {}, context)
		self._children = self._children or {}; table.insert(self._children, component)
		if component.Frame then component.Frame.LayoutOrder = #self._children end
		if context.Window and context.Window._ApplyZIndex then context.Window:_ApplyZIndex() end
		return component
	end
	function self:SetEnabled(enabled)
		if self._destroyed then return end
		Base.SetEnabled(self, enabled)
		for _, child in ipairs(self._children or {}) do if child.SetEnabled then child:SetEnabled(enabled) end end
	end
	for method, kind in pairs({ AddButton = "Button", AddToggle = "Toggle", AddSlider = "Slider", AddDropdown = "Dropdown",
		AddMultiSelect = "MultiSelect", AddTextInput = "TextInput", AddNumericInput = "NumericInput", AddLabel = "Label",
		AddParagraph = "Paragraph", AddDivider = "Divider", AddProgress = "Progress", AddImage = "Image", AddKeybind = "Keybind",
		AddSegmented = "Segmented", AddCard = "Card", AddCollapsible = "Collapsible", AddForm = "Form", AddBadge = "Badge", AddStatusIndicator = "StatusIndicator", AddMetricCard = "MetricCard", AddKeyValueList = "KeyValueList", AddDataTable = "DataTable", AddItemCatalog = "ItemCatalog", AddRadioGroup = "RadioGroup", AddRangeSlider = "RangeSlider", AddTextArea = "TextArea", AddColorPicker = "ColorPicker", AddEmptyState = "EmptyState", AddLogViewer = "LogViewer", AddTreeView = "TreeView", AddCarousel = "Carousel", AddCheckbox = "Checkbox", AddSearchableDropdown = "SearchableDropdown", AddMultiSelectDropdown = "MultiSelectDropdown",
        AddTagSelector = "TagSelector", AddCheckboxGroup = "CheckboxGroup", AddPrimaryButton = "PrimaryButton",
        AddSecondaryButton = "SecondaryButton", AddDestructiveButton = "DestructiveButton", AddIconButton = "IconButton",
        AddButtonGroup = "ButtonGroup", AddAccordion = "Accordion", AddProgressBar = "Progress" }) do
		local componentKind = kind
		self[method] = function(card, componentOptions) return card:Add(componentKind, componentOptions) end
	end
	return self
end
return Card
