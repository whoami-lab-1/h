local Builder = require("../Utilities/InstanceBuilder")
local Defaults = require("../Utilities/Defaults")
local Cleanup = require("../Utilities/Cleanup")
local Validation = require("../Utilities/Validation")
local IconRenderer = require("../Utilities/IconRenderer")
local Tab = require("./Tab")

local Window = {}
Window.__index = Window

local HEADER_HEIGHT = 58

local function safeSize(value, fallback)
    return typeof(value) == "UDim2" and value or fallback
end

function Window.new(baseContext, options, manager)
    options = Defaults.Merge(Defaults.Window, Validation.Options(options, "Window options"))
    options.Title = Validation.String(options.Title, "Title", "Harkening UI", true)
    options.Description = Validation.String(options.Description, "Description", "", true)
    assert(typeof(options.Size) == "UDim2", "Size debe ser UDim2")
    assert(typeof(options.Position) == "UDim2", "Position debe ser UDim2")
    assert(typeof(options.MinSize) == "Vector2" and typeof(options.MaxSize) == "Vector2", "MinSize y MaxSize deben ser Vector2")
    local function finite(value) return type(value) == "number" and value == value and value > -math.huge and value < math.huge end
    assert(finite(options.MinSize.X) and finite(options.MinSize.Y) and options.MinSize.X >= 1 and options.MinSize.Y >= 1,
        "MinSize debe contener dimensiones positivas y finitas")
    assert(finite(options.MaxSize.X) and finite(options.MaxSize.Y) and options.MaxSize.X >= options.MinSize.X and options.MaxSize.Y >= options.MinSize.Y,
        "MaxSize debe ser finito y no puede ser menor que MinSize")
    for _, key in ipairs({ "Animation", "AdaptiveSize", "Draggable", "Resizable", "Minimizable", "Maximizable", "Closable" }) do
        assert(type(options[key]) == "boolean", key .. " debe ser booleano")
    end
    if options.SidebarWidth ~= nil then assert(finite(options.SidebarWidth) and options.SidebarWidth >= 0, "SidebarWidth debe ser un número finito >= 0") end
    assert(options.CloseBehavior == "Hide" or options.CloseBehavior == "Destroy", "CloseBehavior debe ser Hide o Destroy")

    local context = table.clone(baseContext)
    context.Window = nil
    local theme = context.Theme
    local workspaceService = context.Services.Workspace
    local screenSize = options.Size or UDim2.fromOffset(780, 520)
    -- Keep the shadow as a sibling so ClipsDescendants on the rounded window cannot cut it off.
    local shadow = Builder.Create("ImageLabel", {
        Name = (options.Name or "HarkeningWindow") .. "_Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5), Position = options.Position,
        Size = UDim2.new(screenSize.X.Scale, screenSize.X.Offset + 46, screenSize.Y.Scale, screenSize.Y.Offset + 46),
        BackgroundTransparency = 1, BorderSizePixel = 0, Image = "rbxassetid://6015897843",
        ImageColor3 = theme:Get("Shadow") or Color3.new(0, 0, 0), ImageTransparency = 0.48,
        ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 9, Visible = options.Visible ~= false,
    }, context.Gui)
    local root = Builder.Create("Frame", {
        Name = options.Name or "HarkeningWindow", AnchorPoint = Vector2.new(0.5, 0.5),
        Position = options.Position, Size = safeSize(screenSize, UDim2.fromOffset(780, 520)),
        BackgroundColor3 = theme:Get("Background"), BorderSizePixel = 0, ClipsDescendants = true,
        Active = true, Visible = options.Visible ~= false, ZIndex = 10,
    }, context.Gui)
    Builder.Corner(root, theme:Get("CornerRadius"))
    local outerStroke = Builder.Stroke(root, theme:Get("Border"), 0.50, 1)
    Builder.Create("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme:Get("Surface")),
            ColorSequenceKeypoint.new(0.48, theme:Get("Background")),
            ColorSequenceKeypoint.new(1, theme:Get("SurfaceInset")),
        }),
    }, root)

    local sizeConstraint = Builder.Create("UISizeConstraint", {
        MinSize = options.MinSize, MaxSize = options.MaxSize,
    }, root)

    -- Header: compact brand mark, title hierarchy, and actual icon controls.
    local topbar = Builder.Create("Frame", {
        Name = "Topbar", Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
        BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0, ZIndex = 11,
    }, root)
    Builder.Corner(topbar, theme:Get("CornerRadius"))
    Builder.Create("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new(theme:Get("SurfaceRaised"), theme:Get("Surface")),
    }, topbar)
    -- Flatten only the lower half so the top corners stay rounded while the header
    -- joins the sidebar/content with a clean horizontal edge.
    Builder.Create("Frame", {
        Name = "TopbarLowerFill", Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0, ZIndex = 11,
    }, topbar)
    local headerLine = Builder.Create("Frame", {
        Name = "HeaderDivider", Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = theme:Get("BorderSubtle"), BackgroundTransparency = 0.16, BorderSizePixel = 0, ZIndex = 12,
    }, topbar)
    local accentLine = Builder.Create("Frame", {
        Name = "AccentLine", Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0.13, 0, 0, 2),
        BackgroundColor3 = theme:Get("Accent"), BorderSizePixel = 0, ZIndex = 13,
    }, topbar)
    Builder.Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, theme:Get("Accent")),
            ColorSequenceKeypoint.new(1, theme:Get("AccentSecondary")),
        }),
    }, accentLine)

    local brandMark = Builder.Create("Frame", {
        Name = "BrandMark", Position = UDim2.new(0, 15, 0.5, -16), Size = UDim2.fromOffset(32, 32),
        BackgroundColor3 = theme:Get("AccentSoft"), BorderSizePixel = 0, ZIndex = 12,
    }, topbar)
    Builder.Corner(brandMark, 9)
    Builder.Stroke(brandMark, theme:Get("Accent"), 0.68, 1)
    local brandIcon = IconRenderer.Create(brandMark, options.Icon or "sparkles", {
        Name = "BrandIcon", Size = UDim2.fromOffset(18, 18), Position = UDim2.new(0.5, -9, 0.5, -9),
        Color = theme:Get("Accent"), Fallback = "H", TextSize = 18, ZIndex = 13,
    })
    local titleX = 58
    local controls = {}
    local function headerButton(name, icon, index, color, background)
        local button = Builder.Create("TextButton", {
            Name = name, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12 - (index * 36), 0.5, 0),
            Size = UDim2.fromOffset(28, 28), BackgroundColor3 = background or theme:Get("SurfaceRaised"),
            BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 13, Selectable = true,
        }, topbar)
        Builder.Corner(button, 8)
        local stroke = Builder.Stroke(button, theme:Get("BorderSubtle"), 0.48, 1)
        local baseIconColor = color or theme:Get("MutedText")
        local iconObject = IconRenderer.Create(button, icon, { Name = "Icon", Size = UDim2.fromOffset(14, 14), Position = UDim2.new(0.5, -7, 0.5, -7),
            Color = baseIconColor, Fallback = icon, TextSize = 15, ZIndex = 14 })
        button.MouseEnter:Connect(function()
            if not button.Parent then return end
            context.Tweens:To(button, { BackgroundColor3 = name == "Close" and theme:Get("Danger") or theme:Get("SurfaceHover") }, { Time = 0.12 })
            context.Tweens:To(stroke, { Transparency = 0.15, Color = name == "Close" and theme:Get("Danger") or theme:Get("Accent") }, { Time = 0.12 })
            if iconObject then
                if iconObject:IsA("ImageLabel") then context.Tweens:To(iconObject, { ImageColor3 = name == "Close" and Color3.new(1, 1, 1) or theme:Get("Accent") }, { Time = 0.12 })
                else context.Tweens:To(iconObject, { TextColor3 = name == "Close" and Color3.new(1, 1, 1) or theme:Get("Accent") }, { Time = 0.12 }) end
            end
        end)
        button.MouseLeave:Connect(function()
            if not button.Parent then return end
            context.Tweens:To(button, { BackgroundColor3 = background or theme:Get("SurfaceRaised") }, { Time = 0.12 })
            context.Tweens:To(stroke, { Transparency = 0.48, Color = theme:Get("BorderSubtle") }, { Time = 0.12 })
            if iconObject then
                if iconObject:IsA("ImageLabel") then context.Tweens:To(iconObject, { ImageColor3 = baseIconColor }, { Time = 0.12 })
                else context.Tweens:To(iconObject, { TextColor3 = baseIconColor }, { Time = 0.12 }) end
            end
        end)
        table.insert(controls, button)
        return button
    end
    local controlIndex = 0
    local minimizeButton, maximizeButton, closeButton
    if options.Closable then closeButton = headerButton("Close", "close", controlIndex, theme:Get("Danger")); controlIndex += 1 end
    if options.Maximizable then maximizeButton = headerButton("Maximize", "maximize", controlIndex); controlIndex += 1 end
    if options.Minimizable then minimizeButton = headerButton("Minimize", "minimize", controlIndex); controlIndex += 1 end

    local controlWidth = controlIndex > 0 and (controlIndex * 36 + 8) or 14
    local title = Builder.Label(topbar, "Title", options.Title,
        UDim2.new(1, -(titleX + controlWidth + 12), 0, options.Description ~= "" and 23 or 30),
        UDim2.new(0, titleX, 0, options.Description ~= "" and 7 or 14), theme:Get("Text"), 15, true)
    title.ZIndex = 12
    title.TextTruncate = Enum.TextTruncate.AtEnd
    local description
    if options.Description ~= "" then
        description = Builder.Label(topbar, "Description", options.Description,
            UDim2.new(1, -(titleX + controlWidth + 12), 0, 16), UDim2.new(0, titleX, 0, 30), theme:Get("MutedText"), 10)
        description.ZIndex = 12
        description.TextTruncate = Enum.TextTruncate.AtEnd
    end

    local sidebar = Builder.Create("Frame", {
        Name = "Sidebar", Position = UDim2.new(0, 0, 0, HEADER_HEIGHT),
        Size = UDim2.new(0, options.SidebarWidth, 1, -HEADER_HEIGHT),
        BackgroundColor3 = theme:Get("Surface"), BorderSizePixel = 0, ZIndex = 11,
    }, root)
    local sidebarLine = Builder.Create("Frame", {
        Name = "SidebarDivider", AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = theme:Get("BorderSubtle"), BorderSizePixel = 0, ZIndex = 12,
    }, sidebar)
    local navLabel = Builder.Label(sidebar, "NavigationLabel", "WORKSPACE", UDim2.new(1, -28, 0, 14), UDim2.new(0, 14, 0, 14), theme:Get("MutedText"), 9, true)
    navLabel.ZIndex = 12
    local tabButtons = Builder.Create("ScrollingFrame", {
        Name = "TabButtons", BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, 38), Size = UDim2.new(1, -16, 1, -94), CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme:Get("Border"), ScrollingDirection = Enum.ScrollingDirection.Y, ZIndex = 12,
    }, sidebar)
    Builder.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 5) }, tabButtons)
    local sidebarFooter = Builder.Create("Frame", {
        Name = "SidebarFooter", AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 10, 1, -10),
        Size = UDim2.new(1, -20, 0, 34), BackgroundColor3 = theme:Get("SurfaceRaised"), BorderSizePixel = 0, ZIndex = 12,
    }, sidebar)
    Builder.Corner(sidebarFooter, 8)
    Builder.Stroke(sidebarFooter, theme:Get("BorderSubtle"), 0.62, 1)
    local statusDot = Builder.Create("Frame", { Name = "StatusDot", Position = UDim2.new(0, 10, 0.5, -3), Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = theme:Get("Success"), BorderSizePixel = 0, ZIndex = 13 }, sidebarFooter)
    Builder.Corner(statusDot, 99)
    local footerTitle = Builder.Label(sidebarFooter, "FooterTitle", "HARKENING UI", UDim2.new(1, -28, 0, 12),
        UDim2.new(0, 23, 0, 4), theme:Get("Text"), 9, true); footerTitle.ZIndex = 13
    local footerSubtitle = Builder.Label(sidebarFooter, "FooterSubtitle", "READY TO USE", UDim2.new(1, -28, 0, 11),
        UDim2.new(0, 23, 0, 17), theme:Get("MutedText"), 8, false); footerSubtitle.ZIndex = 13

    local contentHost = Builder.Create("Frame", {
        Name = "ContentHost", Position = UDim2.new(0, options.SidebarWidth, 0, HEADER_HEIGHT),
        Size = UDim2.new(1, -options.SidebarWidth, 1, -HEADER_HEIGHT),
        BackgroundColor3 = theme:Get("Background"), BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 11,
    }, root)
    local pages = Builder.Create("Frame", {
        Name = "Pages", Position = UDim2.new(), Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 12,
    }, contentHost)
    local resizeHandle
    if options.Resizable then
        resizeHandle = Builder.Create("TextButton", {
            Name = "ResizeHandle", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 0, 1, 0),
            Size = UDim2.fromOffset(24, 24), BackgroundColor3 = theme:Get("SurfaceRaised"), BackgroundTransparency = 0.25,
            BorderSizePixel = 0, Text = "", AutoButtonColor = false, ZIndex = 80,
        }, root)
        Builder.Corner(resizeHandle, 7)
        IconRenderer.Create(resizeHandle, "resize", { Size = UDim2.fromOffset(13, 13), Position = UDim2.new(0.5, -6.5, 0.5, -6.5),
            Color = theme:Get("MutedText"), Fallback = "resize", TextSize = 14, ZIndex = 81 })
    end

    local self = setmetatable({
        Id = options.Id, Options = options, Frame = root, Shadow = shadow, Context = context, Manager = manager,
        Tabs = {}, ActiveTab = nil, Visible = root.Visible, Minimized = false, Maximized = false,
        _destroyed = false, _savedSize = root.Size, _savedPosition = root.Position, _legacyTabs = {},
        TitleObject = title, DescriptionObject = description, Topbar = topbar, Sidebar = sidebar, Pages = pages,
        TabButtons = tabButtons, SizeConstraint = sizeConstraint, _cleanup = Cleanup.new(),
        _sidebarFooterTitle = footerTitle, _sidebarFooterSubtitle = footerSubtitle,
    }, Window)
    context.Window = self

    local sharedTweens = context.Tweens
    context.Tweens = {}
    function context.Tweens:To(instance, properties, tweenOptions)
        local config = table.clone(tweenOptions or {})
        if config.Enabled == nil then config.Enabled = options.Animation end
        return sharedTweens:To(instance, properties, config)
    end
    function context.Tweens:Cancel(instance) return sharedTweens:Cancel(instance) end
    function context.Tweens:Sequence(instance, steps, tweenOptions)
        local config = table.clone(tweenOptions or {})
        if config.Enabled == nil then config.Enabled = options.Animation end
        if config.Enabled == false then
            return { Play = function() for _, step in ipairs(steps) do for property, value in pairs(step.Properties or {}) do instance[property] = value end end end, Cancel = function() end }
        end
        return sharedTweens:Sequence(instance, steps, config)
    end
    self.Context = context

    local function syncShadow()
        if not shadow.Parent or not root.Parent then return end
        shadow.AnchorPoint = root.AnchorPoint
        shadow.Position = root.Position
        shadow.Size = UDim2.new(root.Size.X.Scale, root.Size.X.Offset + 46, root.Size.Y.Scale, root.Size.Y.Offset + 46)
        shadow.Visible = root.Visible
        shadow.ZIndex = math.max(1, (self._zBase or 10) - 1)
    end

    function self:_ApplyZIndex(base)
        if self._destroyed or not root.Parent then return end
        base = base or self._zBase or 10
        self._zBase = base
        root.ZIndex = base
        if shadow.Parent then shadow.ZIndex = math.max(1, base - 1) end
        local descendants = root:GetDescendants()
        local function depth(instance)
            local count, current = 0, instance
            while current and current ~= root do count += 1; current = current.Parent end
            return count
        end
        table.sort(descendants, function(a, b) return depth(a) < depth(b) end)
        for _, descendant in ipairs(descendants) do
            if descendant:IsA("GuiObject") then descendant.ZIndex = base + math.clamp(depth(descendant), 1, 50) end
        end
    end

    local function responsiveLayout()
        if self._destroyed or not root.Parent then return end
        local width = root.AbsoluteSize.X
        local configuredWidth = options.SidebarWidth or 168
        local sidebarWidth = width < 560 and math.clamp(configuredWidth, 112, 124) or math.clamp(configuredWidth, 145, 205)
        sidebar.Size = UDim2.new(0, sidebarWidth, 1, -HEADER_HEIGHT)
        contentHost.Position = UDim2.new(0, sidebarWidth, 0, HEADER_HEIGHT)
        contentHost.Size = UDim2.new(1, -sidebarWidth, 1, -HEADER_HEIGHT)
        navLabel.Visible = width >= 390
        footerSubtitle.Visible = width >= 560
        sidebarFooter.Size = UDim2.new(1, -20, 0, width < 560 and 30 or 34)
        tabButtons.Size = UDim2.new(1, -16, 1, -(width < 560 and 82 or 94))
        tabButtons.Position = UDim2.new(0, 8, 0, width < 560 and 28 or 38)
    end

    function self:Focus()
        if not self._destroyed then manager:Focus(self) end
    end
    function self:SetVisible(visible)
        if self._destroyed then return end
        self.Visible = visible == true
        root.Visible = self.Visible
        if shadow.Parent then shadow.Visible = self.Visible end
        if not self.Visible then context.Input:CancelOwner(self); context.Input:CancelScope(self) else self:Focus() end
    end
    function self:Show() self:SetVisible(true) end
    function self:Hide() self:SetVisible(false) end
    function self:SetTitle(value)
        if self._destroyed then return end
        assert(type(value) == "string", "SetTitle espera string")
        title.Text = value
    end
    function self:SetDescription(value)
        if self._destroyed then return end
        assert(type(value) == "string", "SetDescription espera string")
        if description then description.Text = value
        elseif value ~= "" then
            description = Builder.Label(topbar, "Description", value, UDim2.new(1, -200, 0, 16), UDim2.new(0, titleX, 0, 30), theme:Get("MutedText"), 10)
            description.ZIndex = 12; description.TextTruncate = Enum.TextTruncate.AtEnd
            self.DescriptionObject = description
        end
        self:_ApplyZIndex()
    end
    function self:AddTab(tabOptions)
        assert(not self._destroyed, "Ventana destruida")
        if type(tabOptions) == "string" then tabOptions = { Title = tabOptions } end
        tabOptions = tabOptions or {}
        local tab = Tab.new(self, tabOptions)
        table.insert(self.Tabs, tab)
        if not self.ActiveTab or tabOptions.Selected == true then self:ShowTab(tab) end
        self:_ApplyZIndex()
        return tab
    end
    function self:ShowTab(tabOrName)
        local selected
        for _, tab in ipairs(self.Tabs) do
            if tab == tabOrName or tab.Title == tabOrName or tab.Id == tabOrName then selected = tab; break end
        end
        if not selected then return false end
        context.Input:CancelScope(self)
        for _, tab in ipairs(self.Tabs) do
            local active = tab == selected
            if tab.SetActive then tab:SetActive(active) else
                tab.Page.Visible = active
                tab.Button.BackgroundTransparency = active and 0 or 1
                tab.TitleObject.TextColor3 = active and theme:Get("Text") or theme:Get("MutedText")
            end
        end
        self.ActiveTab = selected
        self:Focus()
        return true
    end
    function self:CrearSeccion(name)
        assert(type(name) == "string" and name ~= "", "CrearSeccion necesita un nombre")
        if self._legacyTabs[name] then return self._legacyTabs[name].Section end
        local tab = self:AddTab({ Title = name })
        local section = tab:AddSection({ Title = name })
        self._legacyTabs[name] = { Tab = tab, Section = section }
        return section
    end
    function self:MostrarSeccion(name)
        local record = self._legacyTabs[name]
        return self:ShowTab(record and record.Tab or name)
    end
    function self:CambiarInfoDeContenedorInformacion(data)
        data = data or {}
        self:SetTitle(tostring(data.Titulo or data.Title or ""))
        self:SetDescription(tostring(data.Descripcion or data.Description or ""))
    end
    function self:SetMinimized(minimized)
        if self._destroyed or not options.Minimizable then return end
        minimized = minimized == true
        if minimized == self.Minimized then return end
        if minimized and self.Maximized then self:SetMaximized(false) end
        self.Minimized = minimized
        if minimized then
            self._savedSize = root.Size
            self._savedConstraintMin, self._savedConstraintMax = sizeConstraint.MinSize, sizeConstraint.MaxSize
            sizeConstraint.MinSize = Vector2.new(math.min(sizeConstraint.MinSize.X, root.AbsoluteSize.X), HEADER_HEIGHT)
            sizeConstraint.MaxSize = Vector2.new(math.max(sizeConstraint.MaxSize.X, root.AbsoluteSize.X), math.max(sizeConstraint.MaxSize.Y, HEADER_HEIGHT))
            context.Input:CancelOwner(self); context.Input:CancelScope(self)
            sidebar.Visible = false; contentHost.Visible = false
            if resizeHandle then resizeHandle.Visible = false end
            context.Tweens:To(root, { Size = UDim2.new(self._savedSize.X.Scale, self._savedSize.X.Offset, 0, HEADER_HEIGHT) }, { Time = 0.18, Enabled = options.Animation })
        else
            sizeConstraint.MinSize = self._savedConstraintMin or options.MinSize
            sizeConstraint.MaxSize = self._savedConstraintMax or options.MaxSize
            sidebar.Visible = true; contentHost.Visible = true
            if resizeHandle then resizeHandle.Visible = true end
            context.Tweens:To(root, { Size = self._savedSize }, { Time = 0.18, Enabled = options.Animation })
            responsiveLayout()
        end
    end
    function self:SetMaximized(maximized)
        if self._destroyed or not options.Maximizable then return end
        maximized = maximized == true
        if maximized == self.Maximized then return end
        if maximized then
            if self.Minimized then self:SetMinimized(false) end
            self._restoreSize, self._restorePosition = root.Size, root.Position
            local camera = workspaceService.CurrentCamera
            if camera then
                local viewport = camera.ViewportSize
                local target = UDim2.fromOffset(math.max(300, viewport.X - 28), math.max(240, viewport.Y - 28))
                local maxSize = options.MaxSize
                target = UDim2.fromOffset(math.min(target.X.Offset, maxSize.X), math.min(target.Y.Offset, maxSize.Y))
                root.AnchorPoint = Vector2.new(0.5, 0.5)
                root.Position = UDim2.fromScale(0.5, 0.5)
                context.Tweens:To(root, { Size = target }, { Time = 0.2, Enabled = options.Animation })
            end
        else
            root.AnchorPoint = Vector2.new(0.5, 0.5)
            if self._restorePosition then root.Position = self._restorePosition end
            if self._restoreSize then context.Tweens:To(root, { Size = self._restoreSize }, { Time = 0.2, Enabled = options.Animation }) end
        end
        self.Maximized = maximized
        if resizeHandle then resizeHandle.Visible = options.Resizable and not maximized end
        if maximizeButton then
            local icon = maximizeButton:FindFirstChild("Icon")
            if icon then
                if icon:IsA("TextLabel") then icon.Text = IconRenderer.Glyph(maximized and "restore" or "maximize")
                elseif icon:IsA("ImageLabel") then icon.Image = maximized and "rbxassetid://9886659001" or "rbxassetid://9886659406" end
            end
        end
    end
    function self:Close()
        if options.CloseBehavior == "Destroy" then self:Destroy() else self:Hide() end
    end
    function self:AdaptToViewport()
        if not options.AdaptiveSize or self._destroyed or self.Minimized or self.Maximized then return end
        local camera = workspaceService.CurrentCamera
        if not camera then return end
        local viewport = camera.ViewportSize
        local sourceSize = options.Size
        local desiredWidth = sourceSize.X.Scale * viewport.X + sourceSize.X.Offset
        local desiredHeight = sourceSize.Y.Scale * viewport.Y + sourceSize.Y.Offset
        if desiredWidth <= 0 then desiredWidth = 780 end
        if desiredHeight <= 0 then desiredHeight = 520 end
        local widthCap = math.max(300, viewport.X - 24)
        local heightCap = math.max(240, viewport.Y - 24)
        local configuredMin = options.MinSize
        local minWidth, minHeight = math.min(configuredMin.X, widthCap), math.min(configuredMin.Y, heightCap)
        sizeConstraint.MinSize = Vector2.new(minWidth, minHeight)
        sizeConstraint.MaxSize = Vector2.new(math.min(options.MaxSize.X, widthCap), math.min(options.MaxSize.Y, heightCap))
        root.Size = UDim2.fromOffset(math.clamp(desiredWidth, minWidth, math.max(minWidth, widthCap)),
            math.clamp(desiredHeight, minHeight, math.max(minHeight, heightCap)))
        self._savedSize = root.Size
        responsiveLayout()
    end
    function self:Destroy()
        if self._destroyed then return end
        self._destroyed = true
        context.Input:CancelOwner(self); context.Input:CancelScope(self); context.Tweens:Cancel(root)
        for _, tab in ipairs(self.Tabs) do tab:Destroy() end
        table.clear(self.Tabs)
        self._cleanup:Destroy()
        manager:Remove(self)
        if shadow.Parent then shadow:Destroy() end
        if root.Parent then root:Destroy() end
    end

    if options.Draggable then
        self._cleanup:Add(topbar.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local pointer = input.Position
            local function over(guiObject)
                if not guiObject then return false end
                local position, size = guiObject.AbsolutePosition, guiObject.AbsoluteSize
                return pointer.X >= position.X and pointer.X <= position.X + size.X and pointer.Y >= position.Y and pointer.Y <= position.Y + size.Y
            end
            if over(closeButton) or over(minimizeButton) or over(maximizeButton) then return end
            self:Focus()
            local startInput, startPosition = input.Position, root.Position
            context.Input:BeginDrag(input, function(position)
                local delta = position - startInput
                root.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
                    startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
            end, nil, self, self)
        end))
    end
    if closeButton then self._cleanup:Add(closeButton.Activated:Connect(function() self:Focus(); self:Close() end)) end
    if minimizeButton then self._cleanup:Add(minimizeButton.Activated:Connect(function() self:Focus(); self:SetMinimized(not self.Minimized) end)) end
    if maximizeButton then self._cleanup:Add(maximizeButton.Activated:Connect(function() self:Focus(); self:SetMaximized(not self.Maximized) end)) end
    if resizeHandle then
        self._cleanup:Add(resizeHandle.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            if self.Maximized or self.Minimized then return end
            self:Focus()
            local start, size = input.Position, root.AbsoluteSize
            context.Input:BeginDrag(input, function(position)
                local delta = position - start
                local minSize, maxSize = options.MinSize, options.MaxSize
                local width = math.clamp(size.X + delta.X, minSize.X, maxSize.X)
                local height = math.clamp(size.Y + delta.Y, minSize.Y, maxSize.Y)
                root.Size = UDim2.fromOffset(width, height); self._savedSize = root.Size
            end, nil, self, self)
        end))
    end
    self._cleanup:Add(root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        responsiveLayout()
        syncShadow()
    end))
    self._cleanup:Add(root:GetPropertyChangedSignal("Position"):Connect(syncShadow))
    self._cleanup:Add(root:GetPropertyChangedSignal("Size"):Connect(syncShadow))
    self._cleanup:Add(root:GetPropertyChangedSignal("Visible"):Connect(syncShadow))
    local function connectCamera(camera)
        if self._cameraConnection then self._cameraConnection:Disconnect(); self._cameraConnection = nil end
        if camera then self._cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if self.Maximized then self:SetMaximized(false); self:SetMaximized(true) else self:AdaptToViewport() end
        end) end
    end
    self._cleanup:Add(function() if self._cameraConnection then self._cameraConnection:Disconnect(); self._cameraConnection = nil end end)
    self._cleanup:Add(workspaceService:GetPropertyChangedSignal("CurrentCamera"):Connect(function() connectCamera(workspaceService.CurrentCamera); self:AdaptToViewport() end))
    connectCamera(workspaceService.CurrentCamera)
    self:_ApplyZIndex()
    self:AdaptToViewport()
    syncShadow()
    return self
end

return Window
