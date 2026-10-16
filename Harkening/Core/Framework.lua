local Cleanup = require("../Utilities/Cleanup")
local Defaults = require("../Utilities/Defaults")
local Validation = require("../Utilities/Validation")
local Builder = require("../Utilities/InstanceBuilder")
local EnvironmentAdapter = require("../Services/EnvironmentAdapter")
local ThemeManager = require("../Services/ThemeManager")
local TweenManager = require("../Services/TweenManager")
local InputManager = require("../Services/InputManager")
local ComponentFactory = require("../Components/ComponentFactory")
local LifecycleManager = require("./LifecycleManager")
local WindowManager = require("./WindowManager")
local Modal = require("../Components/Modal")
local Popup = require("../Components/Popup")
local Notification = require("../Components/Notification")
local Icons = require("../Utilities/Icons")
local Watermark = require("../Services/Watermark")

local ACTIVE_BY_PARENT = setmetatable({}, { __mode = "k" })

local Framework = {}
Framework.__index = Framework
Framework.Version = "2.2.3"

function Framework.new(options)
	options = Defaults.Merge(Defaults.Framework, Validation.Options(options, "Harkening.new options"))
	options.Name = Validation.String(options.Name, "Name", "Harkening UI", false)
	assert(type(options.Theme) == "table", "Theme debe ser una tabla")
	assert(type(options.Animation) == "boolean", "Animation debe ser booleano")
	assert(type(options.ResetOnSpawn) == "boolean", "ResetOnSpawn debe ser booleano")
	options.DisplayOrder = Validation.Number(options.DisplayOrder, "DisplayOrder", 50)
	assert(options.DisplayOrder % 1 == 0, "DisplayOrder debe ser un entero")
	assert(type(options.Debug) == "boolean", "Debug debe ser booleano")
	local environment = EnvironmentAdapter.new(options)
	local parent = environment:ResolveParent()
    -- Reinitializing the same named framework under the same parent replaces the old
    -- instance instead of leaving duplicate ScreenGuis, HUDs, or service connections.
    local namedInstances = ACTIVE_BY_PARENT[parent]
    local previous = namedInstances and namedInstances[options.Name]
    if previous and not previous._destroyed then previous:Destroy() end
    local existingGui = parent:FindFirstChild(options.Name)
    if existingGui and existingGui:IsA("ScreenGui") and existingGui:GetAttribute("HarkeningOwned") == true then existingGui:Destroy() end
	local services = environment:GetServices()
	local gui = Builder.Create("ScreenGui", { Name = options.Name or "HarkeningUI", ResetOnSpawn = options.ResetOnSpawn,
		DisplayOrder = options.DisplayOrder, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = false }, parent)
    gui:SetAttribute("HarkeningOwned", true)
    gui:SetAttribute("HarkeningVersion", Framework.Version)
	local cleanup = Cleanup.new()
	local lifecycle = LifecycleManager.new()
	local theme = ThemeManager.new(options.Theme)
	local tweens = TweenManager.new(options.Animation, services.TweenService)
	local input = InputManager.new(cleanup, services.UserInputService)
	local context = {
		Gui = gui, Theme = theme, Tweens = tweens, Input = input, Cleanup = cleanup,
		Environment = environment, Services = services, Lifecycle = lifecycle, Options = options,
	}
	local self = setmetatable({ Options = options, Gui = gui, Environment = environment, Services = services,
		Theme = theme, Tweens = tweens, Input = input, Cleanup = cleanup, Lifecycle = lifecycle,
		Windows = nil, _destroyed = false, _resources = {}, _notifications = {} }, Framework)
	context.Framework = self
	local manager = WindowManager.new(context)
	context.WindowManager = manager
	local factory = ComponentFactory.new(context)
	context.Factory = factory
	self.Context = context
	self.Windows = manager
	self.Components = factory
	self.Componentes = factory
	self.Icons = Icons
    self._registryParent, self._registryName = parent, options.Name
    ACTIVE_BY_PARENT[parent] = ACTIVE_BY_PARENT[parent] or {}
    ACTIVE_BY_PARENT[parent][options.Name] = self
    -- The HUD is initialized as part of this framework instance. It shares the same
    -- ScreenGui and lifecycle and remains independent of any individual window.
    if options.Watermark ~= false and type(options.Watermark) == "table" and options.Watermark.Enabled ~= false then
        self.Watermark = Watermark.new(context, options.Watermark)
    end
	return self
end

function Framework:CreateWindow(options)
	assert(not self._destroyed, "Harkening ya fue destruido")
	return self.Windows:Create(options or {})
end
function Framework:GetWindow(id) return self.Windows:Get(id) end
function Framework:GetWindows() return self.Windows:GetAll() end
function Framework:ShowWindow(id) return self.Windows:Show(id) end
function Framework:HideWindow(id) return self.Windows:Hide(id) end
function Framework:DestroyWindow(id) return self.Windows:Destroy(id) end
function Framework:SetTheme(theme) self.Theme:SetTheme(theme) end
function Framework:GetTheme() return self.Theme:GetAll() end
function Framework:GetAvailableComponents() return self.Components:GetAvailable() end
function Framework:SetWatermarkVisible(visible)
    if self._destroyed then return end
    if not self.Watermark then
        if visible == true then
            local watermarkOptions = type(self.Options.Watermark) == "table" and table.clone(self.Options.Watermark) or {}
            watermarkOptions.Enabled = true
            self.Watermark = Watermark.new(self.Context, watermarkOptions)
        end
        return
    end
    self.Watermark:SetVisible(visible == true)
end
function Framework:UpdateWatermark(options)
    assert(type(options) == "table", "UpdateWatermark espera una tabla")
    if self._destroyed then return end
    if not self.Watermark then
        local watermarkOptions = type(self.Options.Watermark) == "table" and table.clone(self.Options.Watermark) or {}
        for key, value in pairs(options) do watermarkOptions[key] = value end
        watermarkOptions.Enabled = true
        self.Watermark = Watermark.new(self.Context, watermarkOptions)
    else
        self.Watermark:Update(options)
    end
end
function Framework:GetWatermark() return self.Watermark end
function Framework:SetStatus(status) if self.Watermark then self.Watermark:SetStatus(status) end end

function Framework:CreateModal(options)
	assert(not self._destroyed, "Harkening ya fue destruido")
	return self.Lifecycle:Add(Modal.new(self.Context, options or {}))
end
function Framework:CreatePopup(options)
	assert(not self._destroyed, "Harkening ya fue destruido")
	return self.Lifecycle:Add(Popup.new(self.Context, options or {}))
end
function Framework:Notify(options)
	assert(not self._destroyed, "Harkening ya fue destruido")
	options = table.clone(options or {})
	local notificationHeight = options.Height or (options.Description and 82 or 62)
	if options.OffsetY == nil then options.OffsetY = 24 + #self._notifications * (notificationHeight + 10) end
	local notification = Notification.new(self.Context, options)
	table.insert(self._notifications, notification)
	notification._onDestroy = function()
		for index = #self._notifications, 1, -1 do
			if self._notifications[index] == notification then table.remove(self._notifications, index); break end
		end
		if not self._destroyed then
			local y = 24
			for _, item in ipairs(self._notifications) do
				if not item._destroyed then
					item:SetOffsetY(y)
					local height = item.Frame and item.Frame.Size.Y.Offset or 62
					y += height + 10
				end
			end
		end
	end
	return self.Lifecycle:Add(notification)
end

-- Friendly aliases for teams that prefer Spanish API names.
Framework.CrearVentanaPrincipal = Framework.CreateWindow
Framework.ObtenerVentana = Framework.GetWindow
Framework.MostrarVentana = Framework.ShowWindow
Framework.OcultarVentana = Framework.HideWindow
Framework.CambiarTema = Framework.SetTheme
Framework.MostrarNotificacion = Framework.Notify
Framework.MostrarMarcaDeAgua = Framework.SetWatermarkVisible
Framework.ActualizarMarcaDeAgua = Framework.UpdateWatermark

function Framework:Destroy()
	if self._destroyed then return end
	self._destroyed = true
    local namedInstances = self._registryParent and ACTIVE_BY_PARENT[self._registryParent]
    if namedInstances and namedInstances[self._registryName] == self then namedInstances[self._registryName] = nil end
	self.Windows:Destroy()
    if self.Watermark then self.Watermark:Destroy(); self.Watermark = nil end
	self.Lifecycle:Destroy()
	self.Input:Destroy()
	self.Tweens:Destroy()
	self.Theme:Destroy()
	self.Cleanup:Destroy()
	if self.Gui and self.Gui.Parent then self.Gui:Destroy() end
end

return Framework
