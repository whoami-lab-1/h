local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local IconRenderer = require("../Utilities/IconRenderer")

local Carousel = {}
Carousel.__index = Carousel
setmetatable(Carousel, { __index = Base })

local RARITY_COLORS = {
    common = Color3.fromRGB(151, 162, 181), uncommon = Color3.fromRGB(79, 199, 132),
    rare = Color3.fromRGB(89, 165, 255), epic = Color3.fromRGB(177, 113, 255),
    legendary = Color3.fromRGB(255, 174, 83), mythic = Color3.fromRGB(255, 93, 128),
}

local function inferIcon(item)
    if item.Icon then return item.Icon end
    local name = string.lower(tostring(item.Category or "") .. " " .. tostring(item.Name or item.Title or ""))
    if name:find("pet", 1, true) or name:find("animal", 1, true) then return "paw" end
    if name:find("sword", 1, true) or name:find("weapon", 1, true) then return "sword" end
    if name:find("gem", 1, true) or name:find("crystal", 1, true) then return "gem" end
    if name:find("coin", 1, true) or name:find("gold", 1, true) then return "coins" end
    if name:find("potion", 1, true) then return "potion" end
    return "item"
end

function Carousel.new(context, parent, options)
    options = options or {}
    local theme = context.Theme
    local height = math.clamp(tonumber(options.Height) or 168, 104, 360)
    local frame = Builder.Create("Frame", { Name = options.Name or "Carousel", BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, height) }, parent)
    local title
    if options.Title then
        title = Builder.Label(frame, "Title", tostring(options.Title), UDim2.new(1, 0, 0, 21), UDim2.new(), theme:Get("Text"), 12, true)
        title.TextTruncate = Enum.TextTruncate.AtEnd
    end
    local scroll = Builder.Create("ScrollingFrame", { Name = "Items", BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, title and 25 or 0), Size = UDim2.new(1, 0, 1, title and -25 or 0),
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.X, ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme:Get("Border"), ScrollingDirection = Enum.ScrollingDirection.X }, frame)
    Builder.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Center }, scroll)
    Builder.Padding(scroll, 2, 8, 2, 5)

    local self = setmetatable({}, Carousel)
    Base.Initialize(self, context, frame)
    self.Items = {}; self.SelectedId = nil; self._rows = {}; self._connections = {}; self._onSelect = options.OnItemSelected
    local function cleanupRows()
        for _, connection in ipairs(self._connections) do if connection.Connected then connection:Disconnect() end end
        table.clear(self._connections)
        for _, row in ipairs(self._rows) do if row.Parent then row:Destroy() end end
        table.clear(self._rows)
    end
    local function render()
        cleanupRows()
        for index, item in ipairs(self.Items) do
            local selected = self.SelectedId == item.Id
            local cardHeight = title and height - 32 or height - 8
            local card = Builder.Create("TextButton", { Name = "CarouselItem", LayoutOrder = index,
                Size = UDim2.fromOffset(options.CardWidth or 166, cardHeight),
                BackgroundColor3 = selected and theme:Get("AccentSoft") or theme:Get("Surface"),
                BorderSizePixel = 0, Text = "", AutoButtonColor = false }, scroll)
            Builder.Corner(card, 10)
            Builder.Stroke(card, selected and theme:Get("Accent") or theme:Get("BorderSubtle"), selected and 0.10 or 0.28, 1)
            table.insert(self._rows, card)
            local imageHeight = math.clamp(tonumber(options.ImageHeight) or 66, 38, math.max(38, cardHeight - 60))
            local imageFrame = Builder.Create("Frame", { Name = "Artwork", Position = UDim2.new(0, 7, 0, 7),
                Size = UDim2.new(1, -14, 0, imageHeight), BackgroundColor3 = theme:Get("SurfaceRaised"),
                BorderSizePixel = 0, ClipsDescendants = true }, card)
            Builder.Corner(imageFrame, 7)
            local image = item.Image or item.Thumbnail or item.ThumbnailId or item.ImageId
            if image ~= nil and image ~= "" then
                IconRenderer.Create(imageFrame, image, { Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0, 0),
                    Color = Color3.new(1, 1, 1), Fallback = false, ScaleType = options.ImageScaleType or Enum.ScaleType.Crop })
            else
                Builder.Create("UIGradient", { Color = ColorSequence.new(theme:Get("SurfaceRaised"), theme:Get("AccentSoft")), Rotation = 18 }, imageFrame)
                IconRenderer.Create(imageFrame, inferIcon(item), { Size = UDim2.fromOffset(27, 27),
                    Position = UDim2.new(0.5, -13.5, 0.5, -13.5), Color = theme:Get("Accent"), Fallback = "item", TextSize = 27 })
            end
            local rarity = tostring(item.Rarity or item.Quality or "")
            if rarity ~= "" then
                local rarityColor = RARITY_COLORS[string.lower(rarity)] or theme:Get("Accent")
                local pillWidth = math.clamp(18 + #rarity * 5, 48, 86)
                local pill = Builder.Create("Frame", { Name = "Rarity", Position = UDim2.new(0, 6, 0, 6),
                    Size = UDim2.fromOffset(pillWidth, 17), BackgroundColor3 = rarityColor, BackgroundTransparency = 0.16, BorderSizePixel = 0 }, imageFrame)
                Builder.Corner(pill, 5)
                local pillText = Builder.Label(pill, "Text", string.upper(rarity), UDim2.new(1, -8, 1, 0), UDim2.new(0, 4, 0, 0), Color3.fromRGB(14, 18, 26), 8, true)
                pillText.TextXAlignment = Enum.TextXAlignment.Center; pillText.TextTruncate = Enum.TextTruncate.AtEnd
            end
            if item.Amount ~= nil or item.Count ~= nil then
                local amount = tostring(item.Amount or item.Count)
                local badge = Builder.Create("Frame", { Name = "Amount", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -6, 0, 6),
                    Size = UDim2.fromOffset(math.clamp(#amount * 7 + 12, 30, 56), 18), BackgroundColor3 = theme:Get("SurfaceInset"),
                    BackgroundTransparency = 0.12, BorderSizePixel = 0 }, imageFrame)
                Builder.Corner(badge, 5)
                local label = Builder.Label(badge, "Text", "×" .. amount, UDim2.fromScale(1, 1), UDim2.new(), theme:Get("Text"), 9, true)
                label.TextXAlignment = Enum.TextXAlignment.Center
            end
            local nameY = 14 + imageHeight
            local name = Builder.Label(card, "Title", tostring(item.Title or item.Name or "Item"),
                UDim2.new(1, -16, 0, 19), UDim2.new(0, 8, 0, nameY), theme:Get("Text"), 11, true)
            name.TextTruncate = Enum.TextTruncate.AtEnd
            local description = Builder.Label(card, "Description", tostring(item.Description or item.Category or ""),
                UDim2.new(1, -16, 0, 24), UDim2.new(0, 8, 0, nameY + 20), theme:Get("MutedText"), 9)
            description.TextTruncate = Enum.TextTruncate.AtEnd; description.TextYAlignment = Enum.TextYAlignment.Top
            if item.Locked == true or item.IsLocked == true then
                local locked = Builder.Create("Frame", { Name = "Locked", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -7, 1, -7),
                    Size = UDim2.fromOffset(23, 23), BackgroundColor3 = theme:Get("SurfaceInset"), BorderSizePixel = 0 }, card)
                Builder.Corner(locked, 7)
                IconRenderer.Create(locked, "lock", { Size = UDim2.fromOffset(13, 13), Position = UDim2.new(0.5, -6.5, 0.5, -6.5), Color = theme:Get("Warning"), TextSize = 13 })
            end
            table.insert(self._connections, card.MouseEnter:Connect(function()
                if self.Enabled and not selected then context.Tweens:To(card, { BackgroundColor3 = theme:Get("SurfaceHover") }, { Time = 0.10 }) end
            end))
            table.insert(self._connections, card.MouseLeave:Connect(function()
                if card.Parent and not self._destroyed and self.SelectedId ~= item.Id then context.Tweens:To(card, { BackgroundColor3 = theme:Get("Surface") }, { Time = 0.10 }) end
            end))
            table.insert(self._connections, card.Activated:Connect(function()
                if not self.Enabled or self._destroyed then return end
                self.SelectedId = item.Id; render()
                if type(self._onSelect) == "function" then task.spawn(self._onSelect, table.clone(item), self) end
            end))
        end
    end
    function self:SetItems(items)
        assert(type(items) == "table", "SetItems espera tabla")
        self.Items = {}; local seen = {}
        for index, item in ipairs(items) do
            if type(item) == "string" or type(item) == "number" then item = { Name = tostring(item) } end
            assert(type(item) == "table", "Cada item del carrusel debe ser una tabla, string o number")
            local copy = table.clone(item); copy.Id = tostring(copy.Id or copy.ID or copy.Name or copy.Title or index)
            assert(not seen[copy.Id], "Carousel contiene IDs duplicados: " .. copy.Id)
            seen[copy.Id] = true; self.Items[index] = copy
        end
        self.SelectedId = nil; render()
    end
    function self:GetItems()
        local out = {}; for index, item in ipairs(self.Items) do out[index] = table.clone(item) end; return out
    end
    function self:Select(id, fireCallback)
        for _, item in ipairs(self.Items) do
            if item.Id == tostring(id) then
                self.SelectedId = item.Id; render()
                if fireCallback == true and type(self._onSelect) == "function" then task.spawn(self._onSelect, table.clone(item), self) end
                return true
            end
        end
        return false
    end
    function self:GetSelected()
        for _, item in ipairs(self.Items) do if item.Id == self.SelectedId then return table.clone(item) end end
        return nil
    end
    function self:Destroy()
        if self._destroyed then return end
        cleanupRows(); Base.Destroy(self)
    end
    self:SetItems(options.Items or {})
    return self
end
return Carousel
