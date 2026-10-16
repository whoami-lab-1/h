local LifecycleManager = {}
LifecycleManager.__index = LifecycleManager
function LifecycleManager.new()
	return setmetatable({ _resources = {}, _destroyed = false }, LifecycleManager)
end
function LifecycleManager:Add(resource)
	if not resource then return resource end
	if self._destroyed then
		if resource.Destroy then resource:Destroy() end
		return resource
	end
	self._resources[resource] = true
	return resource
end
function LifecycleManager:Remove(resource)
	self._resources[resource] = nil
end
function LifecycleManager:Destroy()
	if self._destroyed then return end
	self._destroyed = true
	local resources = {}
	for resource in pairs(self._resources) do table.insert(resources, resource) end
	for index = #resources, 1, -1 do
		local resource = resources[index]
		if type(resource.Destroy) == "function" then
			local ok, err = pcall(resource.Destroy, resource)
			if not ok then warn("[Harkening] No se pudo destruir recurso: " .. tostring(err)) end
		end
	end
	table.clear(self._resources)
end
return LifecycleManager
