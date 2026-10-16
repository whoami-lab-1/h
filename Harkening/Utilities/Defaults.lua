-- Defaults are pure data/helpers; they do not validate or create Instances.
local Defaults = {}

local function clone(value)
	if type(value) ~= "table" then return value end
	local result = {}
	for key, child in pairs(value) do result[key] = clone(child) end
	return result
end

function Defaults.Merge(defaults, supplied)
	assert(type(defaults) == "table", "Defaults.Merge: defaults debe ser una tabla")
	if supplied ~= nil then assert(type(supplied) == "table", "Defaults.Merge: options debe ser una tabla") end
	supplied = supplied or {}
	local result = {}
	for key, defaultValue in pairs(defaults) do
		local suppliedValue = supplied[key]
		if type(defaultValue) == "table" and (suppliedValue == nil or type(suppliedValue) == "table") then
			result[key] = Defaults.Merge(defaultValue, suppliedValue)
		elseif suppliedValue ~= nil then
			-- No usar `suppliedValue or defaultValue`: eso destruye false y otros valores falsy.
			result[key] = clone(suppliedValue)
		else
			result[key] = clone(defaultValue)
		end
	end
	-- Preserve extension keys so themes/components can add their own options.
	for key, suppliedValue in pairs(supplied) do
		if defaults[key] == nil then result[key] = clone(suppliedValue) end
	end
	return result
end

function Defaults.Clone(value)
	return clone(value)
end

Defaults.Framework = {
	Name = "Harkening UI",
	Parent = nil,
	ResetOnSpawn = false,
	DisplayOrder = 50,
	Theme = {},
	Animation = true,
	Debug = false,
    Watermark = {
        Enabled = true, Title = "HARKENING UI", ShowLogo = true, ShowGameName = true,
        ShowGameIcon = true, ShowFPS = true, ShowClock = false, ShowStatus = true,
        Position = "TopRight", Style = "Compact", Status = "RUNNING", BackgroundTransparency = 0.12, Width = 300,
    },
}

Defaults.Window = {
	Id = nil,
	Title = "Harkening UI",
	Description = "",
	Icon = nil,
	Size = UDim2.fromOffset(780, 520),
	Position = UDim2.fromScale(0.5, 0.5),
	MinSize = Vector2.new(420, 300),
	MaxSize = Vector2.new(1400, 960),
	AdaptiveSize = true,
	Draggable = true,
	Resizable = true,
	Minimizable = true,
	Maximizable = true,
	Closable = true,
	CloseBehavior = "Hide", -- Hide | Destroy
	Animation = true,
	SidebarWidth = 168,
}

Defaults.Theme = {
	-- Refined charcoal surfaces with restrained blue/violet accents.
	Background = Color3.fromRGB(12, 14, 19),
	Surface = Color3.fromRGB(17, 20, 27),
	SurfaceRaised = Color3.fromRGB(24, 29, 39),
	SurfaceHover = Color3.fromRGB(31, 38, 51),
	SurfaceInset = Color3.fromRGB(9, 11, 16),
	SurfaceSelected = Color3.fromRGB(28, 39, 64),
	Border = Color3.fromRGB(47, 56, 73),
	BorderSubtle = Color3.fromRGB(34, 41, 54),
	BorderFocus = Color3.fromRGB(190, 108, 255),
	Text = Color3.fromRGB(241, 244, 250),
	MutedText = Color3.fromRGB(145, 156, 176),
	Accent = Color3.fromRGB(190, 108, 255),
	AccentSecondary = Color3.fromRGB(255, 91, 193),
	AccentSoft = Color3.fromRGB(43, 28, 61),
	AccentText = Color3.fromRGB(250, 252, 255),
	Danger = Color3.fromRGB(238, 88, 108),
    Warning = Color3.fromRGB(238, 180, 79),
	Success = Color3.fromRGB(74, 195, 139),
	Info = Color3.fromRGB(91, 169, 247),
	Disabled = Color3.fromRGB(88, 97, 113),
	Shadow = Color3.fromRGB(0, 0, 0),
	CornerRadius = 11,
}

return Defaults
