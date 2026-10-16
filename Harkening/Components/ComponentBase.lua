local Cleanup = require("../Utilities/Cleanup")
local Base = {}
Base.__index = Base

function Base.Initialize(self, context, root)
	self.Context = context
	self.Frame = root
	self.Enabled = true
	self.Visible = true
	self._cleanup = Cleanup.new()
	self._destroyed = false
	return self
end

function Base:Connect(signal, callback)
	return self._cleanup:Add(signal:Connect(callback))
end

function Base:FocusWindow()
	local window = self.Context and self.Context.Window
	if window and not window._destroyed then window:Focus() end
end

function Base:SetVisible(visible)
	if self._destroyed then return end
	self.Visible = visible == true
	if not self.Visible and self.Context and self.Context.Input then self.Context.Input:CancelOwner(self) end
	if self.Frame and self.Frame.Parent then self.Frame.Visible = self.Visible end
end

function Base:SetEnabled(enabled)
	if self._destroyed then return end
	self.Enabled = enabled == true
	if self.Frame and self.Frame.Parent then
		self.Frame.Active = self.Enabled
		self.Frame.Selectable = self.Enabled
	end
end

function Base:SetText(text)
	assert(type(text) == "string", "SetText espera una cadena")
	local target = self.TextObject or self.TitleObject
	assert(target and target:IsA("TextLabel"), "Este componente no expone SetText")
	target.Text = text
end

function Base:Destroy()
	if self._destroyed then return end
	self._destroyed = true
	if self.Context and self.Context.Input then self.Context.Input:CancelOwner(self) end
	if self._children then
		for index = #self._children, 1, -1 do
			local child = self._children[index]
			if child and type(child.Destroy) == "function" then pcall(child.Destroy, child) end
		end
		table.clear(self._children)
	end
	if self.Frame and self.Context and self.Context.Tweens and self.Context.Tweens.Cancel then
		self.Context.Tweens:Cancel(self.Frame)
		for _, descendant in ipairs(self.Frame:GetDescendants()) do self.Context.Tweens:Cancel(descendant) end
	end
	self._cleanup:Destroy()
	if self.Context and self.Context.Lifecycle then self.Context.Lifecycle:Remove(self) end
	if self.Frame and self.Frame.Parent then self.Frame:Destroy() end
	self.Frame = nil
	if self._onDestroy then
		local callback = self._onDestroy; self._onDestroy = nil
		local ok, err = pcall(callback, self)
		if not ok then warn("[Harkening] Error en OnDestroy: " .. tostring(err)) end
	end
end

return Base
