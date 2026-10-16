local InputManager = {}
InputManager.__index = InputManager

function InputManager.new(cleanup, userInputService)
	assert(userInputService, "InputManager necesita UserInputService")
	local self = setmetatable({ _drag = nil, _destroyed = false, _cleanup = cleanup, _service = userInputService }, InputManager)
	self._cleanup:Add(userInputService.InputChanged:Connect(function(input)
		local drag = self._drag
		if not drag then return end
		local kind = input.UserInputType
		if (drag.PointerType == Enum.UserInputType.MouseButton1 and kind == Enum.UserInputType.MouseMovement)
			or (drag.PointerType == Enum.UserInputType.Touch and kind == Enum.UserInputType.Touch) then
			drag.OnMove(input.Position)
		end
	end))
	self._cleanup:Add(userInputService.InputEnded:Connect(function(input)
		local drag = self._drag
		if drag and input.UserInputType == drag.PointerType then
			self._drag = nil
			if drag.OnEnd then drag.OnEnd() end
		end
	end))
	return self
end

function InputManager:BeginDrag(input, onMove, onEnd, owner, scope)
	if self._destroyed or not input then return false end
	local kind = input.UserInputType
	if kind ~= Enum.UserInputType.MouseButton1 and kind ~= Enum.UserInputType.Touch then return false end
	self:EndDrag()
	self._drag = { PointerType = kind, OnMove = onMove, OnEnd = onEnd, Owner = owner, Scope = scope }
	return true
end

function InputManager:EndDrag()
	if not self._drag then return end
	local old = self._drag
	self._drag = nil
	if old.OnEnd then old.OnEnd() end
end

function InputManager:CancelOwner(owner)
	if self._drag and self._drag.Owner == owner then self:EndDrag() end
end

function InputManager:CancelScope(scope)
	if scope ~= nil and self._drag and self._drag.Scope == scope then self:EndDrag() end
end

function InputManager:Destroy()
	if self._destroyed then return end
	self:EndDrag()
	self._destroyed = true
end

return InputManager
