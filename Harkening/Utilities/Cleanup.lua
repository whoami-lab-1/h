-- Harkening UI: deterministic resource cleanup.
local Cleanup = {}
Cleanup.__index = Cleanup

local function dispose(resource, method)
	if resource == nil then return end
	local kind = typeof(resource)
	if method and type(resource) == "table" and type(resource[method]) == "function" then
		resource[method](resource)
	elseif kind == "RBXScriptConnection" then
		resource:Disconnect()
	elseif kind == "Instance" then
		resource:Destroy()
	elseif type(resource) == "function" then
		resource()
	elseif type(resource) == "thread" then
		pcall(task.cancel, resource)
	elseif type(resource) == "table" then
		if type(resource.Destroy) == "function" then resource:Destroy()
		elseif type(resource.Disconnect) == "function" then resource:Disconnect()
		elseif type(resource.Cancel) == "function" then resource:Cancel() end
	end
end

function Cleanup.new()
	return setmetatable({ _items = {}, _destroyed = false }, Cleanup)
end

function Cleanup:Add(resource, method)
	if resource == nil then return nil end
	if self._destroyed then
		dispose(resource, method)
		return resource
	end
	table.insert(self._items, { Resource = resource, Method = method })
	return resource
end

function Cleanup:Remove(resource, cleanupNow)
	for index = #self._items, 1, -1 do
		local item = self._items[index]
		if item.Resource == resource then
			table.remove(self._items, index)
			if cleanupNow then dispose(item.Resource, item.Method) end
			return true
		end
	end
	return false
end

function Cleanup:Clean()
	if self._destroyed then return end
	for index = #self._items, 1, -1 do
		local item = self._items[index]
		local ok, err = pcall(dispose, item.Resource, item.Method)
		if not ok then warn("[Harkening] Error durante cleanup: " .. tostring(err)) end
		self._items[index] = nil
	end
end

function Cleanup:Destroy()
	if self._destroyed then return end
	self:Clean()
	self._destroyed = true
end

Cleanup.Dispose = dispose
return Cleanup
