-- Shared icon resolver/renderer. Supports semantic glyphs, numeric asset IDs,
-- rbxassetid:// strings and descriptors: { Name = "heart", Color = Color3, Asset = ... }.
local Builder = require("./InstanceBuilder")
local LegacyIcons = require("./Icons")

local IconRenderer = {}

local GLYPHS = {
    home = "⌂", house = "⌂", general = "◈", grid = "▦", catalog = "▦", inventory = "▤",
    layers = "▱", layout = "▦", panel = "▤", settings = "⚙", gear = "⚙", wrench = "⌁",
    search = "⌕", filter = "▽", sort = "⇅", list = "☷", menu = "☰", sidebar = "▥", chevron = "⌄", ["chevron-down"] = "⌄",
    ["chevron-up"] = "⌃", ["chevron-right"] = "›", ["chevron-left"] = "‹", arrow = "→",
    ["arrow-left"] = "←", ["arrow-right"] = "→", close = "×", x = "×", minimize = "−",
    maximize = "□", restore = "❐", resize = "⤡", plus = "+", minus = "−", check = "✓",
    copy = "▢", edit = "✎", trash = "⌫", refresh = "↻", heart = "♥", favorite = "♥", star = "★",
    lock = "▣", unlock = "▢", shield = "⬡", sword = "⚔", weapon = "⚔", coin = "●", coins = "●",
    gem = "◆", diamond = "◇", pet = "♥", paw = "🐾", box = "▣", package = "▣", item = "◆", potion = "⚗", flask = "⚗", more = "•••",
    book = "▤", food = "◉", car = "▰", key = "⚿", backpack = "▤", equip = "✓", equipped = "✓", favoriteon = "♥", new = "✦", premium = "♛",
    info = "i", warning = "!", alert = "!", success = "✓", error = "×", terminal = "›_",
    code = "</>", bell = "♢", clock = "◷", gamepad = "⌘", play = "▶", pause = "Ⅱ", stop = "■",
    download = "↓", upload = "↑", link = "↗", folder = "▰", file = "▤", document = "▤", tag = "◇",
    hash = "#", sliders = "☷", zap = "ϟ", lightning = "ϟ", fire = "♨", crown = "♛", trophy = "♜",
    medal = "●", calendar = "▦", mail = "✉", message = "▱", help = "?", question = "?", eye = "◉",
    ["eye-off"] = "⊘", power = "⏻", server = "▤", database = "▦", activity = "⌁", globe = "◎",
    wifi = "⌁", image = "▧", palette = "◒", clipboard = "▤", bookmark = "▯", flag = "⚑", volume = "◖",
    map = "⌖", ["map-pin"] = "⌖", sun = "☼", moon = "☾", sparkles = "✦", chart = "▥",
    ["bar-chart"] = "▥", ["chart-line"] = "⌁", user = "●", users = "●", profile = "●",
}

local function cleanName(value)
    return string.lower(tostring(value)):gsub("[%s_]+", "-")
end

local function assetString(value)
    if type(value) == "number" then
        if value <= 0 or value ~= value or value == math.huge then return nil end
        return "rbxassetid://" .. tostring(math.floor(value))
    end
    if type(value) ~= "string" or value == "" then return nil end
    if value:match("^%d+$") then return "rbxassetid://" .. value end
    if value:match("^rbxassetid://%d+$") or value:match("^rbxthumb://") or value:match("^rbxasset://") or value:match("^https?://") then
        return value
    end
    return nil
end

function IconRenderer.Resolve(value, fallback)
    local color, imageColor, name
    if type(value) == "table" then
        color = value.Color or value.TextColor3
        imageColor = value.ImageColor3 or value.Tint
        name = value.Name or value.Key
        value = value.Asset or value.Image or value.Id or value.Icon or name
    end
    if value == nil or value == false or value == "" then
        if fallback == false then return nil end
        value = fallback or "item"
    end
    local legacy = type(value) == "string" and LegacyIcons[value]
    local asset = legacy or assetString(value)
    if asset then return { Kind = "Image", Value = asset, Color = color or imageColor } end
    local key = cleanName(name or value)
    if LegacyIcons[key] then return { Kind = "Image", Value = LegacyIcons[key], Color = color or imageColor } end
    local glyph = GLYPHS[key]
    if not glyph and type(value) == "string" and #value <= 4 and not value:match("^[%w%-_]+$") then glyph = value end
    if not glyph and fallback ~= false then glyph = GLYPHS[cleanName(fallback or "item")] or "◆" end
    if not glyph then return nil end
    return { Kind = "Glyph", Value = glyph, Color = color }
end

function IconRenderer.Create(parent, value, options)
    options = options or {}
    local resolved = IconRenderer.Resolve(value, options.Fallback)
    if not resolved then return nil end
    local size = options.Size or UDim2.fromOffset(18, 18)
    local color = options.Color or resolved.Color or Color3.fromRGB(210, 220, 238)
    local common = {
        Name = options.Name or "Icon",
        BackgroundTransparency = options.BackgroundTransparency == nil and 1 or options.BackgroundTransparency,
        BackgroundColor3 = options.BackgroundColor3 or Color3.new(1, 1, 1),
        Size = size,
        Position = options.Position or UDim2.new(),
        AnchorPoint = options.AnchorPoint or Vector2.new(0, 0),
        ZIndex = options.ZIndex,
    }
    if resolved.Kind == "Image" then
        common.Image = resolved.Value
        common.ImageColor3 = options.Color or resolved.Color or Color3.new(1, 1, 1)
        common.ImageTransparency = options.ImageTransparency or 0
        common.ScaleType = options.ScaleType or Enum.ScaleType.Fit
        return Builder.Create("ImageLabel", common, parent)
    end
    common.Font = options.Font or Enum.Font.GothamBold
    common.Text = resolved.Value
    common.TextColor3 = color
    common.TextSize = options.TextSize or math.max(10, math.floor(math.min(size.X.Offset, size.Y.Offset) * 0.82))
    common.TextXAlignment = options.TextXAlignment or Enum.TextXAlignment.Center
    common.TextYAlignment = options.TextYAlignment or Enum.TextYAlignment.Center
    common.TextWrapped = false
    common.RichText = false
    return Builder.Create("TextLabel", common, parent)
end

function IconRenderer.Glyph(name, fallback)
    local resolved = IconRenderer.Resolve(name, fallback)
    return resolved and resolved.Kind == "Glyph" and resolved.Value or nil
end

function IconRenderer.DefaultFor(title)
    local text = cleanName(title or "")
    if text:find("setting", 1, true) or text:find("config", 1, true) then return "settings" end
    if text:find("invent", 1, true) or text:find("item", 1, true) then return "inventory" end
    if text:find("catalog", 1, true) or text:find("shop", 1, true) then return "catalog" end
    if text:find("stat", 1, true) or text:find("metric", 1, true) then return "chart" end
    if text:find("log", 1, true) or text:find("console", 1, true) then return "terminal" end
    if text:find("security", 1, true) or text:find("protect", 1, true) then return "shield" end
    if text:find("general", 1, true) or text:find("home", 1, true) then return "home" end
    return "layers"
end

return IconRenderer
