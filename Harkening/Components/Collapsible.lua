local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local Collapsible = {}
Collapsible.__index = Collapsible
setmetatable(Collapsible, { __index = Base })
function Collapsible.new(context, parent, options)
	options = options or {}
	local theme = context.Theme
	local frame = Builder.Create("Frame", { Name = options.Name or "Collapsible", BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, options.HeaderHeight or 36), ClipsDescendants = true }, parent)
	Builder.Corner(frame, theme:Get("CornerRadius"))
	local header = Builder.Create("TextButton", { Name = "Header", Size = UDim2.new(1, 0, 0, options.HeaderHeight or 36),
		BackgroundTransparency = 1, AutoButtonColor = false, Text = "", TextXAlignment = Enum.TextXAlignment.Left }, frame)
	local title = Builder.Label(header, "Title", options.Title or "Expandable section", UDim2.new(1, -42, 1, 0), UDim2.new(0, 11, 0, 0), theme:Get("Text"), 13, true)
	local arrow = Builder.Label(header, "Arrow", options.Expanded == true and "−" or "+", UDim2.new(0, 24, 1, 0), UDim2.new(1, -30, 0, 0), theme:Get("MutedText"), 17, true)
	arrow.TextXAlignment = Enum.TextXAlignment.Center
	local content = Builder.Create("Frame", { Name = "Content", BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, (options.HeaderHeight or 36) + 5), Size = UDim2.new(1, -20, 0, 0), Visible = options.Expanded == true }, frame)
	local layout = Builder.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }, content)
	local self = setmetatable({}, Collapsible); Base.Initialize(self, context, frame); self.TextObject = title
	self:Connect(layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		if self._expanded then
			content.Size = UDim2.new(1, -20, 0, layout.AbsoluteContentSize.Y)
			frame.Size = UDim2.new(1, 0, 0, self._headerHeight + 5 + layout.AbsoluteContentSize.Y)
		end
	end)
	self.Content, self._header, self._arrow, self._expanded, self._headerHeight = content, header, arrow, options.Expanded == true, options.HeaderHeight or 36
	function self:Add(kind, componentOptions)
		assert(not self._destroyed, "Collapsible destruido")
		local component = context.Factory:Create(kind, content, componentOptions or {}, context)
		self._children = self._children or {}; table.insert(self._children, component)
		if component.Frame then component.Frame.LayoutOrder = #self._children end
		if context.Window and context.Window._ApplyZIndex then context.Window:_ApplyZIndex() end
		return component
	end
	for method, kind in pairs({ AddButton = "Button", AddToggle = "Toggle", AddSlider = "Slider", AddDropdown = "Dropdown",
		AddMultiSelect = "MultiSelect", AddTextInput = "TextInput", AddNumericInput = "NumericInput", AddLabel = "Label",
		AddParagraph = "Paragraph", AddDivider = "Divider", AddCard = "Card", AddProgress = "Progress", AddImage = "Image",
		AddKeybind = "Keybind", AddSegmented = "Segmented", AddCollapsible = "Collapsible", AddForm = "Form", AddBadge = "Badge", AddStatusIndicator = "StatusIndicator", AddMetricCard = "MetricCard", AddKeyValueList = "KeyValueList", AddDataTable = "DataTable", AddItemCatalog = "ItemCatalog", AddRadioGroup = "RadioGroup", AddRangeSlider = "RangeSlider", AddTextArea = "TextArea", AddColorPicker = "ColorPicker", AddEmptyState = "EmptyState", AddLogViewer = "LogViewer", AddTreeView = "TreeView", AddCarousel = "Carousel", AddCheckbox = "Checkbox", AddSearchableDropdown = "SearchableDropdown", AddMultiSelectDropdown = "MultiSelectDropdown",
        AddTagSelector = "TagSelector", AddCheckboxGroup = "CheckboxGroup", AddPrimaryButton = "PrimaryButton",
        AddSecondaryButton = "SecondaryButton", AddDestructiveButton = "DestructiveButton", AddIconButton = "IconButton",
        AddButtonGroup = "ButtonGroup", AddAccordion = "Accordion", AddProgressBar = "Progress" }) do
		local componentKind = kind
		self[method] = function(item, componentOptions) return item:Add(componentKind, componentOptions) end
	end
	function self:SetExpanded(expanded)
		if self._destroyed then return end
		self._expanded = expanded == true
		content.Visible = self._expanded
		content.Size = UDim2.new(1, -20, 0, self._expanded and layout.AbsoluteContentSize.Y or 0)
		frame.Size = UDim2.new(1, 0, 0, self._headerHeight + (self._expanded and 5 + layout.AbsoluteContentSize.Y or 0))
		arrow.Text = self._expanded and "−" or "+"
	end
	function self:IsExpanded() return self._expanded end
	function self:SetEnabled(enabled)
		if self._destroyed then return end
		Base.SetEnabled(self, enabled); header.Active = self.Enabled; header.Selectable = self.Enabled
		if not self.Enabled then header.TextTransparency = 0.4 else header.TextTransparency = 0 end
		for _, child in ipairs(self._children or {}) do if child.SetEnabled then child:SetEnabled(enabled) end end
	end
	self:Connect(header.Activated, function() if not self.Enabled then return end; self:FocusWindow(); self:SetExpanded(not self._expanded) end)
	self:SetExpanded(options.Expanded == true)
	self:SetEnabled(options.Enabled ~= false)
	return self
end
return Collapsible
