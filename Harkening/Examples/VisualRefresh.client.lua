-- Harkening UI 2.2.3 — refined visual showcase.
-- 1) Build with Darklua; put dist/Harkening.lua in ReplicatedStorage as "Harkening".
-- 2) Run this LocalScript from StarterPlayerScripts in Roblox Studio.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Harkening = require(ReplicatedStorage:WaitForChild("Harkening"))

local ui = Harkening.new({
    Name = "HarkeningVisualRefresh",
    Animation = true,
    ResetOnSpawn = false,
    DisplayOrder = 90,
    Theme = {
        Background = Color3.fromRGB(12, 14, 19),
        Surface = Color3.fromRGB(17, 20, 27),
        SurfaceRaised = Color3.fromRGB(24, 29, 39),
        SurfaceHover = Color3.fromRGB(31, 38, 51),
        SurfaceInset = Color3.fromRGB(9, 11, 16),
        SurfaceSelected = Color3.fromRGB(45, 32, 62),
        Border = Color3.fromRGB(47, 56, 73),
        BorderSubtle = Color3.fromRGB(34, 41, 54),
        Text = Color3.fromRGB(241, 244, 250),
        MutedText = Color3.fromRGB(145, 156, 176),
        Accent = Color3.fromRGB(190, 108, 255),
        AccentSecondary = Color3.fromRGB(255, 91, 193),
    },
    Watermark = {
        Enabled = true,
        Title = "HARKENING UI",
        Text = "VISUAL PREVIEW",
        ShowLogo = true,
        ShowGameName = true,
        ShowGameIcon = true,
        ShowFPS = true,
        ShowClock = false,
        ShowStatus = true,
        Position = "TopRight",
        Style = "Compact",
        Status = "READY",
    },
})

local window = ui:CreateWindow({
    Id = "visual-main",
    Title = "Harkening UI",
    Description = "Dark interface with violet and fuchsia accents",
    Icon = "sparkles",
    Size = UDim2.fromOffset(900, 620),
    MinSize = Vector2.new(620, 440),
    MaxSize = Vector2.new(1280, 900),
    Resizable = true,
    Draggable = true,
    Minimizable = true,
    Maximizable = true,
    Closable = true,
    CloseBehavior = "Hide",
})

local overview = window:AddTab({ Title = "Overview", Icon = "grid", Selected = true })
local catalogTab = window:AddTab({ Title = "Item catalog", Icon = "inventory", Badge = "8" })
local controlsTab = window:AddTab({ Title = "Controls", Icon = "sliders" })

local metrics = overview:AddSection({
    Title = "Workspace overview",
    Description = "Clear hierarchy, quiet borders and a single accent color.",
    Icon = "chart",
})
metrics:AddMetricCard({ Title = "Registered items", Value = "128", Description = "+12 this session", Icon = "package" })
metrics:AddMetricCard({ Title = "Ready components", Value = "32", Description = "Shared component library", Icon = "layers" })
metrics:AddStatusIndicator({ Status = "READY", Text = "All demo components are initialized" })
metrics:AddParagraph({
    Title = "Visual direction",
    Text = "Harkening uses charcoal surfaces, soft outlines, restrained violet-fuchsia accents and icons that share consistent sizes. Accent rules are opt-in instead of decorating every card.",
})

local featured = overview:AddSection({ Title = "Featured actions", Description = "Hover states and feedback without visual noise.", Icon = "sparkles" })
featured:AddPrimaryButton({ Title = "Show success notification", Icon = "check", Callback = function()
    ui:Notify({ Type = "Success", Title = "Changes saved", Description = "The visual preview is running successfully.", Duration = 3 })
end })
featured:AddSecondaryButton({ Title = "Open item details", Icon = "box", Callback = function()
    ui:CreateModal({ Title = "Visual refresh", Description = "This modal uses the same surface, outline, radius and icon styling as the main window.",
        Icon = "sparkles", ConfirmText = "Got it", CancelText = "Close", OnConfirm = function() return true end })
end })

local catalogSection = catalogTab:AddSection({
    Title = "Inventory",
    Description = "Icons work with semantic names, asset IDs, or descriptors with custom tint.",
    Icon = "box",
})
local catalog = catalogSection:AddItemCatalog({
    Height = 442,
    CardHeight = 192,
    MaxRender = 40,
    Layout = "Grid",
    SortBy = "Name",
    ShowFavorite = true,
    ActionText = "Inspect",
    SearchPlaceholder = "Search inventory…",
    EmptyTitle = "No matching items",
    EmptyText = "Try another name, category or rarity.",
    Items = {
        {
            Id = "frostblade", Name = "Frostblade", Description = "A polished winter-forged blade.",
            Category = "Weapon", Rarity = "Legendary", Icon = { Name = "sword", Color = Color3.fromRGB(145, 187, 255) },
            Amount = 1, Price = 1250, Currency = "Coins", Equipped = true,
            Tags = { "Limited", "Winter" }, Stats = { Damage = 140, Speed = 1.2 },
            Meta = { Origin = "Winter event", Tradeable = "No" },
            Actions = { { Name = "Favorite", Icon = "heart", Callback = function(item) print("Quick favorite action:", item.Name) end } },
        },
        {
            Id = "azure-gem", Name = "Azure Gem", Description = "A clear crystal used for crafting.",
            Category = "Material", Rarity = "Rare", Icon = { Name = "gem", Color = Color3.fromRGB(100, 196, 255) },
            Amount = 8, Price = 320, Currency = "Coins", Tags = { "Crafting" }, Stats = { Purity = "A+" },
        },
        {
            Id = "healing-potion", Name = "Healing Potion", Description = "Restores a portion of health.",
            Category = "Consumable", Rarity = "Uncommon", Icon = "potion", Amount = 4, Price = 65,
            Currency = "Coins", Tags = { "Consumable" }, Stats = { Healing = 35 },
        },
        {
            Id = "sealed-relic", Name = "Sealed Relic", Description = "An old object of unknown origin.",
            Category = "Quest", Rarity = "Mythic", Icon = "rbxassetid://70534796161944", Locked = true,
            Tags = { "Quest", "Bound" }, Meta = { Origin = "Unknown", Inspectable = "Yes" },
        },
        {
            Id = "silver-key", Name = "Silver Key", Description = "May unlock an unopened cache.",
            Category = "Utility", Rarity = "Common", Icon = "key", Amount = 2, Price = 25, Currency = "Coins",
        },
        {
            Id = "companion", Name = "Moon Companion", Description = "A quiet companion that follows its owner.",
            Category = "Pet", Rarity = "Epic", Icon = { Name = "paw", Color = Color3.fromRGB(190, 157, 255) },
            Price = 980, Currency = "Coins", Tags = { "Companion", "Event" }, Stats = { Loyalty = 100 },
        },
    },
    OnItemSelected = function(item)
        print("Selected:", item.Name, item.Id)
    end,
    OnAction = function(item)
        ui:Notify({ Type = "Info", Title = item.Name, Description = "Item details opened from the catalog.", Duration = 3 })
    end,
    OnFavoriteChanged = function(item, favorite)
        print(item.Name, favorite and "added to favorites" or "removed from favorites")
    end,
})

local controls = controlsTab:AddSection({ Title = "Consistent controls", Description = "Controls use the same theme and spacing.", Icon = "sliders" })
controls:AddToggle({ Title = "Enable preview", Description = "A compact switch with a clear active state.", Value = true,
    Callback = function(enabled) ui:SetStatus(enabled and "RUNNING" or "READY") end })
controls:AddDropdown({ Title = "Density", Options = { "Comfortable", "Compact", "Spacious" }, Value = "Comfortable",
    Callback = function(value) print("Density:", value) end })
controls:AddSlider({ Title = "Accent intensity", Min = 0, Max = 100, Step = 5, Value = 65,
    Callback = function(value) print("Accent intensity:", value) end })
controls:AddButton({ Title = "Switch catalog to list", Icon = "list", Callback = function() catalog:SetLayout("List") end })
controls:AddButton({ Title = "Switch catalog to grid", Icon = "grid", Callback = function() catalog:SetLayout("Grid") end })

-- The HUD is created automatically by Harkening.new. These calls only demonstrate updates.
ui:UpdateWatermark({ Title = "HARKENING UI", Text = "VISUAL REFRESH", Style = "Compact", Status = "READY" })

-- To remove the preview and every managed component, call ui:Destroy().
