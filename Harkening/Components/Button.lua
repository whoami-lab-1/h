local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local IconRenderer = require("../Utilities/IconRenderer")
local Validation = require("../Utilities/Validation")
local Button = {}
Button.__index = Button
setmetatable(Button, { __index = Base })

function Button.new(context, parent, options)
	options = Validation.Options(options, "Button options")
	local theme = context.Theme
	local title = Validation.String(options.Title, "Title", "Button", true)
	local description = Validation.String(options.Description, "Description", "", true)
	local callback = Validation.Callback(options.Callback)
	local variant = options.Variant or "Secondary"
    local variants = { Primary = theme:Get("Accent"), Secondary = theme:Get("SurfaceRaised"), Destructive = theme:Get("Danger"), Success = theme:Get("Success") }
    local originalColor = variants[variant] or theme:Get("SurfaceRaised")
    local height = options.Height or (description ~= "" and 62 or (options.IconOnly and 40 or 42))
	local frame = Builder.Create("Frame", {
		Name = options.Name or "Button", BackgroundColor3 = originalColor, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, options.Height or height),
	}, parent)
	Builder.Corner(frame, theme:Get("CornerRadius"))
    local stroke = Builder.Stroke(frame, variant == "Primary" and theme:Get("Accent") or theme:Get("BorderSubtle"), variant == "Primary" and 0.25 or 0.34, 1)
	local textButton = Builder.Create("TextButton", {
		Name = "Action", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
		Text = "", AutoButtonColor = false, Active = options.Enabled ~= false, Selectable = options.Enabled ~= false,
	}, frame)
    local iconRight = options.IconPosition == "Right"
	local left = options.Icon and not iconRight and 43 or 12
    local rightInset = options.Icon and iconRight and 42 or 12
    local iconObject
	if options.Icon then
        local iconSize = options.IconSize or 18
        local holder = Builder.Create("Frame", { Name = "IconHolder", AnchorPoint = Vector2.new(iconRight and 1 or 0, 0.5),
            Position = iconRight and UDim2.new(1, -10, 0.5, 0) or UDim2.new(0, 9, 0.5, 0),
            Size = UDim2.fromOffset(iconSize + 8, iconSize + 8), BackgroundColor3 = variant == "Primary" and theme:Get("AccentText") or theme:Get("AccentSoft"),
            BackgroundTransparency = variant == "Primary" and 0.72 or 0.06, BorderSizePixel = 0 }, frame)
        Builder.Corner(holder, 7)
        iconObject = IconRenderer.Create(holder, options.Icon, { Name = "Icon", Size = UDim2.fromOffset(iconSize, iconSize),
            Position = UDim2.new(0.5, -iconSize / 2, 0.5, -iconSize / 2),
            Color = (variant == "Primary" or variant == "Destructive" or variant == "Success") and theme:Get("AccentText") or theme:Get("Accent"),
            Fallback = "sparkles", TextSize = iconSize, ZIndex = frame.ZIndex + 1 })
    end
	local titleLabel = Builder.Label(frame, "Title", title,
        UDim2.new(1, -(left + rightInset + 4), 0, description ~= "" and 22 or 24), UDim2.new(0, left, 0, description ~= "" and 6 or 0),
        (variant == "Primary" or variant == "Destructive" or variant == "Success") and theme:Get("AccentText") or theme:Get("Text"), 13, true)
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    if options.IconOnly then titleLabel.Visible = false; if iconObject and iconObject.Parent then iconObject.Parent.AnchorPoint = Vector2.new(0.5, 0.5); iconObject.Parent.Position = UDim2.fromScale(0.5, 0.5) end end
	local descLabel
	if description ~= "" then
		descLabel = Builder.Label(frame, "Description", description,
			UDim2.new(1, -(left + rightInset + 4), 0, 20), UDim2.new(0, left, 0, 32), theme:Get("MutedText"), 10, false)
	end
	local self = setmetatable({}, Button)
	Base.Initialize(self, context, frame)
	self.TextObject = titleLabel
	self.DescriptionObject = descLabel
	self._button = textButton
	self._callback = callback
	self._originalColor = frame.BackgroundColor3
    self._stroke = stroke
    self._variant = variant; self._loading = options.Loading == true; self._originalTitle = title
	self.Enabled = options.Enabled ~= false
	textButton.Active = self.Enabled
	textButton.Selectable = self.Enabled
	self:Connect(textButton.MouseEnter, function()
		if self.Enabled then
            local targetColor = variant == "Primary" and self._originalColor:Lerp(theme:Get("Text"), 0.08) or theme:Get("SurfaceHover")
            context.Tweens:To(frame, { BackgroundColor3 = targetColor }, { Time = 0.12 })
            context.Tweens:To(stroke, { Color = theme:Get("Accent"), Transparency = 0.16 }, { Time = 0.12 })
        end
	end)
	self:Connect(textButton.MouseLeave, function()
		if self.Enabled then
            context.Tweens:To(frame, { BackgroundColor3 = self._originalColor }, { Time = 0.12 })
            context.Tweens:To(stroke, { Color = variant == "Primary" and theme:Get("Accent") or theme:Get("BorderSubtle"), Transparency = variant == "Primary" and 0.25 or 0.34 }, { Time = 0.12 })
        end
	end)
	self:Connect(textButton.Activated, function()
		if not self.Enabled or self._loading or self._destroyed then return end
		self:FocusWindow()
		context.Tweens:To(frame, { BackgroundColor3 = variant == "Primary" and theme:Get("AccentSecondary") or theme:Get("AccentSoft") }, { Time = 0.07 })
		task.delay(0.09, function()
			if not self._destroyed and self.Enabled and frame.Parent then
				context.Tweens:To(frame, { BackgroundColor3 = self._originalColor }, { Time = 0.12 })
			end
		end)
		if self._callback then task.spawn(self._callback, self) end
	end)
    if self._loading then self:SetLoading(true) end
	return self
end

function Button:SetText(text)
	if self._destroyed then return end
	self.TextObject.Text = Validation.String(text, "text", nil, true)
end

function Button:SetDescription(text)
	if self._destroyed then return end
	assert(type(text) == "string", "text debe ser una cadena")
	if not self.DescriptionObject then
		self.DescriptionObject = Builder.Label(self.Frame, "Description", text, UDim2.new(1, -58, 0, 20), UDim2.new(0, 43, 0, 32), self.Context.Theme:Get("MutedText"), 10)
		self.Frame.Size = UDim2.new(1, 0, 0, 62)
	else self.DescriptionObject.Text = text end
end

function Button:SetEnabled(enabled)
	Base.SetEnabled(self, enabled)
	self._button.Active = self.Enabled
	self._button.Selectable = self.Enabled
	self._button.TextTransparency = self.Enabled and 0 or 0.35
	self.Frame.BackgroundTransparency = self.Enabled and 0 or 0.35
    if self._stroke then self._stroke.Transparency = self.Enabled and 0.34 or 0.72 end
end

function Button:SetLoading(loading, loadingText)
    if self._destroyed then return end
    self._loading = loading == true
    self._button.Active = self.Enabled and not self._loading
    self._button.Selectable = self.Enabled and not self._loading
    self.TextObject.Text = self._loading and tostring(loadingText or "Loading…") or self._originalTitle
    self.Frame.BackgroundTransparency = (not self.Enabled or self._loading) and 0.25 or 0
end
function Button:IsLoading() return self._loading end
function Button:SetVariant(variant)
    if self._destroyed then return end
    local theme = self.Context.Theme
    local variants = { Primary = theme:Get("Accent"), Secondary = theme:Get("SurfaceRaised"), Destructive = theme:Get("Danger"), Success = theme:Get("Success") }
    self._variant = variant; self._originalColor = variants[variant] or theme:Get("SurfaceRaised"); self.Frame.BackgroundColor3 = self._originalColor
    if self._stroke then self._stroke.Color = variant == "Primary" and theme:Get("Accent") or theme:Get("BorderSubtle") end
    self.TextObject.TextColor3 = (variant == "Primary" or variant == "Destructive" or variant == "Success") and theme:Get("AccentText") or theme:Get("Text")
end

return Button
