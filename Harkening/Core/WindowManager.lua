local Window = require("../Components/Window")
local WindowManager = {}
WindowManager.__index = WindowManager
function WindowManager.new(context)
	return setmetatable({ Context = context, _windows = {}, _focusOrder = {}, _counter = 0, _destroyed = false }, WindowManager)
end
function WindowManager:Create(options)
	assert(not self._destroyed, "WindowManager ya fue destruido")
	options = table.clone(options or {})
	self._counter += 1
	local id = options.Id or ("Window" .. tostring(self._counter))
	assert(type(id) == "string" and id ~= "", "Window Id debe ser una cadena no vacía")
	assert(self._windows[id] == nil, "Ya existe una ventana con Id " .. id)
	options.Id = id
	local window = Window.new(self.Context, options, self)
	window.Id = id
	self._windows[id] = window
	table.insert(self._focusOrder, window)
	if self.Context.Lifecycle then self.Context.Lifecycle:Add(window) end
	self:Focus(window)
	return window
end
function WindowManager:Get(id) return self._windows[id] end
function WindowManager:GetAll()
	local result = {}
	for _, window in ipairs(self._focusOrder) do if not window._destroyed then table.insert(result, window) end end
	return result
end
function WindowManager:Focus(window)
	if self._destroyed or not window or window._destroyed then return end
	local found
	for index, existing in ipairs(self._focusOrder) do
		if existing == window then table.remove(self._focusOrder, index); found = true; break end
	end
	if not found then return end
	table.insert(self._focusOrder, window)
	for index, existing in ipairs(self._focusOrder) do
		existing:_ApplyZIndex(10 + index * 100)
	end
end
function WindowManager:Remove(window)
	if not window then return end
	if self._windows[window.Id] == window then self._windows[window.Id] = nil end
	for index = #self._focusOrder, 1, -1 do if self._focusOrder[index] == window then table.remove(self._focusOrder, index) end end
	if self.Context.Lifecycle then self.Context.Lifecycle:Remove(window) end
	for index, existing in ipairs(self._focusOrder) do if not existing._destroyed then existing:_ApplyZIndex(10 + index * 100) end end
end
function WindowManager:Show(id)
	local window = self:Get(id); if window then window:Show() end; return window
end
function WindowManager:Hide(id)
	local window = self:Get(id); if window then window:Hide() end; return window
end
function WindowManager:Destroy(id)
	local window = self:Get(id); if window then window:Destroy() end
end
function WindowManager:DestroyAll()
	local windows = self:GetAll()
	for index = #windows, 1, -1 do windows[index]:Destroy() end
end
function WindowManager:Destroy()
	if self._destroyed then return end
	self:DestroyAll()
	self._destroyed = true
	table.clear(self._windows); table.clear(self._focusOrder)
end
return WindowManager
