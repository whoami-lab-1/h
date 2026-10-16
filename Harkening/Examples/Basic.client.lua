-- Coloca este LocalScript en StarterPlayerScripts después de importar Harkening a ReplicatedStorage.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Harkening = require(ReplicatedStorage:WaitForChild("Harkening"))

local ui = Harkening.new({
	Name = "DemoHarkening",
	Animation = true,
	Theme = {
		Accent = Color3.fromRGB(119, 145, 255),
		Background = Color3.fromRGB(17, 18, 24),
	},
})

local main = ui:CreateWindow({
	Id = "main",
	Title = "Harkening UI",
	Description = "Componentes modulares",
	Resizable = true,
	Size = UDim2.fromOffset(620, 460),
})

local general = main:AddTab({ Title = "General" })
local controls = general:AddSection({ Title = "Controles", Description = "Cambios de estado y callbacks." })

controls:AddButton({
	Title = "Mostrar notificación",
	Description = "Esta acción solo se ejecuta cuando activas el botón.",
	Callback = function()
		ui:Notify({ Title = "Harkening", Description = "El botón funciona.", Duration = 3 })
	end,
})

local toggle = controls:AddToggle({ Title = "Activar modo", Value = false, Callback = function(value)
	print("Modo activado:", value)
end })
controls:AddButton({ Title = "Cambiar toggle por código", Callback = function()
	toggle:SetValue(not toggle:GetValue(), false) -- fireCallback=false: no dispara callback programático.
end })

local slider = controls:AddSlider({ Title = "Volumen", Min = 0, Max = 100, Step = 5, Value = 35,
	Callback = function(value) print("Volumen:", value) end })
controls:AddLabel({ Text = "Valor programático del slider: " .. tostring(slider:GetValue()) })

controls:AddDropdown({ Title = "Dificultad", Options = { "Fácil", "Normal", "Difícil" }, Value = "Normal",
	Callback = function(value) print("Dificultad:", value) end })
controls:AddMultiSelect({ Title = "Categorías", Options = { "UI", "Audio", "Gameplay", "Debug" }, Value = { "UI", "Debug" },
	Callback = function(values) print("Categorías:", table.concat(values, ", ")) end })
controls:AddTextInput({ Title = "Nombre", Placeholder = "Escribe un nombre", Value = "Jugador",
	Callback = function(value) print("Nombre confirmado:", value) end })
controls:AddNumericInput({ Title = "Cantidad", Min = 1, Max = 20, Integer = true, Value = 5,
	Callback = function(value) print("Cantidad:", value) end })
controls:AddSegmented({ Title = "Modo", Options = { "Solo", "Equipo", "Libre" }, Value = "Equipo",
	Callback = function(value) print("Modo:", value) end })
controls:AddKeybind({ Title = "Tecla de acción", Value = Enum.KeyCode.G,
	Callback = function(key) print("Tecla asignada:", key.Name) end })

local composed = general:AddSection({ Title = "Componentes compuestos" })
local card = composed:AddCard({ Title = "Tarjeta de configuración", Description = "Una tarjeta puede contener controles." })
card:AddToggle({ Title = "Mostrar detalle", Value = true })
card:AddButton({ Title = "Abrir ventana secundaria", Callback = function()
	local child = ui:GetWindow("settings")
	if child then child:Show(); return end
	child = ui:CreateWindow({ Id = "settings", Title = "Configuración", Description = "Ventana independiente",
		Size = UDim2.fromOffset(390, 300), Position = UDim2.new(0.65, 0, 0.5, 0), Resizable = true })
	local tab = child:AddTab({ Title = "Opciones" })
	local section = tab:AddSection({ Title = "Preferencias" })
	section:AddToggle({ Title = "Reducir animaciones", Value = false })
	section:AddDropdown({ Title = "Idioma", Options = { "Español", "English" }, Value = "Español" })
	section:AddButton({ Title = "Cerrar ventana", Callback = function() child:Hide() end })
end })

local progressSection = general:AddSection({ Title = "Otros componentes" })
local progress = progressSection:AddProgress({ Title = "Carga de ejemplo", Value = 64 })
progressSection:AddButton({ Title = "Actualizar progreso", Callback = function()
	progress:SetValue((progress:GetValue() + 15) % 101)
end })
progressSection:AddCollapsible({ Title = "Más opciones", Expanded = false }):AddParagraph({
	Title = "Contenido anidado", Text = "Los contenedores aceptan componentes sin duplicar sus implementaciones." })

local actions = main:AddTab({ Title = "Acciones" })
local actionSection = actions:AddSection({ Title = "Diálogo" })
actionSection:AddButton({ Title = "Pedir confirmación", Callback = function()
	ui:CreateModal({ Title = "¿Continuar?", Description = "Este diálogo bloquea la interacción detrás de él.",
		ConfirmText = "Continuar", CancelText = "Cancelar",
		OnConfirm = function() ui:Notify({ Title = "Confirmado", Description = "Acción aceptada." }) end })
end })

-- ui:Destroy() elimina todas las ventanas, notificaciones y conexiones del framework.
