local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local IconRenderer = require("../Utilities/IconRenderer")
local Validation = require("../Utilities/Validation")
local Dropdown = {}
Dropdown.__index = Dropdown
setmetatable(Dropdown, { __index = Base })

local function normalizeOption(option)
	if type(option) == "string" or type(option) == "number" then
		return { Value = option, Text = tostring(option) }
	end
	assert(type(option) == "table", "Cada opción debe ser string, number o tabla")
	local value = option.Value
	if value == nil then value = option.Text end
	assert(value ~= nil, "Cada opción necesita Value o Text")
	assert(type(value) == "string" or type(value) == "number" or type(value) == "boolean", "Value debe ser string, number o boolean")
	if type(value) == "number" then assert(value == value and value > -math.huge and value < math.huge, "Value numérico debe ser finito") end
	return { Value = value, Text = tostring(option.Text or value), Id = option.Id, Description = option.Description, Icon = option.Icon or option.Image, Disabled = option.Disabled == true }
end

function Dropdown.new(context, parent, options)
	options = Validation.Options(options, "Dropdown options")
	local theme = context.Theme
	local multiple = options.Multiple == true
	local callback = Validation.Callback(options.Callback)
	if options.Title ~= nil then assert(type(options.Title) == "string", "Title debe ser string") end
	if options.Placeholder ~= nil then assert(type(options.Placeholder) == "string", "Placeholder debe ser string") end
	assert(options.Options == nil or type(options.Options) == "table", "Options debe ser una tabla")
	local rowHeight = Validation.Number(options.RowHeight, "RowHeight", 36)
	local searchable = options.Searchable == true
	local maxListHeight = Validation.Number(options.MaxListHeight, "MaxListHeight", 150)
	assert(rowHeight > 0 and maxListHeight > 0, "RowHeight y MaxListHeight deben ser positivos")
	local optionValues = {}
	for _, option in ipairs(options.Options or {}) do
		local entry = normalizeOption(option)
		assert(not optionValues[entry.Value], "Opción duplicada: " .. tostring(entry.Value))
		optionValues[entry.Value] = true
	end
	local wrapper = Builder.Create("Frame", { Name = options.Name or (multiple and "MultiSelect" or "Dropdown"),
		BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, rowHeight), ClipsDescendants = true }, parent)
	local header = Builder.Create("TextButton", { Name = "Header", BackgroundColor3 = theme:Get("SurfaceRaised"), BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, rowHeight), Text = "", AutoButtonColor = false }, wrapper)
	Builder.Corner(header, theme:Get("CornerRadius"))
    local headerStroke = Builder.Stroke(header, theme:Get("BorderSubtle"), 0.32, 1)
    local searchBox
    if searchable then
        searchBox = Builder.Create("TextBox", { Name = "Search", Position = UDim2.new(0, 0, 0, rowHeight + 4),
            Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = theme:Get("Background"), BorderSizePixel = 0,
            Text = "", PlaceholderText = options.SearchPlaceholder or "Search options…", ClearTextOnFocus = false,
            Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = theme:Get("Text"), PlaceholderColor3 = theme:Get("MutedText"),
            TextXAlignment = Enum.TextXAlignment.Left, Visible = false }, wrapper)
        Builder.Corner(searchBox, 5); Builder.Padding(searchBox, 8, 6, 0, 0)
    end
	local titleIcon
    local titleX = 12
    if options.Icon then
        titleIcon = IconRenderer.Create(header, options.Icon, { Size = UDim2.fromOffset(16, 16), Position = UDim2.new(0, 10, 0.5, -8),
            Color = theme:Get("Accent"), Fallback = "filter", TextSize = 16 })
        titleX = 34
    end
    local titleLabel = Builder.Label(header, "Title", options.Title or (multiple and "Select options" or "Select an option"),
		UDim2.new(0.47, -titleX, 1, 0), UDim2.new(0, titleX, 0, 0), theme:Get("Text"), 12, true)
	local valueLabel = Builder.Label(header, "SelectedValue", "", UDim2.new(0.48, -30, 1, 0), UDim2.new(0.48, 0, 0, 0), theme:Get("MutedText"), 10)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	local arrow = IconRenderer.Create(header, "chevron-down", { Name = "Arrow", Size = UDim2.fromOffset(16, 16), Position = UDim2.new(1, -24, 0.5, -8),
        Color = theme:Get("MutedText"), Fallback = "chevron-down", TextSize = 16 })
	local optionList = Builder.Create("ScrollingFrame", { Name = "Options", BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, rowHeight + (searchable and 36 or 4)), Size = UDim2.new(1, 0, 0, 0), CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 4, Visible = false, ClipsDescendants = true }, wrapper)
	Builder.Corner(optionList, theme:Get("CornerRadius"))
    Builder.Stroke(optionList, theme:Get("BorderSubtle"), 0.28, 1)
	Builder.Padding(optionList, 4, 4, 4, 4)
	local layout = Builder.Create("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, optionList)
    local noResults = Builder.Label(optionList, "NoResults", options.NoResultsText or "No matching options", UDim2.new(1, -8, 0, 26), UDim2.new(), theme:Get("MutedText"), 10)
    noResults.TextXAlignment = Enum.TextXAlignment.Center; noResults.LayoutOrder = 0; noResults.Visible = false
	local self = setmetatable({}, Dropdown)
	Base.Initialize(self, context, wrapper)
	self.TextObject = titleLabel
	self._header, self._valueLabel, self._arrow, self._list = header, valueLabel, arrow, optionList
	self._layout, self._multiple, self._callback = layout, multiple, callback
	self._options, self._optionButtons, self._open = {}, {}, false
	self._maximumListHeight = maxListHeight
	self._rowHeight = rowHeight
    self._searchable, self._searchBox = searchable, searchBox
    self._minSelected = math.max(0, math.floor(tonumber(options.MinSelected) or 0))
    self._maxSelected = tonumber(options.MaxSelected) and math.max(0, math.floor(tonumber(options.MaxSelected))) or math.huge
    assert(self._minSelected <= self._maxSelected, "MinSelected no puede superar MaxSelected")
	self._value = multiple and {} or nil
	local refreshLayout
    self:Connect(layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        if not self._open or not refreshLayout then return end
        refreshLayout()
    end)
	local initial = options.Value
	if initial == nil then initial = options.Default end

	local function isSelected(value)
		if multiple then
			for _, entry in ipairs(self._value) do if entry == value then return true end end
			return false
		end
		return self._value == value
	end
	local function displayText(value)
		local record = self._optionButtons[value]
		return record and record.Text or tostring(value)
	end
	local function updateLabel()
		if multiple then
			if #self._value == 0 then valueLabel.Text = options.Placeholder or "None selected"
			elseif #self._value == 1 then valueLabel.Text = displayText(self._value[1])
			else valueLabel.Text = tostring(#self._value) .. " selected" end
		else
			valueLabel.Text = self._value == nil and (options.Placeholder or "Choose…") or displayText(self._value)
		end
		for value, record in pairs(self._optionButtons) do
            local selected = isSelected(value)
            if record.Label then record.Label.TextColor3 = selected and theme:Get("Accent") or (record.Disabled and theme:Get("Disabled") or theme:Get("Text")) end
            if record.Button then
                record.Button.BackgroundColor3 = selected and theme:Get("AccentSoft") or theme:Get("SurfaceRaised")
                record.Button.BackgroundTransparency = selected and 0.20 or 1
            end
            if record.Check then record.Check.Visible = selected end
		end
	end

    refreshLayout = function()
        local visibleCount = 0
        for _, record in pairs(self._optionButtons) do if record.Button.Visible then visibleCount += 1 end end
        noResults.Visible = visibleCount == 0
        local contentHeight = 0
        for _, record in pairs(self._optionButtons) do
            if record.Button.Visible then contentHeight += record.Description and 38 or 29 end
        end
        local height = visibleCount == 0 and 36 or math.min(self._maximumListHeight, contentHeight + 11)
        optionList.Size = UDim2.new(1, 0, 0, height)
        wrapper.Size = UDim2.new(1, 0, 0, rowHeight + (searchable and 36 or 4) + height)
    end
    local function applySearch()
        if not searchable or not searchBox then return end
        local query = string.lower(searchBox.Text)
        for _, record in pairs(self._optionButtons) do
            local searchableText = string.lower(table.concat({ record.Text or "", record.Description or "" }, " "))
            record.Button.Visible = query == "" or string.find(searchableText, query, 1, true) ~= nil
        end
        if self._open then refreshLayout() end
    end
    if searchable and searchBox then
        self:Connect(searchBox:GetPropertyChangedSignal("Text"), applySearch)
    end

	local function normalizedValue(value)
		local valid = {}
		for _, entry in ipairs(self._options) do if not entry.Disabled then valid[entry.Value] = true end end
		if multiple then
			assert(type(value) == "table", "MultiSelect:SetValue espera una tabla")
			local result, seen = {}, {}
			for _, item in ipairs(value) do
				assert(valid[item], "Opción no válida o deshabilitada: " .. tostring(item))
				if not seen[item] then table.insert(result, item); seen[item] = true end
			end
            assert(#result >= self._minSelected, "La selección no alcanza MinSelected")
            assert(#result <= self._maxSelected, "La selección supera MaxSelected")
			return result
		end
		assert(value == nil or valid[value], "Opción no válida: " .. tostring(value))
		return value
	end
	function self:GetValue()
		if multiple then return table.clone(self._value) end
		return self._value
	end
	function self:SetValue(value, fireCallback)
		if self._destroyed then return end
		value = normalizedValue(value)
		local changed = self._value ~= value
		if multiple then
			changed = #self._value ~= #value
			if not changed then
				for index, entry in ipairs(value) do if self._value[index] ~= entry then changed = true; break end end
			end
		end
		self._value = value
		updateLabel()
		if changed and fireCallback == true and self._callback then task.spawn(self._callback, self:GetValue(), self) end
	end
	function self:Get() return self:GetValue() end
	function self:Set(value, fireCallback) return self:SetValue(value, fireCallback) end
    function self:SelectAll(fireCallback)
        assert(self._multiple, "SelectAll solo está disponible en MultiSelect")
        local values = {}
        for _, entry in ipairs(self._options) do if not entry.Disabled and #values < self._maxSelected then table.insert(values, entry.Value) end end
        self:SetValue(values, fireCallback == true)
    end
    function self:ClearSelection(fireCallback)
        assert(self._multiple, "ClearSelection solo está disponible en MultiSelect")
        if self._minSelected > 0 then return false end
        self:SetValue({}, fireCallback == true); return true
    end
    function self:IsOpen() return self._open end
	function self:Close()
		if self._destroyed or not self._open then return end
		self._open = false
		optionList.Visible = false
		optionList.Size = UDim2.new(1, 0, 0, 0)
        if searchBox then searchBox.Visible = false end
		wrapper.Size = UDim2.new(1, 0, 0, rowHeight)
		context.Tweens:To(arrow, { Rotation = 0 }, { Time = 0.12 })
	end
	function self:Open()
		if self._destroyed then return end
		if not self.Enabled or self._open then return end
		self._open = true
        if searchBox then searchBox.Visible = true end
        optionList.Visible = true
        applySearch()
        refreshLayout()
		context.Tweens:To(arrow, { Rotation = 180 }, { Time = 0.12 })
	end
	function self:ToggleOpen()
		if self._destroyed or not self.Enabled then return end
		if self._open then self:Close() else self:Open() end
	end
	function self:ClearOptions()
		if self._destroyed then return end
		for _, record in pairs(self._optionButtons) do
			if record.Connection then record.Connection:Disconnect() end
			if record.Button.Parent then record.Button:Destroy() end
			self._cleanup:Remove(record.Connection, false)
		end
		table.clear(self._optionButtons)
		table.clear(self._options)
		self._value = multiple and {} or nil
		self:Close()
		updateLabel()
	end
	function self:AddOption(option)
		assert(not self._destroyed, "Dropdown destruido")
		local entry = normalizeOption(option)
		for _, existing in ipairs(self._options) do assert(existing.Value ~= entry.Value, "Opción duplicada: " .. tostring(entry.Value)) end
		table.insert(self._options, entry)
		local button = Builder.Create("TextButton", { Name = "Option", Size = UDim2.new(1, 0, 0, entry.Description and 38 or 29),
			BackgroundColor3 = theme:Get("SurfaceRaised"), BackgroundTransparency = 1, AutoButtonColor = false, Text = "",
			Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
			TextColor3 = entry.Disabled and theme:Get("Disabled") or theme:Get("Text"), LayoutOrder = #self._options, Active = not entry.Disabled,
            TextTransparency = entry.Disabled and 0.35 or 0 }, optionList)
        Builder.Corner(button, 7)
        local textX = 9
        if entry.Icon then
            IconRenderer.Create(button, entry.Icon, { Size = UDim2.fromOffset(15, 15), Position = UDim2.new(0, 8, 0, entry.Description and 6 or 7),
                Color = entry.Disabled and theme:Get("Disabled") or theme:Get("Accent"), Fallback = "circle", TextSize = 14 })
            textX = 31
        end
        local optionLabel = Builder.Label(button, "OptionText", entry.Text, UDim2.new(1, -(textX + 34), 0, entry.Description and 18 or 29),
            UDim2.new(0, textX, 0, entry.Description and 1 or 0), theme:Get("Text"), 11, true)
        optionLabel.TextTruncate = Enum.TextTruncate.AtEnd
        local optionDescription
        if entry.Description then
            optionDescription = Builder.Label(button, "OptionDescription", tostring(entry.Description), UDim2.new(1, -(textX + 34), 0, 15),
                UDim2.new(0, textX, 0, 18), theme:Get("MutedText"), 9, false)
            optionDescription.TextTruncate = Enum.TextTruncate.AtEnd
        end
        local check = IconRenderer.Create(button, "check", { Size = UDim2.fromOffset(14, 14), Position = UDim2.new(1, -22, 0.5, -7),
            Color = theme:Get("Accent"), Fallback = "check", TextSize = 14 })
        check.Visible = false
        local connection = button.Activated:Connect(function()
			if not self.Enabled then return end
			self:FocusWindow()
			if entry.Disabled then return end
            if multiple then
				local current = table.clone(self._value)
				local found
				for index, value in ipairs(current) do if value == entry.Value then table.remove(current, index); found = true; break end end
                if found and #current < self._minSelected then return end
                if not found and #current >= self._maxSelected then return end
				if not found then table.insert(current, entry.Value) end
				self:SetValue(current, true)
			else
				self:SetValue(entry.Value, true)
				self:Close()
			end
		end)
        button.MouseEnter:Connect(function()
            if not entry.Disabled and not self._destroyed then context.Tweens:To(button, { BackgroundTransparency = 0.12 }, { Time = 0.1 }) end
        end)
        button.MouseLeave:Connect(function()
            if not entry.Disabled and not self._destroyed then context.Tweens:To(button, { BackgroundTransparency = 1 }, { Time = 0.1 }) end
        end)
		self._cleanup:Add(connection)
		self._optionButtons[entry.Value] = { Button = button, Connection = connection, Text = entry.Text, Label = optionLabel, Description = optionDescription, Check = check, Disabled = entry.Disabled }
        applySearch()
		updateLabel()
		if context.Window and context.Window._ApplyZIndex then context.Window:_ApplyZIndex() end
	end
	function self:SetOptions(newOptions)
		assert(not self._destroyed, "Dropdown destruido")
		assert(type(newOptions) == "table", "SetOptions espera una tabla")
		self:ClearOptions()
		for _, entry in ipairs(newOptions) do self:AddOption(entry) end
		updateLabel()
	end
	function self:RemoveOption(value)
		if self._destroyed then return false end
		local record = self._optionButtons[value]
		if not record then return false end
		if record.Connection then record.Connection:Disconnect(); self._cleanup:Remove(record.Connection, false) end
		if record.Button.Parent then record.Button:Destroy() end
		self._optionButtons[value] = nil
		for index, entry in ipairs(self._options) do if entry.Value == value then table.remove(self._options, index); break end end
		if multiple then
			local kept = {}
			for _, selected in ipairs(self._value) do if selected ~= value then table.insert(kept, selected) end end
			self._value = kept
		elseif self._value == value then self._value = nil end
		updateLabel()
		return true
	end
	self:Connect(header.Activated, function() self:FocusWindow(); self:ToggleOpen() end)
	self:Connect(header.MouseEnter, function()
        if self.Enabled then context.Tweens:To(header, { BackgroundColor3 = theme:Get("SurfaceHover") }, { Time = 0.1 }); context.Tweens:To(headerStroke, { Color = theme:Get("Accent"), Transparency = 0.12 }, { Time = 0.1 }) end
    end)
	self:Connect(header.MouseLeave, function()
        if self.Enabled then context.Tweens:To(header, { BackgroundColor3 = theme:Get("SurfaceRaised") }, { Time = 0.1 }); context.Tweens:To(headerStroke, { Color = theme:Get("BorderSubtle"), Transparency = 0.32 }, { Time = 0.1 }) end
    end)
	function self:SetEnabled(enabled)
		if self._destroyed then return end
		Base.SetEnabled(self, enabled)
		header.Active = self.Enabled
		header.Selectable = self.Enabled
        if searchBox then searchBox.TextEditable = self.Enabled; searchBox.Active = self.Enabled end
		header.BackgroundTransparency = self.Enabled and 0 or 0.35
		if not self.Enabled then self:Close() end
	end
	for _, option in ipairs(options.Options or {}) do self:AddOption(option) end
    if initial == nil and multiple and self._minSelected > 0 then
        initial = {}
        for _, entry in ipairs(self._options) do
            if not entry.Disabled and #initial < self._minSelected then table.insert(initial, entry.Value) end
        end
    end
	if initial ~= nil then
		local ok, err = pcall(function() self:SetValue(initial, false) end)
		if not ok then self:Destroy(); error(err, 2) end
	end
	self:SetEnabled(options.Enabled ~= false)
	return self
end

return Dropdown
