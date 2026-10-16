local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local IconRenderer = require("../Utilities/IconRenderer")

local ItemCatalog = {}
ItemCatalog.__index = ItemCatalog
setmetatable(ItemCatalog, { __index = Base })

local RARITY_COLORS = {
    common = Color3.fromRGB(151, 162, 181), normal = Color3.fromRGB(151, 162, 181), basic = Color3.fromRGB(151, 162, 181),
    comun = Color3.fromRGB(151, 162, 181), comunun = Color3.fromRGB(151, 162, 181),
    uncommon = Color3.fromRGB(79, 199, 132), uncomun = Color3.fromRGB(79, 199, 132),
    rare = Color3.fromRGB(89, 165, 255), raro = Color3.fromRGB(89, 165, 255),
    epic = Color3.fromRGB(177, 113, 255), epico = Color3.fromRGB(177, 113, 255),
    legendary = Color3.fromRGB(255, 174, 83), legendario = Color3.fromRGB(255, 174, 83),
    mythic = Color3.fromRGB(255, 93, 128), mythical = Color3.fromRGB(255, 93, 128), mitico = Color3.fromRGB(255, 93, 128),
    divine = Color3.fromRGB(255, 220, 111), divino = Color3.fromRGB(255, 220, 111),
    limited = Color3.fromRGB(99, 224, 218), limitededition = Color3.fromRGB(99, 224, 218), limitado = Color3.fromRGB(99, 224, 218),
    secret = Color3.fromRGB(246, 98, 180), secreto = Color3.fromRGB(246, 98, 180),
    celestial = Color3.fromRGB(129, 205, 255), ancient = Color3.fromRGB(211, 162, 105), exotic = Color3.fromRGB(255, 130, 86),
}

local function itemId(item, index)
    return item.Id or item.ID or item.Key or tostring(item.Name or item.Title or "Item") .. "#" .. tostring(index)
end

local function firstValue(...)
    for index = 1, select("#", ...) do
        local value = select(index, ...)
        if value ~= nil and value ~= "" then return value end
    end
    return nil
end

local function normalize(items)
    assert(type(items) == "table", "Items debe ser una tabla")
    local out, seen = {}, {}
    for index, item in ipairs(items) do
        if type(item) == "string" or type(item) == "number" then item = { Name = tostring(item) } end
        assert(type(item) == "table", "Cada item debe ser una tabla, string o number")
        local copy = table.clone(item)
        copy.Name = tostring(firstValue(copy.Name, copy.Title, copy.DisplayName, "Untitled item"))
        copy.Description = tostring(firstValue(copy.Description, copy.Subtitle, copy.Info, ""))
        copy.Id = itemId(copy, index)
        copy.Image = firstValue(copy.Image, copy.Thumbnail, copy.ThumbnailId, copy.ImageId, copy.PreviewImage, copy.ImageAsset, copy.AssetId, copy.Asset)
        copy.Icon = firstValue(copy.Icon, copy.IconName, copy.IconId, copy.Symbol, copy.IconAsset, copy.Emblem)
        copy.Category = firstValue(copy.Category, copy.Type, copy.Group)
        copy.Rarity = firstValue(copy.Rarity, copy.Quality, copy.Tier)
        copy.Amount = firstValue(copy.Amount, copy.Count, copy.Quantity, copy.StackSize)
        copy.Price = firstValue(copy.Price, copy.Cost, copy.Worth)
        copy.Tags = type(copy.Tags) == "table" and table.clone(copy.Tags) or (copy.Tag and { copy.Tag } or {})
        copy.Stats = type(copy.Stats) == "table" and copy.Stats or {}
        copy.Meta = type(copy.Meta) == "table" and copy.Meta or {}
        assert(not seen[copy.Id], "ID de item duplicado: " .. tostring(copy.Id))
        seen[copy.Id] = true
        out[#out + 1] = copy
    end
    return out
end

local function inferIcon(item)
    -- Explicit assets and semantic names always take priority over inference.
    if item.Icon ~= nil then return item.Icon end
    local text = string.lower(tostring(item.Category or "") .. " " .. item.Name)
    local function hasAny(words)
        for _, word in ipairs(words) do if text:find(word, 1, true) then return true end end
        return false
    end
    if hasAny({ "sword", "weapon", "blade", "espada", "arma", "hoja", "katana" }) then return "sword" end
    if hasAny({ "pet", "animal", "mascota", "companion", "compañero", "perro", "gato", "dragon", "dragón" }) then return "paw" end
    if hasAny({ "coin", "gold", "money", "currency", "moneda", "oro", "dinero", "cash", "dollar", "dólar" }) then return "coins" end
    if hasAny({ "gem", "crystal", "diamond", "cristal", "gema", "diamante", "joya" }) then return "gem" end
    if hasAny({ "potion", "elixir", "poción", "pocion", "elixir", "brebaje" }) then return "potion" end
    if hasAny({ "chest", "crate", "box", "cofre", "caja", "baúl", "baul", "loot" }) then return "box" end
    if hasAny({ "tool", "gear", "hammer", "pickaxe", "herramienta", "martillo", "pico" }) then return "wrench" end
    if hasAny({ "badge", "achievement", "medal", "insignia", "logro", "medalla" }) then return "medal" end
    if hasAny({ "book", "spell", "tome", "libro", "hechizo", "grimorio" }) then return "book" end
    if hasAny({ "food", "apple", "bread", "comida", "manzana", "pan", "fruta" }) then return "food" end
    if hasAny({ "armor", "armour", "shield", "armadura", "escudo" }) then return "shield" end
    if hasAny({ "key", "llave", "token", "ticket", "boleto", "pase" }) then return "key" end
    if hasAny({ "car", "vehicle", "vehículo", "vehiculo", "coche", "auto", "truck", "camión", "camion" }) then return "car" end
    if hasAny({ "house", "home", "casa", "hogar", "building", "edificio" }) then return "house" end
    return "item"
end

local function rarityColor(theme, rarity)
    local key = string.lower(tostring(rarity or "")):gsub("[%s%._%-]+", "")
    return RARITY_COLORS[key] or theme:Get("Accent")
end

-- Keep this after rarityColor so the local helper is resolved correctly.
local function iconColor(item, theme)
    if type(item.Icon) == "table" and (item.Icon.Color or item.Icon.ImageColor3 or item.Icon.Tint) then
        return item.Icon.Color or item.Icon.ImageColor3 or item.Icon.Tint
    end
    return item.IconColor or rarityColor(theme, item.Rarity)
end

local function createPill(parent, text, color, options)
    options = options or {}
    local frame = Builder.Create("Frame", {
        Name = options.Name or "Pill", BackgroundColor3 = color, BackgroundTransparency = options.Transparency or 0.84,
        BorderSizePixel = 0, Size = options.Size or UDim2.fromOffset(options.Width or 72, options.Height or 19),
        Position = options.Position or UDim2.new(), AnchorPoint = options.AnchorPoint or Vector2.new(0, 0),
    }, parent)
    Builder.Corner(frame, 6)
    local label = Builder.Label(frame, "Text", tostring(text), UDim2.new(1, -10, 1, 0), UDim2.new(0, 5, 0, 0), color, options.TextSize or 9, true)
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.TextTruncate = Enum.TextTruncate.AtEnd
    return frame
end

function ItemCatalog.new(context, parent, options)
    options = options or {}
    local theme = context.Theme
    local height = math.clamp(tonumber(options.Height) or 330, 160, 900)
    local initialLayout = options.Layout == "List" and "List" or "Grid"
    local frame = Builder.Create("Frame", {
        Name = options.Name or "ItemCatalog", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height),
    }, parent)

    -- Unified catalog toolbar, styled as an inset field with compact action controls.
    local toolbar = Builder.Create("Frame", { Name = "Toolbar", Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1, BorderSizePixel = 0 }, frame)
    local searchFrame = Builder.Create("Frame", { Name = "SearchField", Size = UDim2.new(1, -158, 1, 0),
        BackgroundColor3 = theme:Get("SurfaceInset"), BorderSizePixel = 0 }, toolbar)
    Builder.Corner(searchFrame, 9)
    local searchStroke = Builder.Stroke(searchFrame, theme:Get("BorderSubtle"), 0.28, 1)
    IconRenderer.Create(searchFrame, "search", { Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 11, 0.5, -8), Color = theme:Get("MutedText"), Fallback = "search", TextSize = 16 })
    local search = Builder.Create("TextBox", {
        Name = "Search", Position = UDim2.new(0, 34, 0, 0), Size = UDim2.new(1, -42, 1, 0),
        PlaceholderText = options.SearchPlaceholder or "Search items, tags, rarity…", Text = "", ClearTextOnFocus = false,
        BackgroundTransparency = 1, BorderSizePixel = 0, Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = theme:Get("Text"), PlaceholderColor3 = theme:Get("MutedText"), TextXAlignment = Enum.TextXAlignment.Left,
    }, searchFrame)
    local sortButton = Builder.Create("TextButton", { Name = "Sort", Position = UDim2.new(1, -151, 0, 0), Size = UDim2.fromOffset(88, 36),
        BackgroundColor3 = theme:Get("SurfaceRaised"), BorderSizePixel = 0, Text = "   Name  ↑", TextColor3 = theme:Get("MutedText"),
        TextSize = 10, Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Center, AutoButtonColor = false }, toolbar)
    Builder.Corner(sortButton, 9); Builder.Stroke(sortButton, theme:Get("BorderSubtle"), 0.55, 1)
    IconRenderer.Create(sortButton, "sort", { Size = UDim2.fromOffset(13, 13), Position = UDim2.new(0, 8, 0.5, -6.5), Color = theme:Get("Accent"), Fallback = "sort", TextSize = 13 })
    local viewButton = Builder.Create("TextButton", { Name = "ToggleView", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromOffset(36, 36), BackgroundColor3 = theme:Get("SurfaceRaised"), BorderSizePixel = 0,
        Text = "", AutoButtonColor = false }, toolbar)
    Builder.Corner(viewButton, 9); Builder.Stroke(viewButton, theme:Get("BorderSubtle"), 0.55, 1)
    local viewIcon = IconRenderer.Create(viewButton, initialLayout == "Grid" and "list" or "grid", {
        Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0.5, -8, 0.5, -8), Color = theme:Get("Text"), Fallback = "grid", TextSize = 16,
    })

    local filters = Builder.Create("ScrollingFrame", { Name = "CategoryFilters", Position = UDim2.new(0, 0, 0, 43),
        Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, BorderSizePixel = 0,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollBarThickness = 0,
        ScrollingDirection = Enum.ScrollingDirection.X, Visible = options.ShowCategoryFilters ~= false,
    }, frame)
    Builder.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6), VerticalAlignment = Enum.VerticalAlignment.Center }, filters)

    local listTop = options.ShowCategoryFilters == false and 43 or 76
    local list = Builder.Create("ScrollingFrame", { Name = "Items", Position = UDim2.new(0, 0, 0, listTop),
        Size = UDim2.new(1, 0, 1, -listTop), BackgroundTransparency = 1, BorderSizePixel = 0,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme:Get("Border"), ScrollingDirection = Enum.ScrollingDirection.Y,
    }, frame)
    Builder.Padding(list, 2, 6, 2, 8)
    local layout
    if initialLayout == "Grid" then
        layout = Builder.Create("UIGridLayout", {
            Name = "GridLayout", SortOrder = Enum.SortOrder.LayoutOrder,
            CellSize = UDim2.new(0.333, -8, 0, options.CardHeight or 184), CellPadding = UDim2.fromOffset(8, 8),
        }, list)
    else
        layout = Builder.Create("UIListLayout", {
            Name = "ListLayout", SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 7),
        }, list)
    end
    local empty = Builder.Create("Frame", { Name = "EmptyState", Position = UDim2.new(0, 0, 0, listTop),
        Size = UDim2.new(1, 0, 1, -listTop), BackgroundTransparency = 1, Visible = false, ZIndex = 20,
    }, frame)
    local emptyIconTile = Builder.Create("Frame", { Name = "IconTile", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, -37), Size = UDim2.fromOffset(40, 40),
        BackgroundColor3 = theme:Get("SurfaceRaised"), BackgroundTransparency = 0.2, BorderSizePixel = 0, ZIndex = 21 }, empty)
    Builder.Corner(emptyIconTile, 12)
    Builder.Stroke(emptyIconTile, theme:Get("BorderSubtle"), 0.42, 1)
    IconRenderer.Create(emptyIconTile, "search", { Size = UDim2.fromOffset(19, 19), Position = UDim2.new(0.5, -9.5, 0.5, -9.5),
        Color = theme:Get("MutedText"), Fallback = "search", TextSize = 19, ZIndex = 22 })
    local emptyTitle = Builder.Label(empty, "Title", tostring(options.EmptyTitle or "Nothing here yet"),
        UDim2.new(1, -20, 0, 22), UDim2.new(0, 10, 0.5, -5), theme:Get("Text"), 12, true); emptyTitle.TextXAlignment = Enum.TextXAlignment.Center; emptyTitle.ZIndex = 21
    local emptyText = Builder.Label(empty, "Description", tostring(options.EmptyText or "Try changing your search or filters."),
        UDim2.new(1, -30, 0, 28), UDim2.new(0, 15, 0.5, 17), theme:Get("MutedText"), 10, false); emptyText.TextXAlignment = Enum.TextXAlignment.Center; emptyText.TextYAlignment = Enum.TextYAlignment.Top; emptyText.ZIndex = 21

    local self = setmetatable({}, ItemCatalog)
    Base.Initialize(self, context, frame)
    self.Items, self.Filter, self.SearchText, self.SortBy, self.SelectedId = {}, nil, "", options.SortBy or "Name", nil
    self._rowItems, self._rowConnections = {}, {}
    self._filterButtons, self._filterConnections = {}, {}
    self._favorites = {}
    self._onSelect, self._onAction = options.OnItemSelected, options.OnAction
    self._onFavoriteChanged = options.OnFavoriteChanged
    self._maxRender = math.clamp(tonumber(options.MaxRender) or 72, 10, 500)
    self._displayCount = self._maxRender
    self._sortDescending = options.SortDescending == true
    self._layoutMode = initialLayout
    self._showFavorite = options.ShowFavorite ~= false
    self._sortFields = options.SortFields or { "Name", "Rarity", "Price", "Amount" }
    self._sortIndex = 1
    for index, field in ipairs(self._sortFields) do if field == self.SortBy then self._sortIndex = index; break end end

    local function disconnectConnections(array)
        for _, connection in ipairs(array) do if connection.Connected then connection:Disconnect() end end
        table.clear(array)
    end
    local function disconnectRows()
        disconnectConnections(self._rowConnections)
        for _, row in ipairs(self._rowItems) do if row.Parent then row:Destroy() end end
        table.clear(self._rowItems)
    end
    local function addConnection(connection)
        table.insert(self._rowConnections, connection)
    end
    local function itemIsFavorite(item)
        if self._favorites[item.Id] ~= nil then return self._favorites[item.Id] end
        return item.Favorite == true or item.IsFavorite == true
    end
    local function updateSortText()
        sortButton.Text = tostring(self.SortBy or "Name") .. (self._sortDescending and "  ↓" or "  ↑")
    end
    local function setSortKey(key, descending)
        self.SortBy = key
        self._sortDescending = descending == true
        for index, field in ipairs(self._sortFields) do if field == key then self._sortIndex = index; break end end
        updateSortText()
    end
    local function getRows()
        local rows, query = {}, string.lower(self.SearchText)
        for _, item in ipairs(self.Items) do
            local tags = table.concat((function()
                local arr = {}
                for _, tag in ipairs(item.Tags or {}) do arr[#arr + 1] = tostring(tag) end
                return arr
            end)(), " ")
            local meta = {}
            for key, value in pairs(item.Meta or {}) do meta[#meta + 1] = tostring(key) .. " " .. tostring(value) end
            local haystack = string.lower(table.concat({ item.Name, item.Description, tostring(item.Category or ""), tostring(item.Rarity or ""), tostring(item.Id), tags, table.concat(meta, " ") }, " "))
            local matchesQuery = query == "" or string.find(haystack, query, 1, true) ~= nil
            local functionMatches = false
            if type(self.Filter) == "function" then local ok, result = pcall(self.Filter, item); functionMatches = ok and result == true end
            local matchesExplicitFilter = self.Filter == nil or functionMatches or item.Category == self.Filter or item.Rarity == self.Filter
            local matchesChip = self._chipFilter == nil or item.Category == self._chipFilter or item.Rarity == self._chipFilter
            if matchesQuery and matchesExplicitFilter and matchesChip then rows[#rows + 1] = item end
        end
        if self.SortBy then
            local key, descending = self.SortBy, self._sortDescending
            table.sort(rows, function(a, b)
                local av, bv = a[key], b[key]
                if av == nil and bv ~= nil then return false end
                if bv == nil and av ~= nil then return true end
                if av == bv then return tostring(a.Id) < tostring(b.Id) end
                if type(av) == "number" and type(bv) == "number" then return descending and av > bv or (not descending and av < bv) end
                av, bv = string.lower(tostring(av or "")), string.lower(tostring(bv or ""))
                return descending and av > bv or (not descending and av < bv)
            end)
        end
        return rows
    end

    local render
    local detailsOverlay, detailsPanel
    self._detailsConnections = {}
    local function detailConnect(signal, callback)
        table.insert(self._detailsConnections, signal:Connect(callback))
    end
    local function clearDetails()
        for _, connection in ipairs(self._detailsConnections) do
            if connection.Connected then connection:Disconnect() end
        end
        table.clear(self._detailsConnections)
        if detailsOverlay and detailsOverlay.Parent then detailsOverlay:Destroy() end
        detailsOverlay, detailsPanel = nil, nil
    end
    local function selectItem(item)
        if self._destroyed or not self.Enabled then return end
        self.SelectedId = item.Id
        self:FocusWindow()
        if type(self._onSelect) == "function" then task.spawn(self._onSelect, table.clone(item), self) end
        render()
    end
    local function openDetails(item)
        if self._destroyed or not self.Enabled then return false end
        clearDetails()
        self:FocusWindow()
        self.SelectedId = item.Id
        render()
        local overlay = Builder.Create("TextButton", { Name = "ItemDetailsOverlay", Size = UDim2.fromScale(1, 1),
            Position = UDim2.fromScale(0, 0), BackgroundColor3 = Color3.fromRGB(5, 7, 12), BackgroundTransparency = 0.20,
            BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 60 }, frame)
        detailsOverlay = overlay
        local panelWidth = math.clamp(frame.AbsoluteSize.X - 28, 250, 420)
        local panelHeight = math.clamp(frame.AbsoluteSize.Y - 28, 220, 360)
        local panel = Builder.Create("Frame", { Name = "ItemDetails", AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(panelWidth, panelHeight),
            BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0, ZIndex = 61, ClipsDescendants = true }, overlay)
        detailsPanel = panel
        Builder.Corner(panel, 12); Builder.Stroke(panel, theme:Get("Border"), 0.08, 1)
        Builder.Create("UIGradient", { Rotation = 90, Color = ColorSequence.new(theme:Get("SurfaceRaised"), theme:Get("Surface")) }, panel)
        local accent = Builder.Create("Frame", { Name = "AccentRule", Size = UDim2.new(0.18, 0, 0, 2),
            BackgroundColor3 = rarityColor(theme, item.Rarity), BorderSizePixel = 0, ZIndex = 62 }, panel)
        Builder.Create("UIGradient", { Color = ColorSequence.new(rarityColor(theme, item.Rarity), theme:Get("AccentSecondary")) }, accent)
        local close = Builder.Create("TextButton", { Name = "Close", AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -9, 0, 9), Size = UDim2.fromOffset(27, 27), BackgroundColor3 = theme:Get("SurfaceInset"),
            BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 64 }, panel)
        Builder.Corner(close, 8); Builder.Stroke(close, theme:Get("BorderSubtle"), 0.4, 1)
        IconRenderer.Create(close, "close", { Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0.5, -7, 0.5, -7),
            Color = theme:Get("MutedText"), TextSize = 14, ZIndex = 65 })
        detailConnect(close.Activated, clearDetails)

        local top = Builder.Create("Frame", { Name = "ItemHeader", Position = UDim2.new(0, 14, 0, 14),
            Size = UDim2.new(1, -28, 0, 76), BackgroundTransparency = 1, ZIndex = 62 }, panel)
        local artwork = Builder.Create("Frame", { Name = "Artwork", Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.fromOffset(70, 70), BackgroundColor3 = theme:Get("SurfaceInset"), BorderSizePixel = 0,
            ClipsDescendants = true, ZIndex = 63 }, top)
        Builder.Corner(artwork, 10); Builder.Stroke(artwork, rarityColor(theme, item.Rarity), 0.35, 1)
        if item.Image ~= nil and item.Image ~= "" then
            IconRenderer.Create(artwork, item.Image, { Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0, 0),
                Color = Color3.new(1, 1, 1), Fallback = false, ScaleType = options.ImageScaleType or Enum.ScaleType.Crop, ZIndex = 64 })
        else
            IconRenderer.Create(artwork, inferIcon(item), { Size = UDim2.fromOffset(32, 32), Position = UDim2.new(0.5, -16, 0.5, -16),
                Color = iconColor(item, theme), TextSize = 32, ZIndex = 64 })
        end
        local title = Builder.Label(top, "ItemName", item.Name, UDim2.new(1, -118, 0, 24), UDim2.new(0, 82, 0, 3), theme:Get("Text"), 15, true)
        title.ZIndex = 63; title.TextTruncate = Enum.TextTruncate.AtEnd
        local desc = Builder.Label(top, "ItemDescription", item.Description ~= "" and item.Description or tostring(item.Category or "No description available"),
            UDim2.new(1, -84, 0, 31), UDim2.new(0, 82, 0, 29), theme:Get("MutedText"), 10)
        desc.ZIndex = 63; desc.TextYAlignment = Enum.TextYAlignment.Top; desc.TextTruncate = Enum.TextTruncate.AtEnd
        local rarity = tostring(item.Rarity or item.Category or "ITEM")
        local rarityPill = createPill(top, rarity, rarityColor(theme, item.Rarity), { Position = UDim2.new(0, 82, 0, 54), Width = math.clamp(26 + #rarity * 5, 54, 112), Height = 18, TextSize = 8, Transparency = 0.82 })
        rarityPill.ZIndex = 63

        local bodyTop = 102
        local detailsScroll = Builder.Create("ScrollingFrame", { Name = "DetailsContent", Position = UDim2.new(0, 14, 0, bodyTop),
            Size = UDim2.new(1, -28, 1, -(bodyTop + 58)), BackgroundTransparency = 1, BorderSizePixel = 0,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3,
            ScrollBarImageColor3 = theme:Get("Border"), ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 62 }, panel)
        Builder.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }, detailsScroll)
        Builder.Padding(detailsScroll, 0, 3, 0, 5)
        local order = 0
        local function addTextBlock(name, value, color, height, bold)
            order += 1
            local label = Builder.Label(detailsScroll, name, value, UDim2.new(1, -2, 0, height or 18), UDim2.new(), color or theme:Get("Text"), 10, bold == true)
            label.LayoutOrder = order; label.ZIndex = 63; label.TextYAlignment = Enum.TextYAlignment.Top
            return label
        end
        if item.Tags and #item.Tags > 0 then
            local tagText = {}
            for _, tag in ipairs(item.Tags) do tagText[#tagText + 1] = tostring(tag) end
            addTextBlock("Tags", "TAGS   ·   " .. table.concat(tagText, "   /   "), theme:Get("Accent"), 22, true)
        end
        local function addMap(titleText, values)
            local keys = {}
            for key in pairs(values or {}) do keys[#keys + 1] = key end
            table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
            if #keys == 0 then return end
            order += 1
            local header = Builder.Label(detailsScroll, "Group_" .. titleText, string.upper(titleText), UDim2.new(1, 0, 0, 15), UDim2.new(), theme:Get("MutedText"), 8, true)
            header.LayoutOrder = order; header.ZIndex = 63
            for _, key in ipairs(keys) do
                order += 1
                local row = Builder.Create("Frame", { Name = "Property", LayoutOrder = order, Size = UDim2.new(1, -2, 0, 23),
                    BackgroundColor3 = theme:Get("SurfaceRaised"), BorderSizePixel = 0, ZIndex = 63 }, detailsScroll)
                Builder.Corner(row, 6)
                local keyLabel = Builder.Label(row, "Key", tostring(key), UDim2.new(0.47, -8, 1, 0), UDim2.new(0, 8, 0, 0), theme:Get("MutedText"), 9, false)
                keyLabel.ZIndex = 64; keyLabel.TextTruncate = Enum.TextTruncate.AtEnd
                local valueLabel = Builder.Label(row, "Value", tostring(values[key]), UDim2.new(0.53, -14, 1, 0), UDim2.new(0.47, 2, 0, 0), theme:Get("Text"), 9, true)
                valueLabel.ZIndex = 64; valueLabel.TextXAlignment = Enum.TextXAlignment.Right; valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
            end
        end
        if next(item.Stats) then addMap("Statistics", item.Stats) end
        if next(item.Meta) then addMap("Details", item.Meta) end
        if order == 0 then addTextBlock("NoMetadata", "No extra metadata was provided for this item.", theme:Get("MutedText"), 34, false) end

        local footer = Builder.Create("Frame", { Name = "Actions", AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 14, 1, -12),
            Size = UDim2.new(1, -28, 0, 34), BackgroundTransparency = 1, ZIndex = 63 }, panel)
        local actions = {}
        if item.ActionText or options.ActionText then
            actions[#actions + 1] = { Text = item.ActionText or options.ActionText, Callback = item.Callback or self._onAction, Variant = "Primary" }
        end
        if type(item.Actions) == "table" then for _, action in ipairs(item.Actions) do if #actions < 3 and type(action) == "table" then actions[#actions + 1] = action end end end
        if #actions == 0 then actions[1] = { Text = "Done", Variant = "Secondary", Callback = clearDetails } end
        local buttonGap = 7
        local buttonWidth = math.max(64, (panelWidth - 28 - (#actions - 1) * buttonGap) / #actions)
        for index, action in ipairs(actions) do
            local button = Builder.Create("TextButton", { Name = "Action_" .. index,
                Position = UDim2.new(0, (index - 1) * (buttonWidth + buttonGap), 0, 0), Size = UDim2.new(0, buttonWidth, 1, 0),
                BackgroundColor3 = action.Variant == "Primary" and theme:Get("Accent") or theme:Get("SurfaceRaised"),
                BorderSizePixel = 0, Text = tostring(action.Text or action.Title or "Action"),
                TextColor3 = action.Variant == "Primary" and theme:Get("AccentText") or theme:Get("Text"),
                TextSize = 10, Font = Enum.Font.GothamSemibold, AutoButtonColor = false, ZIndex = 64 }, footer)
            Builder.Corner(button, 7)
            detailConnect(button.Activated, function()
                if not self.Enabled or self._destroyed then return end
                local callback = action.Callback or action.OnClick or (action == actions[1] and self._onAction)
                if type(callback) == "function" then task.spawn(callback, table.clone(item), self) end
                if action.CloseOnClick ~= false then clearDetails() end
            end)
        end
        if type(self._onDetailsOpened) == "function" then task.spawn(self._onDetailsOpened, table.clone(item), self) end
        return true
    end
    local function setFavorite(item, value)
        self._favorites[item.Id] = value == true
        if type(self._onFavoriteChanged) == "function" then task.spawn(self._onFavoriteChanged, table.clone(item), value == true, self) end
        render()
    end
    local function metadataText(item)
        local pieces = {}
        if item.Category then pieces[#pieces + 1] = tostring(item.Category) end
        if item.Rarity then pieces[#pieces + 1] = tostring(item.Rarity) end
        if item.Equipped == true or item.IsEquipped == true then pieces[#pieces + 1] = "Equipped" end
        if item.Locked == true or item.IsLocked == true then pieces[#pieces + 1] = "Locked" end
        return table.concat(pieces, "  ·  ")
    end
    local function valueText(item)
        local value = firstValue(item.Price, item.Value, item.Cost, item.Worth)
        if value == nil then return nil end
        if options.ValuePrefix then return tostring(options.ValuePrefix) .. tostring(value) end
        if item.Currency then return tostring(value) .. " " .. tostring(item.Currency) end
        return tostring(value)
    end
    local function createFavoriteButton(parent, item, compact)
        if not self._showFavorite then return nil end
        local button = Builder.Create("TextButton", {
            Name = "Favorite", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -7, 0, 7),
            Size = UDim2.fromOffset(compact and 25 or 28, compact and 25 or 28),
            BackgroundColor3 = theme:Get("SurfaceInset"), BackgroundTransparency = 0.08, BorderSizePixel = 0,
            Text = "", AutoButtonColor = false,
        }, parent)
        Builder.Corner(button, 8); Builder.Stroke(button, theme:Get("BorderSubtle"), 0.35, 1)
        local glyph = IconRenderer.Create(button, "heart", { Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0.5, -7, 0.5, -7),
            Color = itemIsFavorite(item) and Color3.fromRGB(255, 94, 139) or theme:Get("MutedText"), Fallback = "heart", TextSize = 14 })
        addConnection(button.Activated:Connect(function()
            if self.Enabled and not self._destroyed then setFavorite(item, not itemIsFavorite(item)) end
        end))
        return button
    end
    local function createAction(parent, item, text, position, size, callback)
        local button = Builder.Create("TextButton", { Name = "Action", Position = position, Size = size,
            BackgroundColor3 = theme:Get("AccentSoft"), BorderSizePixel = 0, Text = tostring(text or "Open"),
            Font = Enum.Font.GothamSemibold, TextSize = 10, TextColor3 = theme:Get("Accent"), AutoButtonColor = false,
        }, parent)
        Builder.Corner(button, 7)
        addConnection(button.MouseEnter:Connect(function() if self.Enabled then context.Tweens:To(button, { BackgroundColor3 = theme:Get("Accent") , TextColor3 = theme:Get("AccentText") }, { Time = 0.1 }) end end))
        addConnection(button.MouseLeave:Connect(function() if self.Enabled then context.Tweens:To(button, { BackgroundColor3 = theme:Get("AccentSoft"), TextColor3 = theme:Get("Accent") }, { Time = 0.1 }) end end))
        addConnection(button.Activated:Connect(function()
            if not self.Enabled or self._destroyed then return end
            self:FocusWindow()
            local fn = callback or item.Callback or self._onAction
            if type(fn) == "function" then task.spawn(fn, table.clone(item), self) end
        end))
        return button
    end
    local function createTags(parent, item, layoutMode)
        -- Cards should remain tidy even when users provide many metadata tags.
        local x, visibleCount = 0, 0
        local maxBadges = layoutMode == "Grid" and 2 or 3
        local function addBadge(text, color, width)
            if visibleCount >= maxBadges then return false end
            width = width or math.clamp(16 + #tostring(text) * 5, 42, 82)
            createPill(parent, text, color, { Position = UDim2.new(0, x, 0, 0), Width = width, Height = 18, TextSize = 8, Transparency = 0.88 })
            x += width + 5
            visibleCount += 1
            return true
        end
        if item.Rarity then
            addBadge(item.Rarity, rarityColor(theme, item.Rarity))
        elseif item.Category then
            addBadge(item.Category, theme:Get("Info"))
        end
        if item.Equipped == true or item.IsEquipped == true then addBadge("EQUIPPED", theme:Get("Success"), 62) end
        if item.Locked == true or item.IsLocked == true then addBadge("LOCKED", theme:Get("Warning"), 50) end
        if visibleCount < maxBadges and type(item.Tags) == "table" then
            for _, tag in ipairs(item.Tags) do
                if visibleCount >= maxBadges then break end
                addBadge(tostring(tag), theme:Get("MutedText"))
            end
        end
    end
    local function createCard(item, index)
        local grid = self._layoutMode == "Grid"
        local selected = self.SelectedId == item.Id
        local cardHeight = grid and (options.CardHeight or 184) or (options.RowHeight or 84)
        local card = Builder.Create("Frame", {
            Name = "Item_" .. tostring(item.Id), LayoutOrder = index,
            BackgroundColor3 = selected and theme:Get("AccentSoft") or theme:Get("Surface"),
            BorderSizePixel = 0, Size = grid and UDim2.new(0.333, -8, 0, cardHeight) or UDim2.new(1, -6, 0, cardHeight),
            ClipsDescendants = true,
        }, list)
        Builder.Corner(card, 10)
        local cardStroke = Builder.Stroke(card, selected and theme:Get("Accent") or theme:Get("BorderSubtle"), selected and 0.10 or 0.42, 1)
        -- This hit surface is created first so actual action buttons are always above it.
        local selectButton = Builder.Create("TextButton", { Name = "SelectItem", BackgroundTransparency = 1,
            BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Text = "", AutoButtonColor = false, ZIndex = 1 }, card)
        table.insert(self._rowItems, card)
        local imageAsset = item.Image
        local iconValue = inferIcon(item)
        local holder, icon
        if grid then
            holder = Builder.Create("Frame", { Name = "Artwork", Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 0, 74), BackgroundColor3 = theme:Get("SurfaceRaised"), BorderSizePixel = 0, ClipsDescendants = true }, card)
            if imageAsset ~= nil and imageAsset ~= "" then
                icon = IconRenderer.Create(holder, imageAsset, { Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0, 0),
                    Color = Color3.new(1, 1, 1), Fallback = false, ScaleType = options.ImageScaleType or Enum.ScaleType.Crop })
            else
                Builder.Create("UIGradient", { Color = ColorSequence.new(theme:Get("SurfaceRaised"), theme:Get("SurfaceInset")), Rotation = 25 }, holder)
                local rarityRule = Builder.Create("Frame", { Name = "RarityRule", AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = rarityColor(theme, item.Rarity),
                    BackgroundTransparency = item.Rarity and 0.2 or 0.68, BorderSizePixel = 0 }, holder)
                local iconTile = Builder.Create("Frame", { Name = "IconTile", AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.48), Size = UDim2.fromOffset(48, 48), BackgroundColor3 = theme:Get("SurfaceInset"),
                    BackgroundTransparency = 0.20, BorderSizePixel = 0 }, holder)
                Builder.Corner(iconTile, 14); Builder.Stroke(iconTile, rarityColor(theme, item.Rarity), 0.66, 1)
                IconRenderer.Create(iconTile, iconValue, { Size = UDim2.fromOffset(26, 26), Position = UDim2.new(0.5, -13, 0.5, -13),
                    Color = iconColor(item, theme), Fallback = "item", TextSize = 26 })
            end
            if item.Amount ~= nil then
                createPill(card, "×" .. tostring(item.Amount), theme:Get("Text"), { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -7, 0, 7), Width = 38, Height = 19, TextSize = 9, Transparency = 0.16 })
            end
            createFavoriteButton(card, item, true)
            local title = Builder.Label(card, "Name", item.Name,
                UDim2.new(1, -20, 0, 18), UDim2.new(0, 10, 0, 81), theme:Get("Text"), 11, true)
            title.TextTruncate = Enum.TextTruncate.AtEnd
            local desc = Builder.Label(card, "Description", item.Description ~= "" and item.Description or tostring(item.Category or ""),
                UDim2.new(1, -20, 0, 25), UDim2.new(0, 10, 0, 101), theme:Get("MutedText"), 9, false)
            desc.TextTruncate = Enum.TextTruncate.AtEnd; desc.TextYAlignment = Enum.TextYAlignment.Top
            local tags = Builder.Create("Frame", { Name = "Tags", Position = UDim2.new(0, 10, 0, 130), Size = UDim2.new(1, -20, 0, 18),
                BackgroundTransparency = 1, BorderSizePixel = 0 }, card)
            createTags(tags, item, "Grid")
            local value = valueText(item)
            if value then
                local valueLabel = Builder.Label(card, "Value", value, UDim2.new(0.46, -12, 0, 18), UDim2.new(0, 10, 1, -25), theme:Get("Accent"), 10, true)
                valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
            end
            local actionText = item.ActionText or options.ActionText
            if actionText then createAction(card, item, actionText, UDim2.new(1, -78, 1, -29), UDim2.fromOffset(68, 22)) end
            local detailsButton = Builder.Create("TextButton", { Name = "Details", Position = UDim2.new(1, actionText and -109 or -35, 1, -29),
                Size = UDim2.fromOffset(24, 22), BackgroundColor3 = theme:Get("SurfaceRaised"), BorderSizePixel = 0,
                Text = "", AutoButtonColor = false }, card)
            Builder.Corner(detailsButton, 7); Builder.Stroke(detailsButton, theme:Get("BorderSubtle"), 0.48, 1)
            IconRenderer.Create(detailsButton, "info", { Size = UDim2.fromOffset(13, 13), Position = UDim2.new(0.5, -6.5, 0.5, -6.5),
                Color = theme:Get("MutedText"), TextSize = 13 })
            addConnection(detailsButton.Activated:Connect(function() openDetails(item) end))
            if type(item.Actions) == "table" then
                for actionIndex, action in ipairs(item.Actions) do
                    if actionIndex <= 2 and type(action) == "table" then
                        local actionBtn = Builder.Create("TextButton", { Name = "ExtraAction", AnchorPoint = Vector2.new(1, 0),
                            Position = UDim2.new(1, -((self._showFavorite and 40 or 7) + (actionIndex - 1) * 29), 0, 7),
                            Size = UDim2.fromOffset(25, 25), BackgroundColor3 = theme:Get("SurfaceInset"), BorderSizePixel = 0,
                            Text = "", AutoButtonColor = false }, card)
                        Builder.Corner(actionBtn, 8); Builder.Stroke(actionBtn, theme:Get("BorderSubtle"), 0.35, 1)
                        IconRenderer.Create(actionBtn, action.Icon or action.Name or "more", { Size = UDim2.fromOffset(13, 13),
                            Position = UDim2.new(0.5, -6.5, 0.5, -6.5), Color = theme:Get("Text"), Fallback = "item", TextSize = 13 })
                        addConnection(actionBtn.Activated:Connect(function()
                            if self.Enabled and type(action.Callback) == "function" then task.spawn(action.Callback, table.clone(item), self) end
                        end))
                    end
                end
            end
        else
            holder = Builder.Create("Frame", { Name = "Artwork", Position = UDim2.new(0, 10, 0.5, -28),
                Size = UDim2.fromOffset(56, 56), BackgroundColor3 = theme:Get("SurfaceRaised"), BorderSizePixel = 0, ClipsDescendants = true }, card)
            Builder.Corner(holder, 9)
            if imageAsset ~= nil and imageAsset ~= "" then
                IconRenderer.Create(holder, imageAsset, { Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0, 0), Color = Color3.new(1, 1, 1), Fallback = false,
                    ScaleType = options.ImageScaleType or Enum.ScaleType.Crop })
            else
                IconRenderer.Create(holder, iconValue, { Size = UDim2.fromOffset(28, 28), Position = UDim2.new(0.5, -14, 0.5, -14),
                    Color = iconColor(item, theme), Fallback = "item", TextSize = 28 })
            end
            local left = 78
            local rightInset = (item.ActionText or options.ActionText) and 100 or 14
            local name = Builder.Label(card, "Name", item.Name, UDim2.new(1, -(left + rightInset), 0, 18), UDim2.new(0, left, 0, 11), theme:Get("Text"), 12, true)
            name.TextTruncate = Enum.TextTruncate.AtEnd
            local descText = item.Description
            local meta = metadataText(item)
            if meta ~= "" then descText = descText ~= "" and (descText .. "  ·  " .. meta) or meta end
            local desc = Builder.Label(card, "Description", descText, UDim2.new(1, -(left + rightInset), 0, 16), UDim2.new(0, left, 0, 32), theme:Get("MutedText"), 10, false)
            desc.TextTruncate = Enum.TextTruncate.AtEnd
            local tagStrip = Builder.Create("Frame", { Name = "Tags", Position = UDim2.new(0, left, 0, 52), Size = UDim2.new(1, -(left + rightInset), 0, 18),
                BackgroundTransparency = 1, BorderSizePixel = 0 }, card)
            createTags(tagStrip, item, "List")
            local value = valueText(item)
            if value then
                local valueLabel = Builder.Label(card, "Value", value, UDim2.new(0, 140, 0, 15), UDim2.new(0, left, 1, -20), theme:Get("Accent"), 10, true)
                valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
            end
            createFavoriteButton(card, item, true)
            local actionText = item.ActionText or options.ActionText
            if actionText then createAction(card, item, actionText, UDim2.new(1, -82, 1, -31), UDim2.fromOffset(72, 24)) end
            local detailsButton = Builder.Create("TextButton", { Name = "Details", Position = UDim2.new(1, actionText and -111 or -38, 1, -31),
                Size = UDim2.fromOffset(24, 24), BackgroundColor3 = theme:Get("SurfaceRaised"), BorderSizePixel = 0,
                Text = "", AutoButtonColor = false }, card)
            Builder.Corner(detailsButton, 7); Builder.Stroke(detailsButton, theme:Get("BorderSubtle"), 0.48, 1)
            IconRenderer.Create(detailsButton, "info", { Size = UDim2.fromOffset(13, 13), Position = UDim2.new(0.5, -6.5, 0.5, -6.5),
                Color = theme:Get("MutedText"), TextSize = 13 })
            addConnection(detailsButton.Activated:Connect(function() openDetails(item) end))
        end
        -- Keep the card's selected state and border synchronized after re-rendering.
        selectButton.ZIndex = 1
        for _, child in ipairs(card:GetChildren()) do
            if child:IsA("GuiObject") and child ~= selectButton then
                child.ZIndex = math.max(child.ZIndex, 2)
                for _, descendant in ipairs(child:GetDescendants()) do
                    if descendant:IsA("GuiObject") then descendant.ZIndex = math.max(descendant.ZIndex, 3) end
                end
            end
        end
        addConnection(selectButton.Activated:Connect(function() selectItem(item) end))
        addConnection(card.MouseEnter:Connect(function()
            if not self.Enabled then return end
            context.Tweens:To(card, { BackgroundColor3 = self.SelectedId == item.Id and theme:Get("SurfaceSelected") or theme:Get("SurfaceHover") }, { Time = 0.12 })
            context.Tweens:To(cardStroke, { Color = self.SelectedId == item.Id and theme:Get("Accent") or theme:Get("Border") , Transparency = 0.12 }, { Time = 0.12 })
        end))
        addConnection(card.MouseLeave:Connect(function()
            if self._destroyed or not card.Parent then return end
            context.Tweens:To(card, { BackgroundColor3 = self.SelectedId == item.Id and theme:Get("SurfaceSelected") or theme:Get("Surface") }, { Time = 0.12 })
            context.Tweens:To(cardStroke, { Color = self.SelectedId == item.Id and theme:Get("Accent") or theme:Get("BorderSubtle"), Transparency = self.SelectedId == item.Id and 0.10 or 0.42 }, { Time = 0.12 })
        end))
        if item.Locked == true or item.IsLocked == true then
            local overlay = Builder.Create("Frame", { Name = "LockedOverlay", Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = theme:Get("Background"), BackgroundTransparency = 0.42, BorderSizePixel = 0, ZIndex = 30 }, card)
            IconRenderer.Create(overlay, "lock", { Size = UDim2.fromOffset(20, 20), Position = UDim2.new(0.5, -10, 0.5, -10),
                Color = theme:Get("Warning"), Fallback = "lock", TextSize = 20, ZIndex = 31 })
            overlay.Active = false
        end
    end

    local function updateGridCell()
        if self._layoutMode ~= "Grid" then return end
        local width = list.AbsoluteSize.X
        local columns = width >= 660 and 3 or (width >= 390 and 2 or 1)
        local cellWidth = math.max(145, (width - (columns - 1) * 8 - 14) / columns)
        layout.CellSize = UDim2.new(0, cellWidth, 0, options.CardHeight or 184)
        layout.CellPadding = UDim2.fromOffset(8, 8)
    end

    local function rebuildFilters()
        disconnectConnections(self._filterConnections)
        for _, child in ipairs(self._filterButtons) do if child.Parent then child:Destroy() end end
        table.clear(self._filterButtons)
        if not filters.Visible then return end
        local values, seen = { "All" }, { All = true }
        for _, item in ipairs(self.Items) do
            for _, value in ipairs({ item.Category, item.Rarity }) do
                if value ~= nil and not seen[tostring(value)] then
                    seen[tostring(value)] = true
                    values[#values + 1] = tostring(value)
                end
            end
        end
        table.sort(values, function(a, b) if a == "All" then return true elseif b == "All" then return false else return string.lower(a) < string.lower(b) end end)
        for index, name in ipairs(values) do
            local active = (name == "All" and self._chipFilter == nil) or name == self._chipFilter
            local button = Builder.Create("TextButton", { Name = "Filter_" .. name, LayoutOrder = index,
                Size = UDim2.fromOffset(math.clamp(20 + #name * 6, 44, 110), 24), BackgroundColor3 = active and theme:Get("AccentSoft") or theme:Get("Surface"),
                BorderSizePixel = 0, Text = name, TextColor3 = active and theme:Get("Accent") or theme:Get("MutedText"),
                TextSize = 9, Font = Enum.Font.GothamSemibold, AutoButtonColor = false }, filters)
            Builder.Corner(button, 7)
            if active then Builder.Stroke(button, theme:Get("Accent"), 0.48, 1) else Builder.Stroke(button, theme:Get("BorderSubtle"), 0.48, 1) end
            table.insert(self._filterButtons, button)
            table.insert(self._filterConnections, button.Activated:Connect(function()
                if name == "All" then self._chipFilter = nil else self._chipFilter = name end
                self._displayCount = self._maxRender
                rebuildFilters(); render()
            end))
        end
    end

    render = function()
        if self._destroyed then return end
        disconnectRows()
        local results = getRows()
        local shownCount = math.min(#results, self._displayCount)
        empty.Visible = #results == 0
        list.Visible = #results > 0
        for index = 1, shownCount do createCard(results[index], index) end
        if #results > shownCount then
            local more = Builder.Create("TextButton", { Name = "LoadMore", LayoutOrder = shownCount + 1,
                Size = self._layoutMode == "Grid" and UDim2.new(1, -8, 0, 32) or UDim2.new(1, -6, 0, 32),
                BackgroundColor3 = theme:Get("SurfaceRaised"), BorderSizePixel = 0,
                Text = "Show more   ·   " .. tostring(#results - shownCount) .. " remaining",
                Font = Enum.Font.GothamSemibold, TextSize = 10, TextColor3 = theme:Get("Accent"), AutoButtonColor = false,
            }, list)
            Builder.Corner(more, 8); Builder.Stroke(more, theme:Get("BorderSubtle"), 0.45, 1)
            table.insert(self._rowItems, more)
            addConnection(more.Activated:Connect(function()
                if self._destroyed then return end
                self._displayCount = math.min(#results, self._displayCount + self._maxRender)
                render()
            end))
        end
        updateGridCell()
    end

    local function setLayout(mode)
        mode = mode == "List" and "List" or "Grid"
        if mode == self._layoutMode then return end
        self._layoutMode = mode
        if layout and layout.Parent then layout:Destroy() end
        if viewIcon and viewIcon.Parent then viewIcon:Destroy() end
        if mode == "Grid" then
            layout = Builder.Create("UIGridLayout", { Name = "GridLayout", SortOrder = Enum.SortOrder.LayoutOrder,
                CellSize = UDim2.new(0, 200, 0, options.CardHeight or 184), CellPadding = UDim2.fromOffset(8, 8) }, list)
            viewIcon = IconRenderer.Create(viewButton, "list", { Name = "Icon", Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0.5, -8, 0.5, -8), Color = theme:Get("Text"), Fallback = "list", TextSize = 16 })
        else
            layout = Builder.Create("UIListLayout", { Name = "ListLayout", SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 7) }, list)
            viewIcon = IconRenderer.Create(viewButton, "grid", { Name = "Icon", Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0.5, -8, 0.5, -8), Color = theme:Get("Text"), Fallback = "grid", TextSize = 16 })
        end
        self._displayCount = self._maxRender
        render()
    end

    self:Connect(search:GetPropertyChangedSignal("Text"), function()
        self.SearchText = search.Text
        self._displayCount = self._maxRender
        render()
    end)
    self:Connect(search.Focused, function() context.Tweens:To(searchStroke, { Color = theme:Get("Accent"), Transparency = 0.05 }, { Time = 0.12 }) end)
    self:Connect(search.FocusLost, function() context.Tweens:To(searchStroke, { Color = theme:Get("BorderSubtle"), Transparency = 0.28 }, { Time = 0.12 }) end)
    self:Connect(viewButton.Activated, function() setLayout(self._layoutMode == "Grid" and "List" or "Grid") end)
    self:Connect(sortButton.Activated, function()
        if #self._sortFields == 0 then return end
        if self._sortIndex >= #self._sortFields then self._sortIndex = 1 else self._sortIndex += 1 end
        setSortKey(self._sortFields[self._sortIndex], false)
        render()
    end)
    self:Connect(sortButton.MouseButton2Click, function()
        setSortKey(self.SortBy, not self._sortDescending)
        render()
    end)
    self:Connect(list:GetPropertyChangedSignal("AbsoluteSize"), updateGridCell)
    self._search = search
    self._list = list
    self._toolbar = toolbar
    self._empty = empty

    function self:SetItems(items)
        assert(not self._destroyed, "Catalog destruido")
        self.Items = normalize(items)
        self.SelectedId = nil
        self._displayCount = self._maxRender
        rebuildFilters()
        render()
    end
    function self:GetItems()
        local out = {}
        for index, item in ipairs(self.Items) do out[index] = table.clone(item) end
        return out
    end
    function self:GetItem(id)
        for _, item in ipairs(self.Items) do if item.Id == id then return table.clone(item) end end
        return nil
    end
    function self:SetSearch(query)
        self.SearchText = tostring(query or ""); self._displayCount = self._maxRender
        if search.Text ~= self.SearchText then search.Text = self.SearchText else render() end
    end
    function self:SetFilter(filter)
        self.Filter = filter; self._displayCount = self._maxRender; render()
    end
    function self:SetCategoryFilter(filter)
        if filter == "All" then self._chipFilter = nil else self._chipFilter = filter end
        self._displayCount = self._maxRender; rebuildFilters(); render()
    end
    function self:SetSort(key, descending)
        assert(type(key) == "string", "SetSort espera una clave de ordenación")
        setSortKey(key, descending); self._displayCount = self._maxRender; render()
    end
    function self:SetLayout(mode) setLayout(mode) end
    function self:GetLayout() return self._layoutMode end
    function self:GetSelected()
        for _, item in ipairs(self.Items) do if item.Id == self.SelectedId then return table.clone(item) end end
        return nil
    end
    function self:Select(id, fireCallback)
        for _, item in ipairs(self.Items) do
            if item.Id == id then
                self.SelectedId = id; render()
                if fireCallback == true and type(self._onSelect) == "function" then task.spawn(self._onSelect, table.clone(item), self) end
                return true
            end
        end
        return false
    end
    function self:SetFavorite(id, value)
        for _, item in ipairs(self.Items) do if item.Id == id then setFavorite(item, value); return true end end
        return false
    end
    function self:OpenDetails(id)
        for _, item in ipairs(self.Items) do if item.Id == id or tostring(item.Id) == tostring(id) then return openDetails(item) end end
        return false
    end
    function self:CloseDetails()
        if not detailsOverlay then return false end
        clearDetails(); return true
    end
    function self:GetDetailsOpen() return detailsOverlay ~= nil end
    function self:GetFavorites()
        local out = {}
        for _, item in ipairs(self.Items) do if itemIsFavorite(item) then out[#out + 1] = table.clone(item) end end
        return out
    end
    function self:SetEnabled(enabled)
        Base.SetEnabled(self, enabled)
        search.TextEditable = self.Enabled; sortButton.Active = self.Enabled; viewButton.Active = self.Enabled
        for _, row in ipairs(self._rowItems) do if row:IsA("GuiObject") then row.Active = self.Enabled end end
    end
    function self:Destroy()
        if self._destroyed then return end
        clearDetails()
        disconnectRows(); disconnectConnections(self._filterConnections)
        Base.Destroy(self)
    end

    updateSortText()
    self:SetItems(options.Items or {})
    return self
end

return ItemCatalog
