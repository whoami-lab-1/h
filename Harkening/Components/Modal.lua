local Base = require("./ComponentBase")
local Builder = require("../Utilities/InstanceBuilder")
local IconRenderer = require("../Utilities/IconRenderer")

local Modal = {}
Modal.__index = Modal
setmetatable(Modal, { __index = Base })

local function runTween(context, object, properties, duration)
    if context and context.Tweens and context.Tweens.To then
        context.Tweens:To(object, properties, { Time = duration or 0.16 })
    else
        for property, value in pairs(properties) do object[property] = value end
    end
end

function Modal.new(context, options)
    options = options or {}
    assert(type(options) == "table", "Modal options debe ser una tabla")
    if options.Size ~= nil then assert(typeof(options.Size) == "UDim2", "Modal Size debe ser UDim2") end
    for _, key in ipairs({ "OnConfirm", "OnCancel" }) do
        if options[key] ~= nil then assert(type(options[key]) == "function", key .. " debe ser una función") end
    end
    for _, key in ipairs({ "Title", "Description", "ConfirmText", "CancelText" }) do
        if options[key] ~= nil then assert(type(options[key]) == "string", key .. " debe ser una cadena") end
    end

    local theme = context.Theme
    local overlay = Builder.Create("Frame", {
        Name = options.Name or "ModalOverlay", Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0, 0),
        BackgroundColor3 = Color3.fromRGB(4, 6, 10), BackgroundTransparency = 1,
        BorderSizePixel = 0, Active = options.BlockInput ~= false, Visible = false, ZIndex = 10000,
    }, context.Gui)
    local backdrop = Builder.Create("TextButton", {
        Name = "Backdrop", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
        Text = "", AutoButtonColor = false, ZIndex = 10000, Active = true,
    }, overlay)
    local dialogSize = options.Size or UDim2.fromOffset(390, options.Description and 222 or 184)
    local dialogShadow = Builder.Create("ImageLabel", { Name = "DialogShadow", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(dialogSize.X.Scale, dialogSize.X.Offset + 42, dialogSize.Y.Scale, dialogSize.Y.Offset + 42),
        BackgroundTransparency = 1, BorderSizePixel = 0, Image = "rbxassetid://6015897843",
        ImageColor3 = theme:Get("Shadow") or Color3.new(0, 0, 0), ImageTransparency = 0.52,
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450), ZIndex = 10000,
    }, overlay)
    local dialog = Builder.Create("Frame", {
        Name = "Dialog", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = dialogSize,
        BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0, ZIndex = 10001,
    }, overlay)
    Builder.Corner(dialog, theme:Get("CornerRadius") + 2)
    Builder.Stroke(dialog, theme:Get("Border"), 0.12, 1)
    Builder.Create("UIGradient", { Rotation = 90, Color = ColorSequence.new(theme:Get("SurfaceRaised"), theme:Get("Surface")) }, dialog)

    local accent = Builder.Create("Frame", { Name = "AccentRule", Size = UDim2.new(0.18, 0, 0, 2),
        BackgroundColor3 = theme:Get("Accent"), BorderSizePixel = 0, ZIndex = 10002 }, dialog)
    Builder.Create("UIGradient", { Color = ColorSequence.new(theme:Get("Accent"), theme:Get("AccentSecondary")) }, accent)
    Builder.Padding(dialog, 18, 18, 17, 15)

    local iconBox = Builder.Create("Frame", { Name = "IconBox", Position = UDim2.new(0, 0, 0, 13),
        Size = UDim2.fromOffset(38, 38), BackgroundColor3 = options.Variant == "Destructive" and theme:Get("Danger") or theme:Get("AccentSoft"),
        BackgroundTransparency = 0.16, BorderSizePixel = 0, ZIndex = 10002 }, dialog)
    Builder.Corner(iconBox, 11)
    Builder.Stroke(iconBox, options.Variant == "Destructive" and theme:Get("Danger") or theme:Get("Accent"), 0.58, 1)
    IconRenderer.Create(iconBox, options.Icon or (options.Variant == "Destructive" and "warning" or "sparkles"), {
        Size = UDim2.fromOffset(19, 19), Position = UDim2.new(0.5, -9.5, 0.5, -9.5),
        Color = options.Variant == "Destructive" and theme:Get("Danger") or theme:Get("Accent"), TextSize = 19,
    })

    local close = Builder.Create("TextButton", { Name = "Close", AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 10), Size = UDim2.fromOffset(28, 28),
        BackgroundColor3 = theme:Get("SurfaceRaised"), BorderSizePixel = 0,
        Text = "", AutoButtonColor = false, ZIndex = 10003 }, dialog)
    Builder.Corner(close, 8); Builder.Stroke(close, theme:Get("BorderSubtle"), 0.55, 1)
    IconRenderer.Create(close, "close", { Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0.5, -7, 0.5, -7), Color = theme:Get("MutedText"), TextSize = 15 })

    local title = Builder.Label(dialog, "Title", options.Title or "Confirm action",
        UDim2.new(1, -104, 0, 25), UDim2.new(0, 50, 0, 15), theme:Get("Text"), 16, true)
    title.ZIndex = 10003; title.TextTruncate = Enum.TextTruncate.AtEnd
    local body = Builder.Label(dialog, "Description", options.Description or "Are you sure you want to continue?",
        UDim2.new(1, -2, 0, 62), UDim2.new(0, 0, 0, 61), theme:Get("MutedText"), 11)
    body.ZIndex = 10003; body.TextYAlignment = Enum.TextYAlignment.Top
    body.TextWrapped = true

    local footer = Builder.Create("Frame", { Name = "Footer", AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, ZIndex = 10002 }, dialog)
    local cancel = Builder.Create("TextButton", { Name = "Cancel", AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -98, 0, 0), Size = UDim2.fromOffset(90, 34),
        BackgroundColor3 = theme:Get("SurfaceRaised"), BorderSizePixel = 0,
        Text = options.CancelText or "Cancel", TextColor3 = theme:Get("Text"), TextSize = 11,
        Font = Enum.Font.GothamSemibold, AutoButtonColor = false, ZIndex = 10003 }, footer)
    Builder.Corner(cancel, 8); Builder.Stroke(cancel, theme:Get("BorderSubtle"), 0.4, 1)
    local confirm = Builder.Create("TextButton", { Name = "Confirm", AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0), Size = UDim2.fromOffset(90, 34),
        BackgroundColor3 = options.Variant == "Destructive" and theme:Get("Danger") or theme:Get("Accent"), BorderSizePixel = 0,
        Text = options.ConfirmText or "Confirm", TextColor3 = theme:Get("AccentText"), TextSize = 11,
        Font = Enum.Font.GothamSemibold, AutoButtonColor = false, ZIndex = 10003 }, footer)
    Builder.Corner(confirm, 8)

    local self = setmetatable({}, Modal)
    Base.Initialize(self, context, overlay)
    self.Dialog = dialog; self.Shadow = dialogShadow; self.TextObject = title; self._closing = false; self._openGeneration = 0
    self:Connect(backdrop.Activated, function()
        if options.CloseOnOverlayClick == true then
            if options.OnCancel then task.spawn(options.OnCancel, self) end
            self:Close()
        end
    end)
    self:Connect(close.Activated, function()
        if options.OnCancel then task.spawn(options.OnCancel, self) end
        self:Close()
    end)
    self:Connect(cancel.Activated, function()
        if not self.Enabled then return end
        if options.OnCancel then task.spawn(options.OnCancel, self) end
        self:Close()
    end)
    self:Connect(confirm.Activated, function()
        if not self.Enabled or self._closing then return end
        local result = true
        if options.OnConfirm then
            local ok, returned = pcall(options.OnConfirm, self)
            result = ok and returned ~= false
            if not ok then warn("[Harkening] Modal OnConfirm: " .. tostring(returned)) end
        end
        if result and options.CloseOnConfirm ~= false then self:Close() end
    end)
    for _, button in ipairs({ cancel, confirm, close }) do
        self:Connect(button.MouseEnter, function()
            if button == confirm then runTween(context, button, { BackgroundColor3 = options.Variant == "Destructive" and theme:Get("Danger") or theme:Get("AccentSecondary") }, 0.1)
            else runTween(context, button, { BackgroundColor3 = theme:Get("SurfaceHover") }, 0.1) end
        end)
        self:Connect(button.MouseLeave, function()
            if button == confirm then runTween(context, button, { BackgroundColor3 = options.Variant == "Destructive" and theme:Get("Danger") or theme:Get("Accent") }, 0.1)
            elseif button == cancel then runTween(context, button, { BackgroundColor3 = theme:Get("SurfaceRaised") }, 0.1)
            else runTween(context, button, { BackgroundColor3 = theme:Get("SurfaceRaised") }, 0.1) end
        end)
    end

    function self:Open()
        if self._destroyed then return false end
        self._closing = false; self._openGeneration += 1
        overlay.Visible = true; overlay.BackgroundTransparency = 1
        dialog.Position = UDim2.new(0.5, 0, 0.5, 10)
        dialogShadow.Position = dialog.Position
        runTween(context, overlay, { BackgroundTransparency = options.OverlayTransparency or 0.32 }, 0.18)
        runTween(context, dialog, { Position = UDim2.fromScale(0.5, 0.5) }, 0.2)
        runTween(context, dialogShadow, { Position = UDim2.fromScale(0.5, 0.5), ImageTransparency = 0.52 }, 0.2)
        return true
    end
    function self:Close()
        if self._destroyed or self._closing then return end
        self._closing = true; self._openGeneration += 1
        local generation = self._openGeneration
        runTween(context, overlay, { BackgroundTransparency = 1 }, 0.14)
        runTween(context, dialog, { Position = UDim2.new(0.5, 0, 0.5, 8) }, 0.14)
        runTween(context, dialogShadow, { Position = UDim2.new(0.5, 0, 0.5, 8), ImageTransparency = 1 }, 0.14)
        task.delay(0.16, function()
            if self._destroyed or generation ~= self._openGeneration then return end
            if options.DestroyOnClose == false then overlay.Visible = false; self._closing = false
            else self:Destroy() end
        end)
    end
    if options.Visible ~= false then self:Open() else overlay.Visible = false end
    return self
end
return Modal
