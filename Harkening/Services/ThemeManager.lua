local Defaults = require("../Utilities/Defaults")
local ThemeManager = {}
ThemeManager.__index = ThemeManager

function ThemeManager.new(overrides)
	return setmetatable({ _theme = Defaults.Merge(Defaults.Theme, overrides), _listeners = {} }, ThemeManager)
end

function ThemeManager:Get(key)
	local current = self._theme
	for segment in string.gmatch(tostring(key), "[^%.]+") do
		if type(current) ~= "table" then return nil end
		current = current[segment]
	end
	return current
end

function ThemeManager:GetAll()
	return Defaults.Clone(self._theme)
end

function ThemeManager:SetTheme(theme)
	assert(type(theme) == "table", "SetTheme espera una tabla")
	self._theme = Defaults.Merge(self._theme, theme)
	for callback in pairs(self._listeners) do
		task.spawn(callback, self:GetAll())
	end
end

function ThemeManager:Subscribe(callback)
	assert(type(callback) == "function", "callback debe ser una función")
	self._listeners[callback] = true
	local disconnected = false
	return {
		Disconnect = function()
			if disconnected then return end
			disconnected = true
			self._listeners[callback] = nil
		end,
	}
end

function ThemeManager:Destroy()
	table.clear(self._listeners)
end

return ThemeManager
