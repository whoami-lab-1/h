local TweenManager = {}
TweenManager.__index = TweenManager

function TweenManager.new(enabled, tweenService)
	assert(tweenService, "TweenManager necesita TweenService")
	return setmetatable({ Enabled = enabled ~= false, _active = {}, _destroyed = false, _service = tweenService }, TweenManager)
end

function TweenManager:Cancel(instance)
	local state = self._active[instance]
	if not state then return end
	state.Generation += 1
	if state.Connection then state.Connection:Disconnect(); state.Connection = nil end
	if state.Tween then state.Tween:Cancel(); state.Tween = nil end
	if self._active[instance] == state then self._active[instance] = nil end
end

function TweenManager:To(instance, properties, options)
	assert(typeof(instance) == "Instance", "TweenManager:To espera una Instance")
	assert(type(properties) == "table", "properties debe ser una tabla")
	options = options or {}
	self:Cancel(instance)
	if self._destroyed then return nil end
	if not self.Enabled or options.Enabled == false then
		for key, value in pairs(properties) do instance[key] = value end
		return nil
	end
	local info = TweenInfo.new(
		math.max(0, options.Time or 0.18),
		options.EasingStyle or Enum.EasingStyle.Quad,
		options.EasingDirection or Enum.EasingDirection.Out,
		options.RepeatCount or 0,
		options.Reverses == true,
		options.DelayTime or 0
	)
	local tween = self._service:Create(instance, info, properties)
	local state = self._active[instance] or { Generation = 0 }
	state.Generation += 1
	state.Tween = tween
	state.Connection = nil
	self._active[instance] = state
	state.Connection = tween.Completed:Connect(function()
		if self._active[instance] == state and state.Tween == tween then
			if state.Connection then state.Connection:Disconnect(); state.Connection = nil end
			state.Tween = nil
			self._active[instance] = nil
		end
	end)
	tween:Play()
	return tween
end

function TweenManager:Sequence(instance, steps, options)
	assert(typeof(instance) == "Instance", "Sequence espera una Instance")
	assert(type(steps) == "table", "steps debe ser una tabla")
	options = options or {}
	self:Cancel(instance)
	local manager = self
	local controller = { Index = 0, Cancelled = false, _generation = 0, _connection = nil, _tween = nil }
	local function cancelCurrent()
		if controller._connection then controller._connection:Disconnect(); controller._connection = nil end
		if controller._tween then controller._tween:Cancel(); controller._tween = nil end
	end
	function controller:Cancel()
		if self.Cancelled then return end
		self.Cancelled = true
		self._generation += 1
		cancelCurrent()
	end
	function controller:Play()
		self:Cancel()
		self.Cancelled = false
		self.Index = 0
		self._generation += 1
		local generation = self._generation
		cancelCurrent()
		if not manager.Enabled or options.Enabled == false then
			for index, step in ipairs(steps) do
				self.Index = index
				for property, value in pairs(step.Properties or {}) do instance[property] = value end
			end
			return self
		end
		local function playNext()
			if self.Cancelled or self._generation ~= generation then return end
			self.Index += 1
			local step = steps[self.Index]
			if not step then return end
			local tween = manager:To(instance, step.Properties or {}, {
				Time = step.Time or options.Time or 0.18,
				EasingStyle = step.EasingStyle or options.EasingStyle,
				EasingDirection = step.EasingDirection or options.EasingDirection,
				Enabled = step.Enabled == nil and options.Enabled or step.Enabled,
			})
			if not tween then playNext(); return end
			self._tween = tween
			self._connection = tween.Completed:Connect(function(playbackState)
				if self._connection then self._connection:Disconnect(); self._connection = nil end
				self._tween = nil
				if playbackState == Enum.PlaybackState.Completed then playNext() end
			end)
		end
		playNext()
		return self
	end
	return controller
end

function TweenManager:Destroy()
	if self._destroyed then return end
	self._destroyed = true
	local instances = {}
	for instance in pairs(self._active) do table.insert(instances, instance) end
	for _, instance in ipairs(instances) do self:Cancel(instance) end
	table.clear(self._active)
end

return TweenManager
