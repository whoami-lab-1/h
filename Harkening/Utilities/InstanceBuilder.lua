local InstanceBuilder = {}

function InstanceBuilder.Create(className, properties, parent)
	local instance = Instance.new(className)
	for property, value in pairs(properties or {}) do
		local ok, err = pcall(function() instance[property] = value end)
		if not ok then
			instance:Destroy()
			error(("No se pudo asignar %s.%s: %s"):format(className, tostring(property), tostring(err)), 2)
		end
	end
	if parent then instance.Parent = parent end
	return instance
end

function InstanceBuilder.Corner(parent, radius)
	return InstanceBuilder.Create("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, parent)
end

function InstanceBuilder.Stroke(parent, color, transparency, thickness)
	return InstanceBuilder.Create("UIStroke", {
		Color = color or Color3.fromRGB(48, 53, 64),
		Transparency = transparency or 0,
		Thickness = thickness or 1,
	}, parent)
end

function InstanceBuilder.Padding(parent, left, right, top, bottom)
	return InstanceBuilder.Create("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0), PaddingRight = UDim.new(0, right or 0),
		PaddingTop = UDim.new(0, top or 0), PaddingBottom = UDim.new(0, bottom or 0),
	}, parent)
end

function InstanceBuilder.Label(parent, name, text, size, position, color, fontSize, bold)
	return InstanceBuilder.Create("TextLabel", {
		Name = name or "Label", BackgroundTransparency = 1,
		Size = size or UDim2.new(1, 0, 0, 20), Position = position or UDim2.new(),
		Font = bold and Enum.Font.GothamSemibold or Enum.Font.Gotham,
		Text = text or "", TextColor3 = color or Color3.new(1, 1, 1),
		TextSize = fontSize or 14, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
		RichText = false,
	}, parent)
end

return InstanceBuilder
