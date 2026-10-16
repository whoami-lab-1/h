local modules = {
	Button = require("./Button"),
    Checkbox = require("./Checkbox"),
	Toggle = require("./Toggle"),
	Slider = require("./Slider"),
	Dropdown = require("./Dropdown"),
	MultiSelect = require("./MultiSelect"),
	TextInput = require("./TextInput"),
	NumericInput = require("./NumericInput"),
	Label = require("./Label"),
	Paragraph = require("./Paragraph"),
	Divider = require("./Divider"),
	Card = require("./Card"),
	Progress = require("./Progress"),
	Image = require("./Image"),
	Keybind = require("./Keybind"),
	Segmented = require("./Segmented"),
	Collapsible = require("./Collapsible"),
	Form = require("./Form"),
    Badge = require("./Badge"),
    StatusIndicator = require("./StatusIndicator"),
    MetricCard = require("./MetricCard"),
    KeyValueList = require("./KeyValueList"),
    DataTable = require("./DataTable"),
    ItemCatalog = require("./ItemCatalog"),
    RadioGroup = require("./RadioGroup"),
    RangeSlider = require("./RangeSlider"),
    TextArea = require("./TextArea"),
    ColorPicker = require("./ColorPicker"),
    EmptyState = require("./EmptyState"),
    LogViewer = require("./LogViewer"),
    TreeView = require("./TreeView"),
    Carousel = require("./Carousel"),
}

local aliases = {
	normal = "Button", button = "Button", boton = "Button", toggle = "Toggle", interruptor = "Toggle", checkbox = "Checkbox",
    primarybutton = "Button", secondarybutton = "Button", destructivebutton = "Button", actionbutton = "Button", iconbutton = "Button",
    imagebutton = "Button", textbutton = "Button", closebutton = "Button", expandbutton = "Button", copybutton = "Button", splitbutton = "Button", floatingactionbutton = "Button",
    buttongroup = "Segmented",
	slider = "Slider", deslizador = "Slider", dropdown = "Dropdown", despegable = "Dropdown",
	multiselect = "MultiSelect", selectmultiple = "MultiSelect", multiselectdropdown = "MultiSelect", checkboxgroup = "MultiSelect", tagselector = "MultiSelect", textinput = "TextInput", campo = "TextInput",
	numericinput = "NumericInput", number = "NumericInput", label = "Label", etiqueta = "Label",
	paragraph = "Paragraph", parrafo = "Paragraph", divider = "Divider", separador = "Divider",
	card = "Card", tarjeta = "Card", itemcard = "Card", productcard = "Card", gamecard = "Card", informationcard = "Card", profilecard = "Card", selectablecard = "Card", progress = "Progress", progreso = "Progress", image = "Image", imagen = "Image",
	keybind = "Keybind", segmented = "Segmented", segmentado = "Segmented", collapsible = "Collapsible",
	expandible = "Collapsible", form = "Form", formulario = "Form",
    badge = "Badge", tag = "Badge", statusindicator = "StatusIndicator", status = "StatusIndicator",
    metriccard = "MetricCard", statisticscard = "MetricCard", metric = "MetricCard",
    keyvaluelist = "KeyValueList", propertylist = "KeyValueList", keyvalue = "KeyValueList",
    datatable = "DataTable", leaderboard = "DataTable", activitytable = "DataTable", timeline = "LogViewer",
    itemcatalog = "ItemCatalog", objectcatalog = "ItemCatalog", inventorylist = "ItemCatalog", itemlist = "ItemCatalog", searchpanel = "ItemCatalog",
    radiogroup = "RadioGroup", rangslider = "RangeSlider", rangeslider = "RangeSlider", range = "RangeSlider",
    textarea = "TextArea", text_area = "TextArea", colorpicker = "ColorPicker", color = "ColorPicker",
    emptystate = "EmptyState", empty = "EmptyState", logviewer = "LogViewer", consoleviewer = "LogViewer",
    treeview = "TreeView", hierarchicallist = "TreeView", carousel = "Carousel", horizontalcarousel = "Carousel",
    accordion = "Collapsible", collapsiblesection = "Collapsible", searchabledropdown = "Dropdown", progressbar = "Progress",
    itemcatalog = "ItemCatalog", selectablegrid = "ItemCatalog", selectablelist = "ItemCatalog", objectgrid = "ItemCatalog",
}

local Factory = {}
Factory.__index = Factory
function Factory.new(context) return setmetatable({ Context = context }, Factory) end
function Factory:Create(kind, parent, options, context)
	assert(type(kind) == "string", "ComponentFactory:Create espera un tipo string")
	assert(typeof(parent) == "Instance", "ComponentFactory:Create espera un parent Instance")
    local normalizedKind = string.lower(kind)
	local moduleName = modules[kind] and kind or aliases[normalizedKind]
	assert(moduleName and modules[moduleName], "Componente desconocido: " .. kind)
	local resolvedContext = context or self.Context
	assert(not (resolvedContext.Framework and resolvedContext.Framework._destroyed), "Harkening ya fue destruido")
    local resolvedOptions = table.clone(options or {})
    if normalizedKind == "searchabledropdown" then resolvedOptions.Searchable = true end
    if normalizedKind == "multiselectdropdown" or normalizedKind == "checkboxgroup" or normalizedKind == "tagselector" then resolvedOptions.Multiple = true end
    local buttonVariants = { primarybutton = "Primary", secondarybutton = "Secondary", destructivebutton = "Destructive", actionbutton = "Primary", closebutton = "Secondary", expandbutton = "Secondary", splitbutton = "Secondary", floatingactionbutton = "Primary", copybutton = "Secondary" }
    if buttonVariants[normalizedKind] then resolvedOptions.Variant = resolvedOptions.Variant or buttonVariants[normalizedKind] end
    if normalizedKind == "iconbutton" or normalizedKind == "imagebutton" then resolvedOptions.IconOnly = true end
    local component = modules[moduleName].new(resolvedContext, parent, resolvedOptions)
	-- Public factory-created components must be cleaned when the framework is destroyed,
	-- including components mounted in a custom container outside a managed window.
	if resolvedContext.Lifecycle then resolvedContext.Lifecycle:Add(component) end
	return component
end
function Factory:GetAvailable()
	local result = {}
	for name in pairs(modules) do table.insert(result, name) end
	table.sort(result)
	return result
end
return Factory
