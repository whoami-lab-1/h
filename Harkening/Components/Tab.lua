local Builder = require("../Utilities/InstanceBuilder")
local Cleanup = require("../Utilities/Cleanup")
local IconRenderer = require("../Utilities/IconRenderer")
local Section = require("./Section")

local Tab = {}
Tab.__index = Tab

function Tab.new(window, options)
    options = options or {}
    local context, theme = window.Context, window.Context.Theme
    local title = tostring(options.Title or options.Name or "Tab")
    local id = tostring(options.Id or title)
    local iconName = options.Icon or IconRenderer.DefaultFor(title)

    local button = Builder.Create("TextButton", {
        Name = "Tab_" .. id, Size = UDim2.new(1, 0, 0, 39),
        BackgroundColor3 = theme:Get("SurfaceHover"), BackgroundTransparency = 1, BorderSizePixel = 0,
        AutoButtonColor = false, Text = "", LayoutOrder = #window.Tabs + 1,
    }, window.TabButtons)
    Builder.Corner(button, 9)
    local stroke = Builder.Stroke(button, theme:Get("BorderSubtle"), 1, 1)
    local indicator = Builder.Create("Frame", {
        Name = "ActiveIndicator", AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(0, 3, 0, 18), BackgroundColor3 = theme:Get("Accent"), BorderSizePixel = 0,
        Visible = false,
    }, button)
    Builder.Corner(indicator, 5)
    local iconHolder = Builder.Create("Frame", {
        Name = "IconHolder", Position = UDim2.new(0, 8, 0.5, -13), Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = theme:Get("SurfaceRaised"), BackgroundTransparency = 0.28, BorderSizePixel = 0,
    }, button)
    Builder.Corner(iconHolder, 8)
    local icon = IconRenderer.Create(iconHolder, iconName, {
        Size = UDim2.fromOffset(15, 15), Position = UDim2.new(0.5, -7.5, 0.5, -7.5),
        Color = theme:Get("MutedText"), Fallback = "layers", TextSize = 15,
    })
    local label = Builder.Label(button, "Title", title, UDim2.new(1, -54, 1, 0), UDim2.new(0, 43, 0, 0), theme:Get("MutedText"), 11, true)
    label.TextTruncate = Enum.TextTruncate.AtEnd
    local badge
    if options.Badge ~= nil then
        badge = Builder.Create("TextLabel", {
            Name = "Badge", AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0),
            Size = UDim2.fromOffset(22, 18), BackgroundColor3 = theme:Get("AccentSoft"), BorderSizePixel = 0,
            Text = tostring(options.Badge), TextColor3 = theme:Get("Accent"), TextSize = 9, Font = Enum.Font.GothamBold,
        }, button)
        Builder.Corner(badge, 6)
        label.Size = UDim2.new(1, -78, 1, 0)
    end

    local page = Builder.Create("ScrollingFrame", {
        Name = "Page_" .. id, BackgroundTransparency = 1, BorderSizePixel = 0,
        Position = UDim2.new(), Size = UDim2.fromScale(1, 1), CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3,
        ScrollBarImageColor3 = theme:Get("Border"), ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
    }, window.Pages)
    Builder.Padding(page, 17, 17, 14, 20)
    Builder.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 13),
    }, page)

    local pageHeader = Builder.Create("Frame", {
        Name = "PageHeader", LayoutOrder = 0, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, options.Description and 68 or 57),
    }, page)
    local eyebrow = Builder.Label(pageHeader, "Eyebrow", tostring(options.Eyebrow or "HARKENING  /  WORKSPACE"),
        UDim2.new(1, -5, 0, 12), UDim2.new(0, 1, 0, 0), theme:Get("Accent"), 8, true)
    eyebrow.TextXAlignment = Enum.TextXAlignment.Left
    local pageTitle = Builder.Label(pageHeader, "PageTitle", title,
        UDim2.new(1, -5, 0, 27), UDim2.new(0, 0, 0, 13), theme:Get("Text"), 20, true)
    pageTitle.TextTruncate = Enum.TextTruncate.AtEnd
    local pageDescription
    if options.Description and options.Description ~= "" then
        pageDescription = Builder.Label(pageHeader, "PageDescription", tostring(options.Description),
            UDim2.new(1, -5, 0, 17), UDim2.new(0, 1, 0, 42), theme:Get("MutedText"), 10, false)
        pageDescription.TextTruncate = Enum.TextTruncate.AtEnd
    end
    local divider = Builder.Create("Frame", {
        Name = "HeaderDivider", Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = theme:Get("BorderSubtle"), BackgroundTransparency = 0.18, BorderSizePixel = 0,
    }, pageHeader)

    local self = setmetatable({
        Window = window, Context = context, Title = title, Id = id,
        Button = button, Page = page, TitleObject = label, PageTitleObject = pageTitle,
        PageDescriptionObject = pageDescription, Sections = {}, _destroyed = false,
        _cleanup = Cleanup.new(), _active = false, _buttonStroke = stroke,
        _indicator = indicator, _icon = icon, _iconHolder = iconHolder,
    }, Tab)

    function self:AddSection(sectionOptions)
        assert(not self._destroyed, "Tab destruida")
        if type(sectionOptions) == "string" then sectionOptions = { Title = sectionOptions } end
        sectionOptions = sectionOptions or {}
        local section = Section.new(context, page, sectionOptions)
        table.insert(self.Sections, section)
        section.Frame.LayoutOrder = #self.Sections
        if context.Window and context.Window._ApplyZIndex then context.Window:_ApplyZIndex() end
        return section
    end
    function self:SetTitle(value)
        if self._destroyed then return end
        assert(type(value) == "string", "SetTitle espera string")
        self.Title, label.Text, pageTitle.Text = value, value, value
        button.Name = "Tab_" .. tostring(value)
    end
    function self:SetDescription(value)
        if self._destroyed then return end
        assert(type(value) == "string", "SetDescription espera string")
        if pageDescription then pageDescription.Text = value
        elseif value ~= "" then
            pageDescription = Builder.Label(pageHeader, "PageDescription", value, UDim2.new(1, -5, 0, 17), UDim2.new(0, 1, 0, 42), theme:Get("MutedText"), 10)
            pageDescription.TextTruncate = Enum.TextTruncate.AtEnd
            self.PageDescriptionObject = pageDescription
            pageHeader.Size = UDim2.new(1, 0, 0, 68)
        end
    end
    function self:SetActive(active)
        if self._destroyed then return end
        self._active = active == true
        button.BackgroundTransparency = self._active and 0.06 or 1
        button.BackgroundColor3 = self._active and (theme:Get("SurfaceSelected") or theme:Get("AccentSoft")) or theme:Get("SurfaceHover")
        label.TextColor3 = self._active and theme:Get("Text") or theme:Get("MutedText")
        indicator.Visible = self._active
        iconHolder.BackgroundColor3 = theme:Get("SurfaceRaised")
        iconHolder.BackgroundTransparency = self._active and 0.04 or 0.28
        if icon then
            if icon:IsA("ImageLabel") then icon.ImageColor3 = self._active and theme:Get("Accent") or theme:Get("MutedText")
            else icon.TextColor3 = self._active and theme:Get("Accent") or theme:Get("MutedText") end
        end
        page.Visible = self._active
        if self._active then
            context.Tweens:To(stroke, { Color = theme:Get("Accent"), Transparency = 0.52 }, { Time = 0.14 })
            context.Tweens:To(indicator, { Size = UDim2.new(0, 3, 0, 22) }, { Time = 0.12 })
        else
            context.Tweens:To(stroke, { Color = theme:Get("BorderSubtle"), Transparency = 1 }, { Time = 0.12 })
            context.Tweens:To(indicator, { Size = UDim2.new(0, 3, 0, 14) }, { Time = 0.12 })
        end
    end
    function self:Destroy()
        if self._destroyed then return end
        self._destroyed = true
        for _, section in ipairs(self.Sections) do section:Destroy() end
        table.clear(self.Sections)
        self._cleanup:Destroy()
        if button.Parent then button:Destroy() end
        if page.Parent then page:Destroy() end
    end
    self._cleanup:Add(button.Activated:Connect(function() window:ShowTab(self) end))
    self._cleanup:Add(button.MouseEnter:Connect(function()
        if not self._active and not self._destroyed then context.Tweens:To(button, { BackgroundTransparency = 0.45 }, { Time = 0.12 }) end
    end))
    self._cleanup:Add(button.MouseLeave:Connect(function()
        if not self._active and not self._destroyed then context.Tweens:To(button, { BackgroundTransparency = 1 }, { Time = 0.12 }) end
    end))
    return self
end

return Tab
