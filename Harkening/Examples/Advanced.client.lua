-- Harkening UI v2 — Advanced showcase.
-- Put the compiled Harkening.lua into ReplicatedStorage as a ModuleScript named "Harkening".
-- Run this file as a LocalScript from StarterPlayerScripts.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Harkening = require(ReplicatedStorage:WaitForChild("Harkening"))

local ui = Harkening.new({
    Name = "HarkeningAdvancedShowcase",
    Animation = true,
    ResetOnSpawn = false,
    DisplayOrder = 80,
    Theme = {
        Accent = Color3.fromRGB(100, 166, 255),
        Success = Color3.fromRGB(82, 190, 137),
        Warning = Color3.fromRGB(241, 184, 75),
    },
    -- It is created automatically by Harkening.new; do not call a separate constructor.
    Watermark = {
        Enabled = true,
        Title = "PROJECT HARKENING",
        LogoText = "H",
        ShowLogo = true,
        ShowGameName = true,
        ShowGameIcon = true,
        ShowFPS = true,
        ShowClock = true,
        ShowStatus = true,
        Position = "TopRight",
        Style = "Expanded",
        Status = "READY",
    },
})

ui:SetStatus("RUNNING")

local main = ui:CreateWindow({
    Id = "main",
    Title = "Harkening UI",
    Description = "Advanced framework showcase",
    Size = UDim2.fromOffset(820, 600),
    MinSize = Vector2.new(640, 440),
    MaxSize = Vector2.new(1100, 800),
    Position = UDim2.fromScale(0.48, 0.52),
    Resizable = true,
    Draggable = true,
    Minimizable = true,
    Closable = true,
    CloseBehavior = "Hide",
})

local dashboardTab = main:AddTab({ Title = "Dashboard", Selected = true })
local controlsTab = main:AddTab({ Title = "Controls" })
local catalogTab = main:AddTab({ Title = "Catalog" })
local dataTab = main:AddTab({ Title = "Data & Logs" })
local compositionTab = main:AddTab({ Title = "Composition" })

-- DASHBOARD: badges, status, metrics, notifications and nested controls.
local statusSection = dashboardTab:AddSection({ Title = "System status", Description = "Status and runtime metrics" })
statusSection:AddBadge({ Text = "STABLE", Variant = "Success" })
local liveStatus = statusSection:AddStatusIndicator({ Status = "RUNNING", Text = "All UI services initialized" })
local fpsMetric = statusSection:AddMetricCard({ Title = "Render performance", Value = "—", Description = "Current client FPS" })
local sessionsMetric = statusSection:AddMetricCard({ Title = "Demo records", Value = "128", Description = "Sample data only" })
local statusProperties = statusSection:AddKeyValueList({ Data = {
    Framework = "Harkening UI",
    Version = Harkening.Version or "2.x",
    State = "RUNNING",
    Runtime = "Client",
} })

statusSection:AddPrimaryButton({ Title = "Refresh demo metrics", Icon = Harkening.Icons["icono-cursor-fill"], Callback = function()
    fpsMetric:SetValue(tostring(math.random(55, 144)) .. " FPS", "Simulated showcase reading")
    sessionsMetric:SetValue(tostring(math.random(100, 999)), "Updated just now")
    liveStatus:SetStatus("READY", "Metrics refreshed")
    ui:Notify({ Title = "Dashboard updated", Description = "The showcase values were refreshed.", Duration = 3 })
end })

statusSection:AddButton({ Title = "Show success notification", Description = "Demonstrates stacked toast notifications", Callback = function()
    ui:Notify({ Title = "Saved successfully", Description = "Your demo settings were saved.", Duration = 3, Color = Color3.fromRGB(82, 190, 137) })
    ui:Notify({ Title = "Additional information", Description = "Notifications stack and reposition themselves.", Duration = 4 })
end })

local actionsSection = dashboardTab:AddSection({ Title = "Window actions", Description = "Windows, dialogs and HUD control" })
local settingsWindow

actionsSection:AddButton({ Title = "Open secondary settings window", Callback = function()
    if not settingsWindow or settingsWindow._destroyed then
        settingsWindow = ui:CreateWindow({ Id = "settings", Title = "Secondary window", Description = "An independent window",
            Size = UDim2.fromOffset(380, 360), Position = UDim2.fromScale(0.62, 0.52), Resizable = true })
        local settingsTab = settingsWindow:AddTab({ Title = "Settings" })
        local settingsSection = settingsTab:AddSection({ Title = "Appearance" })
        settingsSection:AddToggle({ Title = "Enable a demo option", Value = true, Callback = function(value)
            ui:Notify({ Title = "Setting changed", Description = "Enabled: " .. tostring(value), Duration = 2 })
        end })
        settingsSection:AddDropdown({ Title = "Density", Options = { "Comfortable", "Compact", "Spacious" }, Value = "Comfortable", Callback = function(value)
            print("Density:", value)
        end })
        settingsSection:AddButton({ Title = "Hide this window", Callback = function() settingsWindow:Hide() end })
    else
        settingsWindow:Show()
    end
end })

actionsSection:AddButton({ Title = "Open confirmation dialog", Callback = function()
    ui:CreateModal({
        Title = "Confirm action",
        Description = "This dialog demonstrates confirmation and cancellation callbacks.",
        ConfirmText = "Confirm",
        CancelText = "Cancel",
        OnConfirm = function()
            ui:Notify({ Title = "Confirmed", Description = "The OnConfirm callback was executed.", Duration = 3 })
            return true
        end,
        OnCancel = function() print("Confirmation cancelled") end,
    })
end })

actionsSection:AddButton({ Title = "Open contextual popup", Callback = function()
    local popup = ui:CreatePopup({ Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(250, 180) })
    popup:AddLabel({ Text = "Quick actions", Bold = true })
    popup:AddParagraph({ Text = "This popup has its own component container." })
    popup:AddButton({ Title = "Notify from popup", Callback = function()
        ui:Notify({ Title = "Popup action", Description = "Nested component action executed.", Duration = 2 })
        popup:Close()
    end })
    popup:Open()
end })

actionsSection:AddButton({ Title = "Toggle watermark", Callback = function()
    local watermark = ui:GetWatermark()
    ui:SetWatermarkVisible(not (watermark and watermark:IsVisible()))
end })

actionsSection:AddButton({ Title = "Change watermark layout", Callback = function()
    local watermark = ui:GetWatermark()
    local isExpanded = watermark and watermark.Options.Style == "Expanded"
    ui:UpdateWatermark({ Style = isExpanded and "Compact" or "Expanded", ShowFPS = true, ShowClock = not isExpanded, Status = "RUNNING" })
end })

-- CONTROLS: all key existing controls plus new selection/input components.
local controlSection = controlsTab:AddSection({ Title = "Boolean and action controls" })
controlSection:AddButton({ Title = "Secondary button", Variant = "Secondary", Callback = function() print("Secondary button pressed") end })
controlSection:AddDestructiveButton({ Title = "Destructive-style action", Description = "Showcase only; does not delete data", Callback = function()
    ui:Notify({ Title = "Demo action", Description = "No real data was deleted.", Duration = 3, Color = Color3.fromRGB(232, 86, 99) })
end })
controlSection:AddIconButton({ Title = "Icon only", Icon = Harkening.Icons["icono-dropdown-list"], Callback = function() print("Icon-only button activated") end })
controlSection:AddCheckbox({ Title = "Checkbox control", Description = "Boolean control with checkbox visuals", Value = true, Callback = function(value) print("Checkbox:", value) end })
controlSection:AddToggle({ Title = "Toggle control", Description = "Independent boolean state", Value = false, Callback = function(value) print("Toggle:", value) end })

local valueSection = controlsTab:AddSection({ Title = "Values and selection" })
local volumeSlider = valueSection:AddSlider({ Title = "Volume", Min = 0, Max = 100, Step = 5, Value = 65, Callback = function(value) print("Volume:", value) end })
valueSection:AddRangeSlider({ Title = "Allowed range", Min = 0, Max = 100, Step = 5, MinValue = 20, MaxValue = 75, Callback = function(low, high)
    print("Range:", low, high)
end })
valueSection:AddDropdown({ Title = "Searchable single selection", Searchable = true, Placeholder = "Choose a language", Options = {
    { Value = "luau", Text = "Luau", Description = "Roblox scripting" },
    { Value = "lua", Text = "Lua", Description = "Embedded scripting" },
    { Value = "python", Text = "Python" },
    { Value = "typescript", Text = "TypeScript" },
}, Value = "luau", Callback = function(value) print("Language:", value) end })
valueSection:AddMultiSelectDropdown({ Title = "Multiple tags", Options = { "UI", "Animation", "Input", "Data", "Windows" },
    Value = { "UI", "Animation" }, MaxSelected = 4, Placeholder = "Select tags", Callback = function(values) print("Tags:", table.concat(values, ", ")) end })
valueSection:AddRadioGroup({ Title = "Display mode", Direction = "Vertical", Value = "Auto", Options = {
    { Value = "Auto", Text = "Automatic", Description = "Choose based on screen size" },
    { Value = "Compact", Text = "Compact" },
    { Value = "Detailed", Text = "Detailed" },
}, Callback = function(value) print("Display mode:", value) end })
valueSection:AddSegmented({ Title = "Preview density", Options = { "Small", "Medium", "Large" }, Value = "Medium", Callback = function(value) print("Density:", value) end })
valueSection:AddColorPicker({ Title = "Accent color", Value = Color3.fromRGB(100, 166, 255), Callback = function(value)
    ui:SetTheme({ Accent = value })
    ui:Notify({ Title = "Accent updated", Description = "New components will use this theme color.", Duration = 2 })
end })
valueSection:AddTextInput({ Title = "Short text input", Placeholder = "Type something…", Value = "Harkening", MaxLength = 60, Callback = function(value) print("Text:", value) end })
valueSection:AddTextArea({ Title = "Multiline notes", Description = "A larger field suitable for notes or descriptions", Placeholder = "Write notes here…", Value = "Harkening UI supports nested components." })
valueSection:AddNumericInput({ Title = "Numeric value", Min = 0, Max = 1000, Value = 125, Callback = function(value) print("Number:", value) end })
valueSection:AddKeybind({ Title = "Test keybind", Value = Enum.KeyCode.RightShift, Callback = function(key) print("Keybind pressed:", key.Name) end })

local searchButton = valueSection:AddSearchableDropdown({ Title = "Searchable dropdown alias", Options = { "Alpha", "Bravo", "Charlie", "Delta", "Echo" }, Placeholder = "Search and select" })
valueSection:AddButton({ Title = "Set slider programmatically", Callback = function() volumeSlider:SetValue(40, true) end })
valueSection:AddButton({ Title = "Open dropdown programmatically", Callback = function() searchButton:Open() end })

-- CATALOG: data-driven cards, filtering, sort and item selection.
local catalogSection = catalogTab:AddSection({ Title = "Object catalog", Description = "Search, filter, select and invoke per-item actions" })
local catalog = catalogSection:AddItemCatalog({
    Height = 310,
    MaxRender = 30,
    SortBy = "Name",
    ActionText = "Inspect",
    EmptyText = "No objects found.",
    Items = {
        { Id = "sword-001", Name = "Training Blade", Description = "A simple starter weapon", Category = "Weapon", Rarity = "Common", Value = 25 },
        { Id = "shield-002", Name = "Iron Shield", Description = "Defensive equipment", Category = "Armor", Rarity = "Uncommon", Value = 80 },
        { Id = "potion-003", Name = "Healing Potion", Description = "Restores a small amount of health", Category = "Consumable", Rarity = "Common", Amount = 3 },
        { Id = "gem-004", Name = "Azure Crystal", Description = "A rare crafting material", Category = "Material", Rarity = "Rare", Value = 450 },
        { Id = "key-005", Name = "Old Brass Key", Description = "Opens a forgotten door", Category = "Quest", Rarity = "Epic", Value = 0 },
    },
    OnItemSelected = function(item) print("Selected item:", item.Id, item.Name) end,
    OnAction = function(item) ui:Notify({ Title = "Inspect item", Description = item.Name .. " • " .. tostring(item.Category), Duration = 3 }) end,
})
local catalogActions = catalogTab:AddSection({ Title = "Catalog actions" })
catalogActions:AddButton({ Title = "Filter catalog to equipment", Callback = function() catalog:SetFilter(function(item) return item.Category == "Weapon" or item.Category == "Armor" end) end })
catalogActions:AddButton({ Title = "Clear category filter", Callback = function() catalog:SetFilter(nil) end })
catalogActions:AddButton({ Title = "Sort by value", Callback = function() catalog:SetSort("Value") end })
catalogActions:AddButton({ Title = "Show selected item", Callback = function()
    local item = catalog:GetSelected()
    ui:Notify({ Title = item and item.Name or "Nothing selected", Description = item and ("ID: " .. item.Id .. " | Value: " .. tostring(item.Value or item.Amount or 0)) or "Select an item in the catalog first.", Duration = 3 })
end })

-- DATA: sortable table, key/value properties, hierarchical tree, carousel and logs.
local tableSection = dataTab:AddSection({ Title = "Sortable data table" })
local dataTable = tableSection:AddDataTable({ Height = 210, EmptyText = "No records yet", Columns = {
    { Key = "Name", Title = "Name", Width = 0.42 },
    { Key = "Category", Title = "Category", Width = 0.34 },
    { Key = "Count", Title = "Count", Width = 0.24 },
}, Data = {
    { Id = "a", Name = "Buttons", Category = "Controls", Count = 14 },
    { Id = "b", Name = "Windows", Category = "Layout", Count = 5 },
    { Id = "c", Name = "Animations", Category = "Motion", Count = 12 },
}, OnRowSelected = function(record) print("Selected table row:", record.Name) end })
local dataActions = dataTab:AddSection({ Title = "Data operations" })
dataActions:AddButton({ Title = "Replace table data", Callback = function()
    dataTable:SetData({
        { Id = "x", Name = "Watermark", Category = "HUD", Count = 1 },
        { Id = "y", Name = "Dropdowns", Category = "Controls", Count = 4 },
        { Id = "z", Name = "Catalog items", Category = "Collections", Count = 25 },
    })
end })
local treeSection = dataTab:AddSection({ Title = "Hierarchical tree" })
local tree = treeSection:AddTreeView({ Height = 210, Nodes = {
    { Id = "core", Name = "Core", Expanded = true, Children = {
        { Id = "framework", Name = "Framework.lua" },
        { Id = "window", Name = "WindowManager.lua" },
    } },
    { Id = "components", Name = "Components", Children = {
        { Id = "buttons", Name = "Buttons" },
        { Id = "catalog", Name = "ItemCatalog" },
        { Id = "table", Name = "DataTable" },
    } },
    { Id = "services", Name = "Services", Children = {
        { Id = "tweens", Name = "TweenManager" },
        { Id = "watermark", Name = "Watermark" },
    } },
}, OnNodeSelected = function(node) print("Selected tree node:", node.Name, node.Id) end })
local treeActions = dataTab:AddSection({ Title = "Tree actions" })
treeActions:AddButton({ Title = "Expand all nodes", Callback = function() tree:ExpandAll() end })
treeActions:AddButton({ Title = "Collapse all nodes", Callback = function() tree:CollapseAll() end })
local carouselSection = dataTab:AddSection({ Title = "Horizontal carousel" })
carouselSection:AddCarousel({ Title = "Example projects", Height = 165, CardWidth = 150, Items = {
    { Id = "one", Title = "Dashboard", Description = "Metrics and status" },
    { Id = "two", Title = "Inventory", Description = "Search and selection" },
    { Id = "three", Title = "Admin panel", Description = "Tables and logs" },
    { Id = "four", Title = "Settings", Description = "Forms and controls" },
}, OnItemSelected = function(item) ui:Notify({ Title = item.Title, Description = item.Description, Duration = 2 }) end })
local logSection = dataTab:AddSection({ Title = "Runtime log viewer" })
local logViewer = logSection:AddLogViewer({ Height = 190, MaxLines = 100, Lines = {
    { Level = "INFO", Message = "Framework initialization completed" },
    { Level = "SUCCESS", Message = "Components registry loaded" },
    { Level = "WARN", Message = "This is a demonstration warning" },
} })
logSection:AddButton({ Title = "Append a log entry", Callback = function()
    logViewer:Append("A user requested a sample operation", "INFO")
end })

-- COMPOSITION: cards, accordions and forms can contain/use other components.
local compositionSection = compositionTab:AddSection({ Title = "Nested card" })
local card = compositionSection:AddCard({ Title = "Network preferences", Description = "A reusable card can host other components.", Image = nil })
card:AddToggle({ Title = "Enable network diagnostics", Value = false, Callback = function(value) print("Network diagnostics:", value) end })
card:AddDropdown({ Title = "Refresh rate", Options = { "1 second", "5 seconds", "10 seconds" }, Value = "5 seconds" })
card:AddButton({ Title = "Run diagnostics", Variant = "Primary", Callback = function() ui:Notify({ Title = "Diagnostics started", Duration = 2 }) end })
local accordion = compositionSection:AddAccordion({ Title = "Advanced options", Expanded = false })
accordion:AddCheckbox({ Title = "Verbose logging", Value = false })
accordion:AddToggle({ Title = "Experimental UI", Value = false })
accordion:AddRangeSlider({ Title = "Allowed values", Min = 0, Max = 50, Step = 1, MinValue = 10, MaxValue = 30 })

local formSection = compositionTab:AddSection({ Title = "Validated form" })
local form = formSection:AddForm({
    SubmitText = "Save profile",
    Fields = {
        { Name = "DisplayName", Type = "TextInput", Title = "Display name", Value = "HarkeningUser", Required = true, MaxLength = 32 },
        { Name = "Age", Type = "NumericInput", Title = "Demo numeric field", Min = 0, Max = 100, Value = 18 },
        { Name = "Notes", Type = "TextArea", Title = "Notes", Value = "This form demonstrates composed fields.", Height = 120 },
    },
    OnSubmit = function(values)
        print("Form submitted:", values.DisplayName, values.Age, values.Notes)
        ui:Notify({ Title = "Profile saved", Description = "The sample form validated successfully.", Duration = 3 })
    end,
})

compositionSection:AddEmptyState({ Title = "No pending tasks", Description = "This is a reusable empty state for lists and panels.", Icon = "◇" })
compositionSection:AddProgress({ Title = "Build progress", Min = 0, Max = 100, Value = 72, ShowPercent = true })
compositionSection:AddDivider({})
compositionSection:AddParagraph({ Title = "Lifecycle", Text = "Every framework-owned component is destroyed with ui:Destroy(). Dynamic catalog, table, tree and carousel rows disconnect their prior item listeners before rerendering." })

-- Example of the public factory for custom containers/advanced composition.
local customLabel = ui.Components:Create("Label", compositionSection.Content, { Text = "Created through ComponentFactory", Color = Color3.fromRGB(130, 190, 255) })

-- Clean exit helper for testing the lifecycle contract.
compositionSection:AddButton({ Title = "Destroy the complete showcase", Variant = "Destructive", Callback = function()
    ui:SetStatus("READY")
    ui:Destroy()
end })

print("[Harkening Showcase] Loaded components:", table.concat(ui:GetAvailableComponents(), ", "))
