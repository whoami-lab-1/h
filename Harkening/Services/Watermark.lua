-- Harkening UI automatic watermark/HUD. One managed Heartbeat connection per framework.
local Builder = require("../Utilities/InstanceBuilder")
local Cleanup = require("../Utilities/Cleanup")

local Watermark = {}
Watermark.__index = Watermark

local POSITIONS = {
    TopLeft = { Anchor = Vector2.new(0, 0), Position = UDim2.new(0, 16, 0, 16) },
    TopRight = { Anchor = Vector2.new(1, 0), Position = UDim2.new(1, -16, 0, 16) },
    BottomLeft = { Anchor = Vector2.new(0, 1), Position = UDim2.new(0, 16, 1, -16) },
    BottomRight = { Anchor = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16) },
    TopCenter = { Anchor = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 16) },
    BottomCenter = { Anchor = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -16) },
}

local DEFAULTS = {
    Enabled = true, Title = "HARKENING UI", Text = "", ShowLogo = true, LogoText = "H", LogoImage = nil,
    ShowGameName = true, ShowGameIcon = true, ShowFPS = true, ShowClock = false,
    Position = "TopRight", Style = "Compact", Status = "RUNNING",
    BackgroundTransparency = 0.12, Width = 300,
}

function Watermark.new(context, options)
    options = options or {}
    local self = setmetatable({ Context = context, Options = {}, _cleanup = Cleanup.new(), _destroyed = false, _visible = false,
        _fpsElapsed = 0, _fpsFrames = 0, _fps = 0, _status = "RUNNING" }, Watermark)
    for key, value in pairs(DEFAULTS) do self.Options[key] = value end
    for key, value in pairs(options) do self.Options[key] = value end
    self._status = tostring(self.Options.Status or "RUNNING")

    local theme = context.Theme
    local position = POSITIONS[self.Options.Position] or POSITIONS.TopRight
    local width = math.clamp(tonumber(self.Options.Width) or 300, 190, 520)
    local expanded = self.Options.Style == "Expanded"
    local height = expanded and 68 or 42
    local frame = Builder.Create("Frame", {
        Name = "HarkeningWatermark", AnchorPoint = position.Anchor, Position = position.Position,
        Size = UDim2.fromOffset(width, height), BackgroundColor3 = theme:Get("Surface"),
        BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false, ZIndex = 10000,
    }, context.Gui)
    Builder.Corner(frame, theme:Get("CornerRadius"))
    local stroke = Builder.Stroke(frame, theme:Get("Accent"), 1, 1)
    Builder.Padding(frame, 10, 10, 7, 7)
    local horizontal = Builder.Create("Frame", { Name = "Header", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28), ZIndex = 10001 }, frame)
    local logo = Builder.Create("Frame", { Name = "Logo", BackgroundColor3 = theme:Get("Accent"), BorderSizePixel = 0,
        Size = UDim2.fromOffset(27, 27), Visible = self.Options.ShowLogo ~= false, ZIndex = 10002 }, horizontal)
    Builder.Corner(logo, 7)
    local logoText = Builder.Label(logo, "LogoGlyph", tostring(self.Options.LogoText or "H"), UDim2.fromScale(1, 1), UDim2.new(), theme:Get("AccentText"), 14, true)
    logoText.TextXAlignment = Enum.TextXAlignment.Center
    local logoImage = Builder.Create("ImageLabel", { Name = "LogoImage", BackgroundTransparency = 1, AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(19, 19), Image = tostring(self.Options.LogoImage or ""),
        ScaleType = Enum.ScaleType.Fit, Visible = self.Options.LogoImage ~= nil and self.Options.LogoImage ~= "", ZIndex = 10003 }, logo)
    logoText.Visible = not logoImage.Visible
    local titleX = self.Options.ShowLogo == false and 0 or 35
    local title = Builder.Label(horizontal, "ProjectTitle", tostring(self.Options.Title or "HARKENING UI"),
        UDim2.new(1, -titleX - 88, 0, 18), UDim2.new(0, titleX, 0, 1), theme:Get("Text"), 12, true)
    title.TextTruncate = Enum.TextTruncate.AtEnd
    local status = Builder.Label(horizontal, "Status", self._status, UDim2.new(0, 83, 0, 15), UDim2.new(1, -83, 0, 2), theme:Get("Success"), 9, true)
    status.TextXAlignment = Enum.TextXAlignment.Right
    local stats = Builder.Label(horizontal, "Stats", "", UDim2.new(0, 83, 0, 15), UDim2.new(1, -83, 0, 15), theme:Get("MutedText"), 9)
    stats.TextXAlignment = Enum.TextXAlignment.Right

    local details = Builder.Create("Frame", { Name = "Details", BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 31),
        Size = UDim2.new(1, 0, 0, 24), Visible = expanded, ZIndex = 10001 }, frame)
    local gameIcon = Builder.Create("ImageLabel", { Name = "GameIcon", BackgroundColor3 = theme:Get("SurfaceRaised"),
        BackgroundTransparency = 0, BorderSizePixel = 0, Size = UDim2.fromOffset(20, 20),
        Image = "rbxthumb://type=GameIcon&id=" .. tostring(game.PlaceId) .. "&w=150&h=150",
        ScaleType = Enum.ScaleType.Fit, Visible = self.Options.ShowGameIcon ~= false, ZIndex = 10002 }, details)
    Builder.Corner(gameIcon, 5)
    local gameName = Builder.Label(details, "GameName", tostring(game.Name),
        UDim2.new(1, (self.Options.ShowGameIcon == false and 0 or -27), 0, 20), UDim2.new(0, (self.Options.ShowGameIcon == false and 0 or 27), 0, 0),
        theme:Get("MutedText"), 10)
    gameName.TextTruncate = Enum.TextTruncate.AtEnd
    local clock = Builder.Label(frame, "Clock", "", UDim2.new(1, -12, 0, 12), UDim2.new(0, 1, 1, -13), theme:Get("MutedText"), 9)
    clock.Visible = self.Options.ShowClock == true and expanded

    self.Frame, self._stroke, self._logo, self._title, self._statusLabel = frame, stroke, logo, title, status
    self._stats, self._details, self._gameIcon, self._gameName, self._clock = stats, details, gameIcon, gameName, clock
    self._logoText, self._logoImage, self._header, self._height = logoText, logoImage, horizontal, height
    self._shownPosition = position.Position
    self:_ApplyOptions(self.Options)

    if self.Options.ShowGameName ~= false then
        -- Do not block the framework while asking Roblox for place metadata.
        task.spawn(function()
            local marketplace = context.Services.MarketplaceService
            if not marketplace or game.PlaceId <= 0 then return end
            local ok, info = pcall(function() return marketplace:GetProductInfo(game.PlaceId) end)
            if ok and type(info) == "table" and type(info.Name) == "string" and not self._destroyed then
                self._gameName.Text = info.Name
            end
        end)
    end

    self._cleanup:Add(context.Services.RunService.Heartbeat:Connect(function(dt)
        if self._destroyed then return end
        self._fpsElapsed += dt
        self._fpsFrames += 1
        if self._fpsElapsed >= 0.5 then
            self._fps = math.floor(self._fpsFrames / math.max(self._fpsElapsed, 0.001) + 0.5)
            self._fpsElapsed, self._fpsFrames = 0, 0
            self:_UpdateReadouts()
        end
    end))
    if self.Options.Enabled ~= false then self:Show(false) end
    return self
end

function Watermark:_UpdateReadouts()
    if self._destroyed then return end
    local parts = {}
    if self.Options.ShowFPS ~= false then table.insert(parts, tostring(self._fps) .. " FPS") end
    if self.Options.Text and self.Options.Text ~= "" then table.insert(parts, tostring(self.Options.Text)) end
    self._stats.Text = table.concat(parts, "  •  ")
    self._stats.Visible = #parts > 0
    if self.Options.ShowClock == true then self._clock.Text = os.date("%H:%M:%S") end
    self._statusLabel.Text = self._status
    self._statusLabel.TextColor3 = self._status == "ERROR" and self.Context.Theme:Get("Danger")
        or (self._status == "READY" and self.Context.Theme:Get("Success") or self.Context.Theme:Get("Accent"))
end

function Watermark:_ApplyOptions(options)
    if self._destroyed then return end
    local theme = self.Context.Theme
    local position = POSITIONS[options.Position] or POSITIONS.TopRight
    local expanded = options.Style == "Expanded"
    self.Frame.AnchorPoint = position.Anchor
    self._shownPosition = position.Position
    self.Frame.Position = position.Position
    self.Frame.Size = UDim2.fromOffset(math.clamp(tonumber(options.Width) or 300, 190, 520), expanded and 68 or 42)
    self.Frame.BackgroundTransparency = math.clamp(tonumber(options.BackgroundTransparency) or 0.12, 0, 1)
    self._title.Text = tostring(options.Title or "HARKENING UI")
    self._logo.Visible = options.ShowLogo ~= false
    self._logoImage.Image = tostring(options.LogoImage or "")
    self._logoImage.Visible = options.LogoImage ~= nil and options.LogoImage ~= ""
    self._logoText.Text = tostring(options.LogoText or "H")
    self._logoText.Visible = not self._logoImage.Visible
    self._title.Position = UDim2.new(0, options.ShowLogo == false and 0 or 35, 0, 1)
    self._title.Size = UDim2.new(1, (options.ShowLogo == false and -88 or -123), 0, 18)
    self._gameIcon.Visible = options.ShowGameIcon ~= false
    self._gameName.Visible = options.ShowGameName ~= false
    self._gameName.Position = UDim2.new(0, options.ShowGameIcon == false and 0 or 27, 0, 0)
    self._gameName.Size = UDim2.new(1, options.ShowGameIcon == false and 0 or -27, 0, 20)
    self._details.Visible = expanded and options.ShowGameName ~= false
    self._clock.Visible = expanded and options.ShowClock == true
    self._clock.Position = UDim2.new(0, 1, 1, -14)
    self._statusLabel.Visible = options.ShowStatus ~= false
    self._stats.Visible = options.ShowFPS ~= false or (options.Text ~= nil and options.Text ~= "")
    self._stroke.Color = theme:Get("Accent")
    self:_UpdateReadouts()
end

function Watermark:Update(options)
    assert(type(options) == "table", "UpdateWatermark espera una tabla")
    if self._destroyed then return end
    local wasEnabled = self.Options.Enabled ~= false
    for key, value in pairs(options) do self.Options[key] = value end
    if options.Status ~= nil then self._status = tostring(options.Status) end
    self:_ApplyOptions(self.Options)
    if options.Enabled == false then
        self:Hide()
    elseif options.Enabled == true and not wasEnabled then
        self:Show(false)
    end
end
function Watermark:SetStatus(status)
    assert(type(status) == "string", "SetStatus espera una cadena")
    self._status = status
    self:_UpdateReadouts()
end
function Watermark:SetVisible(visible)
    if self._destroyed then return end
    if visible then self:Show(false) else self:Hide() end
end
function Watermark:Show(skipAnimation)
    if self._destroyed then return end
    self._visible = true
    self.Frame.Visible = true
    local target = self._shownPosition
    if skipAnimation or not self.Context.Tweens.Enabled then
        self.Frame.Position = target
        self.Frame.BackgroundTransparency = math.clamp(tonumber(self.Options.BackgroundTransparency) or 0.12, 0, 1)
        self._stroke.Transparency = 0.35
        self._title.TextTransparency, self._statusLabel.TextTransparency, self._stats.TextTransparency = 0, 0, 0
        self._logoText.TextTransparency, self._gameName.TextTransparency, self._clock.TextTransparency = 0, 0, 0
        return
    end
    local hiddenPosition = target + UDim2.fromOffset(0, self.Options.Position and string.find(self.Options.Position, "Bottom") and 8 or -8)
    self.Frame.Position = hiddenPosition
    self.Frame.BackgroundTransparency = 1
    self._stroke.Transparency = 1
    for _, label in ipairs({ self._title, self._statusLabel, self._stats, self._logoText, self._gameName, self._clock }) do label.TextTransparency = 1 end
    self.Context.Tweens:To(self.Frame, { Position = target, BackgroundTransparency = math.clamp(tonumber(self.Options.BackgroundTransparency) or 0.12, 0, 1) }, { Time = 0.24 })
    self.Context.Tweens:To(self._stroke, { Transparency = 0.35 }, { Time = 0.3 })
    for index, label in ipairs({ self._title, self._statusLabel, self._stats, self._logoText, self._gameName, self._clock }) do
        task.delay((index - 1) * 0.025, function()
            if not self._destroyed and self._visible and label.Parent then self.Context.Tweens:To(label, { TextTransparency = 0 }, { Time = 0.18 }) end
        end)
    end
end
function Watermark:Hide()
    if self._destroyed or not self._visible then return end
    self._visible = false
    if not self.Context.Tweens.Enabled then self.Frame.Visible = false; return end
    local offset = self.Options.Position and string.find(self.Options.Position, "Bottom") and 8 or -8
    self.Context.Tweens:To(self.Frame, { Position = self._shownPosition + UDim2.fromOffset(0, offset), BackgroundTransparency = 1 }, { Time = 0.16 })
    task.delay(0.18, function() if not self._destroyed and not self._visible then self.Frame.Visible = false end end)
end
function Watermark:IsVisible() return self._visible end
function Watermark:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    self._cleanup:Destroy()
    if self.Context and self.Context.Tweens and self.Frame then
        self.Context.Tweens:Cancel(self.Frame)
        for _, item in ipairs(self.Frame:GetDescendants()) do self.Context.Tweens:Cancel(item) end
    end
    if self.Frame and self.Frame.Parent then self.Frame:Destroy() end
    self.Frame = nil
end

return Watermark
