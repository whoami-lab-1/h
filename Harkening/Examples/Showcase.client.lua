--[[
    HARKENING UI v2 — SHOWCASE COMPLETO

    Instalación:
      1. Compila el proyecto con Darklua (build.bat).
      2. Coloca el resultado como ModuleScript "Harkening" en ReplicatedStorage.
      3. Coloca este archivo como LocalScript en StarterPlayer > StarterPlayerScripts.

    Este ejemplo recorre los componentes y las APIs públicas. Las callbacks son
    demostrativas: reemplázalas por la lógica real de tu experiencia.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
assert(player, "Showcase.client.lua debe ejecutarse en el cliente")

local Harkening = require(ReplicatedStorage:WaitForChild("Harkening"))

---------------------------------------------------------------------
-- 1. INICIALIZACIÓN, TEMA Y SERVICIOS PÚBLICOS
---------------------------------------------------------------------

local ui = Harkening.new({
    Name = "HarkeningShowcase",
    ResetOnSpawn = false,
    DisplayOrder = 80,
    Animation = true,
    Debug = true,
    Theme = {
        Background = Color3.fromRGB(16, 18, 24),
        Surface = Color3.fromRGB(24, 27, 35),
        SurfaceRaised = Color3.fromRGB(33, 37, 47),
        Border = Color3.fromRGB(49, 55, 69),
        Text = Color3.fromRGB(240, 243, 250),
        MutedText = Color3.fromRGB(150, 160, 179),
        Accent = Color3.fromRGB(115, 140, 255),
        AccentText = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(72, 190, 140),
        Danger = Color3.fromRGB(235, 90, 105),
        CornerRadius = 8,
    },
})

local function notify(title, description, duration)
    return ui:Notify({
        Title = title,
        Description = description,
        Duration = duration == nil and 3 or duration,
    })
end

local function dump(value)
    if type(value) == "table" then
        local parts = {}
        for key, item in pairs(value) do
            table.insert(parts, tostring(key) .. "=" .. tostring(item))
        end
        table.sort(parts)
        return "{" .. table.concat(parts, ", ") .. "}"
    end
    if typeof(value) == "EnumItem" then
        return value.Name
    end
    return tostring(value)
end

-- ThemeManager permite suscribirse a los cambios. Desconecta la suscripción
-- cuando ya no te haga falta; ui:Destroy() también limpia los listeners.
local themeSubscription = ui.Theme:Subscribe(function(theme)
    print("[Harkening] Tema actualizado. Accent =", theme.Accent)
end)

print("Harkening UI versión:", Harkening.Version)
print("Componentes registrados:", table.concat(ui:GetAvailableComponents(), ", "))
print("Tema actual:", dump(ui:GetTheme()))

---------------------------------------------------------------------
-- 2. VENTANA PRINCIPAL Y NAVEGACIÓN
---------------------------------------------------------------------

local main = ui:CreateWindow({
    Id = "main",
    Title = "Harkening UI",
    Description = "Showcase completo del framework",
    Icon = Harkening.Icons["icono-cuenta"],
    Size = UDim2.fromOffset(760, 550),
    Position = UDim2.fromScale(0.5, 0.5),
    MinSize = Vector2.new(560, 400),
    MaxSize = Vector2.new(1180, 850),
    Draggable = true,
    Resizable = true,
    Minimizable = true,
    Closable = true,
    CloseBehavior = "Hide",
    AdaptiveSize = true,
    Animation = true,
})

local homeTab = main:AddTab({ Title = "Inicio", Icon = Harkening.Icons["icono-cuenta"], Selected = true })
local controlsTab = main:AddTab({ Title = "Controles" })
local componentsTab = main:AddTab({ Title = "Visuales" })
local compositeTab = main:AddTab({ Title = "Compuestos" })
local windowsTab = main:AddTab({ Title = "Ventanas" })
local systemTab = main:AddTab({ Title = "Sistema" })

---------------------------------------------------------------------
-- 3. INICIO: LABEL, PARAGRAPH, DIVIDER, IMAGE, PROGRESS Y BUTTON
---------------------------------------------------------------------

local overview = homeTab:AddSection({
    Title = "Bienvenido",
    Description = "Una demostración de los componentes públicos de Harkening UI v2.",
})

overview:AddLabel({
    Text = "HARKENING UI  /  COMPONENT FRAMEWORK",
    TextSize = 12,
    Bold = true,
    Color = Color3.fromRGB(170, 185, 255),
})

overview:AddParagraph({
    Title = "Cómo leer este ejemplo",
    Text = "Abre cada pestaña y prueba los controles. Los valores iniciales no disparan callbacks; las acciones del usuario sí. Para actualizar un control desde código, usa GetValue y SetValue.",
    TextSize = 12,
})
overview:AddDivider({ Thickness = 1, Color = Color3.fromRGB(58, 65, 82) })
overview:AddImage({
    Image = Harkening.Icons["icono-cuenta"],
    Width = 64,
    Height = 64,
    FixedWidth = true,
    ScaleType = Enum.ScaleType.Fit,
    CornerRadius = 8,
})

local progress = overview:AddProgress({
    Title = "Progreso de demostración",
    Min = 0,
    Max = 100,
    Value = 35,
    ShowPercent = true,
})

overview:AddButton({
    Title = "Incrementar progreso",
    Description = "Cambia el valor del indicador mediante su API pública.",
    Callback = function()
        local nextValue = (progress:GetValue() + 15) % 101
        progress:SetValue(nextValue)
        notify("Progreso", "Nuevo valor: " .. tostring(nextValue) .. "%")
    end,
})

overview:AddButton({
    Title = "Mostrar notificación",
    Icon = Harkening.Icons["icono-dropdown-list"],
    Callback = function()
        notify("Harkening UI", "La notificación se cerrará automáticamente.", 3)
    end,
})

---------------------------------------------------------------------
-- 4. CONTROLES INTERACTIVOS Y MÉTODOS DE ESTADO
---------------------------------------------------------------------

local stateSection = controlsTab:AddSection({
    Title = "Valores y callbacks",
    Description = "Los callbacks se ejecutan al cambiar la selección; los valores iniciales se aplican sin callback.",
})

local activeToggle = stateSection:AddToggle({
    Title = "Activar función de ejemplo",
    Value = false,
    Callback = function(value)
        print("[Toggle] Nuevo valor:", value)
        notify("Interruptor", value and "Función activada" or "Función desactivada", 2)
    end,
})

local strengthSlider = stateSection:AddSlider({
    Title = "Intensidad",
    Min = 0,
    Max = 100,
    Step = 5,
    Value = 35,
    Callback = function(value)
        print("[Slider] Intensidad:", value)
    end,
})

local difficultyDropdown = stateSection:AddDropdown({
    Title = "Dificultad",
    Options = { "Fácil", "Normal", "Difícil" },
    Value = "Normal",
    Placeholder = "Elige una dificultad",
    MaxListHeight = 130,
    Callback = function(value)
        print("[Dropdown] Dificultad:", value)
    end,
})

local categoriesSelect = stateSection:AddMultiSelect({
    Title = "Categorías activas",
    Options = { "Interfaz", "Audio", "Gameplay", "Depuración" },
    Value = { "Interfaz", "Depuración" },
    Placeholder = "Elige una o más categorías",
    MaxListHeight = 130,
    Callback = function(values)
        print("[MultiSelect] Categorías:", table.concat(values, ", "))
    end,
})

local playerNameInput = stateSection:AddTextInput({
    Title = "Nombre de perfil",
    Description = "Ejemplo de campo obligatorio con validación.",
    Placeholder = "Escribe al menos 3 caracteres",
    Value = "Harkening",
    Required = true,
    MaxLength = 24,
    Validator = function(value)
        if #value < 3 then
            return false, "El nombre debe contener al menos 3 caracteres"
        end
        return true
    end,
    Callback = function(value, enterPressed)
        print("[TextInput] Nombre confirmado:", value, "Enter:", enterPressed)
    end,
})

local quantityInput = stateSection:AddNumericInput({
    Title = "Cantidad",
    Description = "Solo admite enteros entre 1 y 50.",
    Placeholder = "1–50",
    Min = 1,
    Max = 50,
    Integer = true,
    Value = 8,
    Required = true,
    Callback = function(value)
        print("[NumericInput] Cantidad confirmada:", value)
    end,
})

local modeSegmented = stateSection:AddSegmented({
    Title = "Modo",
    Options = {
        { Value = "Casual", Text = "Casual" },
        { Value = "Balanceado", Text = "Balanceado" },
        { Value = "Rendimiento", Text = "Rendimiento" },
    },
    Value = "Balanceado",
    Callback = function(value)
        print("[Segmented] Modo:", value)
    end,
})

local keybind = stateSection:AddKeybind({
    Title = "Tecla configurada",
    Value = Enum.KeyCode.G,
    Callback = function(keyCode)
        print("[Keybind] Tecla asignada:", keyCode.Name)
        notify("Tecla asignada", keyCode.Name, 2)
    end,
})

local programmaticSection = controlsTab:AddSection({
    Title = "Control programático",
    Description = "SetValue(value, fireCallback): usa true para solicitar el callback del cambio programático.",
})

programmaticSection:AddButton({
    Title = "Alternar toggle desde código",
    Callback = function()
        activeToggle:SetValue(not activeToggle:GetValue(), true)
    end,
})

programmaticSection:AddButton({
    Title = "Cambiar slider a 75",
    Callback = function()
        strengthSlider:SetValue(75, true)
    end,
})

programmaticSection:AddButton({
    Title = "Cambiar valores de selección",
    Callback = function()
        difficultyDropdown:SetValue("Difícil", true)
        categoriesSelect:SetValue({ "Audio", "Gameplay" }, true)
        modeSegmented:SetValue("Rendimiento", true)
    end,
})

programmaticSection:AddButton({
    Title = "Actualizar campos de texto",
    Callback = function()
        playerNameInput:SetValue("HarkeningDemo", true)
        quantityInput:SetValue(12, true)
    end,
})

programmaticSection:AddButton({
    Title = "Capturar una tecla nueva",
    Description = "Pulsa el control Keybind o usa Capture() en código.",
    Callback = function()
        keybind:Capture()
    end,
})

programmaticSection:AddButton({
    Title = "Leer todos los valores por consola",
    Callback = function()
        print("Toggle:", activeToggle:GetValue())
        print("Slider:", strengthSlider:GetValue())
        print("Dropdown:", difficultyDropdown:GetValue())
        print("MultiSelect:", table.concat(categoriesSelect:GetValue(), ", "))
        print("Nombre:", playerNameInput:GetValue())
        print("Cantidad:", quantityInput:GetValue())
        print("Modo:", modeSegmented:GetValue())
        print("Tecla:", keybind:GetValue().Name)
    end,
})

local enabledExample = controlsTab:AddSection({ Title = "Enabled / Visible / Text" })
local temporaryButton = enabledExample:AddButton({
    Title = "Botón de prueba",
    Description = "Los otros botones activan, ocultan o renombran este control.",
    Callback = function()
        notify("Botón", "El botón de prueba está habilitado.")
    end,
})

enabledExample:AddButton({
    Title = "Deshabilitar botón de prueba",
    Callback = function()
        temporaryButton:SetEnabled(false)
    end,
})
enabledExample:AddButton({
    Title = "Habilitar y renombrar botón",
    Callback = function()
        temporaryButton:SetEnabled(true)
        temporaryButton:SetText("Botón habilitado de nuevo")
        temporaryButton:SetDescription("Texto actualizado con SetDescription.")
    end,
})

---------------------------------------------------------------------
-- 5. COMPONENTES VISUALES Y MUTACIÓN DE TEXTO
---------------------------------------------------------------------

local textSection = componentsTab:AddSection({ Title = "Texto e imagen" })

local dynamicLabel = textSection:AddLabel({
    Text = "Esta etiqueta se puede modificar desde código.",
    TextSize = 13,
    Bold = true,
})

local dynamicParagraph = textSection:AddParagraph({
    Title = "Párrafo descriptivo",
    Text = "Los componentes Label y Paragraph exponen métodos de texto. También admiten SetVisible y Destroy.",
    TextSize = 12,
})

textSection:AddDivider({ Thickness = 2, Color = Color3.fromRGB(115, 140, 255) })

local showcaseImage = textSection:AddImage({
    Image = Harkening.Icons["icono-lock-2-fill"],
    Height = 72,
    ScaleType = Enum.ScaleType.Fit,
    BackgroundTransparency = 1,
})

local disposableLabel = textSection:AddLabel({
    Text = "Etiqueta temporal: se puede destruir sin destruir toda la sección.",
    Color = Color3.fromRGB(130, 210, 175),
})
local disposableLabelDestroyed = false

textSection:AddButton({
    Title = "Cambiar los textos",
    Callback = function()
        dynamicLabel:SetText("Etiqueta actualizada correctamente.")
        dynamicParagraph:SetTitle("Título actualizado")
        dynamicParagraph:SetText("El texto de este párrafo se cambió mediante SetText().")
    end,
})

textSection:AddButton({
    Title = "Ocultar / mostrar etiqueta",
    Callback = function()
        dynamicLabel:SetVisible(not dynamicLabel.Visible)
        print("Texto actual de Label:", dynamicLabel:GetText())
    end,
})

textSection:AddButton({
    Title = "Cambiar imagen y consultar su ID",
    Callback = function()
        local currentImage = showcaseImage:GetImage()
        local newImage = currentImage == Harkening.Icons["icono-cuenta"]
            and Harkening.Icons["icono-lock-2-fill"]
            or Harkening.Icons["icono-cuenta"]
        showcaseImage:SetImage(newImage)
        print("Image actual:", showcaseImage:GetImage())
    end,
})

textSection:AddButton({
    Title = "Destruir etiqueta temporal",
    Callback = function()
        if disposableLabelDestroyed then
            notify("Componente", "La etiqueta ya fue destruida.")
            return
        end
        disposableLabelDestroyed = true
        disposableLabel:Destroy()
        notify("Componente", "Se destruyó solo la etiqueta temporal.")
    end,
})

---------------------------------------------------------------------
-- 6. COMPONENTES COMPUESTOS: CARD Y COLLAPSIBLE
---------------------------------------------------------------------

local cardSection = compositeTab:AddSection({
    Title = "Card con componentes anidados",
    Description = "Card puede alojar los mismos tipos de controles que una sección.",
})

local settingsCard = cardSection:AddCard({
    Title = "Tarjeta de preferencias",
    Description = "Ejemplo compuesto que reúne controles reutilizables.",
    BackgroundColor = Color3.fromRGB(27, 31, 41),
})

settingsCard:AddToggle({
    Title = "Partículas",
    Value = true,
    Callback = function(value) print("Partículas:", value) end,
})
settingsCard:AddSlider({
    Title = "Distancia de visión",
    Min = 25,
    Max = 500,
    Step = 25,
    Value = 150,
    Callback = function(value) print("Distancia:", value) end,
})
settingsCard:AddDropdown({
    Title = "Calidad gráfica",
    Options = { "Baja", "Media", "Alta" },
    Value = "Alta",
})
settingsCard:AddButton({
    Title = "Notificar desde la tarjeta",
    Callback = function() notify("Card", "El callback de un control anidado funciona.") end,
})

local collapsible = cardSection:AddCollapsible({
    Title = "Panel expandible",
    Expanded = false,
})
collapsible:AddParagraph({
    Title = "Contenido interno",
    Text = "El panel expandible también contiene controles a través de la misma fábrica.",
})
collapsible:AddToggle({ Title = "Opción interna", Value = false })
collapsible:AddButton({ Title = "Acción interna", Callback = function() notify("Collapsible", "Acción interna ejecutada") end })

cardSection:AddButton({
    Title = "Expandir / contraer panel",
    Callback = function()
        collapsible:SetExpanded(not collapsible:IsExpanded())
    end,
})

cardSection:AddButton({
    Title = "Deshabilitar / habilitar tarjeta",
    Callback = function()
        settingsCard:SetEnabled(not settingsCard.Enabled)
    end,
})

---------------------------------------------------------------------
-- 7. FORMULARIO, VALIDACIÓN, GETFIELD, GETVALUES Y SUBMIT
---------------------------------------------------------------------

local formSection = compositeTab:AddSection({
    Title = "Formulario compuesto",
    Description = "Form construye campos a partir de su configuración y valida los campos compatibles antes de enviar.",
})

local profileForm = formSection:AddForm({
    SubmitText = "Guardar perfil",
    Enabled = true,
    Fields = {
        {
            Name = "ProfileName",
            Type = "TextInput",
            Title = "Nombre del perfil",
            Placeholder = "Mínimo 3 caracteres",
            Value = "Piloto",
            Required = true,
            MaxLength = 24,
            Validator = function(value)
                if #value < 3 then return false, "Escribe al menos 3 caracteres" end
                return true
            end,
        },
        {
            Name = "MaxPlayers",
            Type = "NumericInput",
            Title = "Máximo de jugadores",
            Min = 1,
            Max = 50,
            Integer = true,
            Value = 12,
            Required = true,
        },
        {
            Name = "Difficulty",
            Type = "Dropdown",
            Title = "Dificultad",
            Options = { "Fácil", "Normal", "Difícil" },
            Value = "Normal",
        },
    },
    OnSubmit = function(values)
        print("[Form] Valores enviados:", dump(values))
        notify("Perfil guardado", dump(values), 5)
    end,
})

formSection:AddButton({
    Title = "Leer valores del formulario",
    Callback = function()
        print("[Form:GetValues]", dump(profileForm:GetValues()))
        local nameField = profileForm:GetField("ProfileName")
        if nameField then print("Campo ProfileName:", nameField:GetValue()) end
    end,
})

formSection:AddButton({
    Title = "Validar y enviar formulario desde código",
    Callback = function()
        local values, valid, fieldName, message = profileForm:Submit()
        if not valid then
            notify("Formulario inválido", tostring(fieldName) .. ": " .. tostring(message), 4)
            return
        end
        print("Submit manual:", dump(values))
    end,
})

formSection:AddButton({
    Title = "Deshabilitar / habilitar formulario",
    Callback = function()
        profileForm:SetEnabled(not profileForm.Enabled)
    end,
})

---------------------------------------------------------------------
-- 8. DROPDOWN: OPCIONES DINÁMICAS Y ESTADO ABIERTO / CERRADO
---------------------------------------------------------------------

local dropdownAdvanced = compositeTab:AddSection({
    Title = "Dropdown dinámico",
    Description = "Añadir, quitar, reemplazar o borrar opciones en tiempo de ejecución.",
})

local dynamicDropdown = dropdownAdvanced:AddDropdown({
    Title = "Selector dinámico",
    Options = { "Uno", "Dos", "Tres" },
    Value = "Dos",
    Callback = function(value) print("Opción dinámica:", value) end,
})
local hasFourOption = false

dropdownAdvanced:AddButton({
    Title = "Añadir opción Cuatro",
    Callback = function()
        if hasFourOption then
            notify("Dropdown", "Cuatro ya existe.")
            return
        end
        dynamicDropdown:AddOption("Cuatro")
        hasFourOption = true
        notify("Dropdown", "Se añadió Cuatro.")
    end,
})
dropdownAdvanced:AddButton({
    Title = "Eliminar opción Cuatro",
    Callback = function()
        dynamicDropdown:RemoveOption("Cuatro")
        hasFourOption = false
        notify("Dropdown", "Se eliminó Cuatro si estaba disponible.")
    end,
})
dropdownAdvanced:AddButton({
    Title = "Reemplazar todas las opciones",
    Callback = function()
        dynamicDropdown:SetOptions({ "Rojo", "Verde", "Azul" })
        dynamicDropdown:SetValue("Verde", false)
        hasFourOption = false
    end,
})
dropdownAdvanced:AddButton({
    Title = "Vaciar todas las opciones",
    Callback = function()
        dynamicDropdown:ClearOptions()
        hasFourOption = false
        notify("Dropdown", "Se eliminaron las opciones. Usa restaurar para volver a llenarlo.")
    end,
})
dropdownAdvanced:AddButton({
    Title = "Restaurar opciones originales",
    Callback = function()
        dynamicDropdown:SetOptions({ "Uno", "Dos", "Tres" })
        dynamicDropdown:SetValue("Dos", false)
        hasFourOption = false
    end,
})
dropdownAdvanced:AddButton({
    Title = "Abrir dropdown directamente",
    Callback = function() dynamicDropdown:Open() end,
})
dropdownAdvanced:AddButton({
    Title = "Cerrar dropdown directamente",
    Callback = function() dynamicDropdown:Close() end,
})
dropdownAdvanced:AddButton({
    Title = "Alternar abierto / cerrado",
    Callback = function() dynamicDropdown:ToggleOpen() end,
})
dropdownAdvanced:AddButton({
    Title = "Consultar si está abierto",
    Callback = function()
        notify("Dropdown", dynamicDropdown:IsOpen() and "El dropdown está abierto" or "El dropdown está cerrado")
    end,
})

---------------------------------------------------------------------
-- 9. VENTANA SECUNDARIA, ADMINISTRACIÓN, FOCO Y DESTRUCCIÓN
---------------------------------------------------------------------

local settingsWindow

local function openSettingsWindow()
    settingsWindow = ui:GetWindow("settings")
    if settingsWindow then
        settingsWindow:Show()
        settingsWindow:Focus()
        return settingsWindow
    end

    settingsWindow = ui:CreateWindow({
        Id = "settings",
        Title = "Configuración secundaria",
        Description = "Ventana independiente de la principal",
        Size = UDim2.fromOffset(430, 370),
        Position = UDim2.new(0.68, 0, 0.52, 0),
        MinSize = Vector2.new(320, 260),
        MaxSize = Vector2.new(700, 620),
        Draggable = true,
        Resizable = true,
        Minimizable = true,
        Closable = true,
        CloseBehavior = "Hide",
        AdaptiveSize = true,
        Animation = true,
    })

    local settingsTab = settingsWindow:AddTab({ Title = "Preferencias" })
    local settingsSection = settingsTab:AddSection({ Title = "Opciones" })
    settingsSection:AddToggle({ Title = "Animaciones de ejemplo", Value = true })
    settingsSection:AddDropdown({ Title = "Idioma", Options = { "Español", "English" }, Value = "Español" })
    settingsSection:AddSlider({ Title = "Escala de interfaz", Min = 80, Max = 120, Step = 5, Value = 100 })
    settingsSection:AddButton({
        Title = "Enfocar ventana principal",
        Callback = function()
            main:Show()
            main:Focus()
        end,
    })
    settingsSection:AddButton({
        Title = "Cerrar usando Window:Close()",
        Callback = function() settingsWindow:Close() end,
    })
    settingsSection:AddButton({
        Title = "Destruir usando Window:Destroy()",
        Callback = function()
            settingsWindow:Destroy()
            settingsWindow = nil
        end,
    })

    return settingsWindow
end

local windowSection = windowsTab:AddSection({
    Title = "Ventanas independientes",
    Description = "El WindowManager identifica las ventanas mediante Id.",
})

windowSection:AddButton({
    Title = "Crear / mostrar ventana secundaria",
    Callback = function() openSettingsWindow() end,
})
windowSection:AddButton({
    Title = "Ocultar ventana secundaria",
    Callback = function() ui:HideWindow("settings") end,
})
windowSection:AddButton({
    Title = "Mostrar y enfocar ventana secundaria",
    Callback = function()
        local window = ui:ShowWindow("settings")
        if window then window:Focus() else notify("Ventanas", "Primero crea la ventana secundaria.") end
    end,
})
windowSection:AddButton({
    Title = "Leer ventanas existentes",
    Callback = function()
        for _, window in ipairs(ui:GetWindows()) do
            print("Ventana:", window.Id, "Título:", window.TitleObject.Text, "Visible:", window.Visible)
        end
    end,
})
windowSection:AddButton({
    Title = "Cambiar título y descripción de la ventana principal",
    Callback = function()
        main:SetTitle("Harkening UI — API Showcase")
        main:SetDescription("Título y descripción cambiados por código")
    end,
})
windowSection:AddButton({
    Title = "Restaurar título principal",
    Callback = function()
        main:SetTitle("Harkening UI")
        main:SetDescription("Showcase completo del framework")
    end,
})
windowSection:AddButton({
    Title = "Enfocar ventana principal",
    Callback = function() main:Show(); main:Focus() end,
})
windowSection:AddButton({
    Title = "Adaptar ventana al viewport actual",
    Callback = function() main:AdaptToViewport() end,
})
windowSection:AddButton({
    Title = "Mostrar pestaña Inicio por referencia",
    Callback = function() main:ShowTab(homeTab) end,
})
windowSection:AddButton({
    Title = "Cambiar / restaurar título de la pestaña Inicio",
    Callback = function()
        if homeTab.Title == "Inicio" then
            homeTab:SetTitle("Overview")
        else
            homeTab:SetTitle("Inicio")
        end
    end,
})

---------------------------------------------------------------------
-- 10. MODAL, POPUP Y NOTIFICACIÓN MANUAL
---------------------------------------------------------------------

local overlaySection = windowsTab:AddSection({
    Title = "Overlays y ventanas flotantes",
    Description = "Modal bloqueante opcional, popup independiente y notificaciones temporales.",
})

overlaySection:AddButton({
    Title = "Abrir diálogo de confirmación",
    Callback = function()
        ui:CreateModal({
            Title = "¿Aplicar configuración?",
            Description = "Este modal se dibuja encima del resto de ventanas.",
            ConfirmText = "Aplicar",
            CancelText = "Cancelar",
            BlockInput = true,
            CloseOnOverlayClick = true,
            OnConfirm = function()
                notify("Modal", "Confirmaste la acción.")
            end,
            OnCancel = function()
                notify("Modal", "Cancelaste la acción.", 2)
            end,
        })
    end,
})

local popupOpen = false
local popup = ui:CreatePopup({
    Name = "ShowcasePopup",
    Position = UDim2.new(1, -275, 0, 65),
    Size = UDim2.fromOffset(250, 255),
    Visible = false,
    ZIndex = 9000,
})
popup:AddParagraph({ Title = "Menú emergente", Text = "Popup admite controles compuestos mediante Add..." })
popup:AddToggle({ Title = "Opción del popup", Value = true })
popup:AddDropdown({ Title = "Acción", Options = { "Abrir", "Editar", "Cerrar" }, Value = "Editar" })
popup:AddButton({ Title = "Cerrar popup", Callback = function() popupOpen = false; popup:Close() end })

overlaySection:AddButton({
    Title = "Abrir / cerrar popup",
    Callback = function()
        popupOpen = not popupOpen
        if popupOpen then popup:Open() else popup:Close() end
    end,
})

local persistentNotification
overlaySection:AddButton({
    Title = "Crear notificación persistente",
    Description = "Duration = 0 desactiva el temporizador automático.",
    Callback = function()
        if persistentNotification and not persistentNotification._destroyed then
            persistentNotification:Close()
            persistentNotification = nil
        else
            persistentNotification = ui:Notify({
                Title = "Notificación persistente",
                Description = "Pulsa el mismo botón para cerrarla manualmente.",
                Duration = 0,
            })
        end
    end,
})

---------------------------------------------------------------------
-- 11. TEMA, FÁBRICA PÚBLICA Y MÉTODOS GLOBALES
---------------------------------------------------------------------

local systemSection = systemTab:AddSection({
    Title = "Servicios públicos",
    Description = "Consulta los tipos disponibles, actualiza el tema y prueba la ComponentFactory.",
})

local alternateAccent = false
systemSection:AddButton({
    Title = "Alternar color de acento para componentes nuevos",
    Callback = function()
        alternateAccent = not alternateAccent
        ui:SetTheme({
            Accent = alternateAccent and Color3.fromRGB(65, 195, 160) or Color3.fromRGB(115, 140, 255),
        })
        notify("Tema", "La paleta quedó actualizada para los componentes que se creen después.", 4)
        print("Tema actualizado:", dump(ui:GetTheme()))
    end,
})

systemSection:AddButton({
    Title = "Listar componentes registrados",
    Callback = function()
        print("Tipos disponibles:", table.concat(ui:GetAvailableComponents(), ", "))
    end,
})

systemSection:AddButton({
    Title = "Desconectar listener del tema",
    Callback = function()
        if themeSubscription then
            themeSubscription:Disconnect()
            themeSubscription = nil
            notify("Tema", "Suscripción desconectada.")
        else
            notify("Tema", "La suscripción ya estaba desconectada.")
        end
    end,
})

systemSection:AddButton({
    Title = "Ocultar la ventana principal",
    Description = "La ventana podrá reabrirse con el botón flotante fuera de ella.",
    Callback = function() main:Hide() end,
})
systemSection:AddButton({
    Title = "SetVisible(false) en ventana principal",
    Callback = function() main:SetVisible(false) end,
})
systemSection:AddButton({
    Title = "Minimizar la ventana principal por código",
    Callback = function() main:SetMinimized(true) end,
})

-- Un contenedor personalizado fuera de una ventana administrada. Esto demuestra
-- ui.Components:Create(...), útil cuando quieres montar un componente en una
-- instancia GUI propia. El propio ScreenGui de Harkening lo limpia al destruir ui.
local launcher = Instance.new("Frame")
launcher.Name = "HarkeningLauncher"
launcher.AnchorPoint = Vector2.new(0, 1)
launcher.Position = UDim2.new(0, 14, 1, -14)
launcher.Size = UDim2.fromOffset(200, 64)
launcher.BackgroundTransparency = 1
launcher.Parent = ui.Gui

local launcherButton = ui.Components:Create("Button", launcher, {
    Title = "Abrir Harkening UI",
    Description = "Botón creado con Components:Create",
    Callback = function()
        main:Show()
        main:SetMinimized(false)
        main:Focus()
    end,
})

-- También puedes crear componentes con nombres españoles en la fábrica:
-- ui.Components:Create("Etiqueta", parentInstance, { Text = "Hola" })
-- Aliases soportados: botón, interruptor, deslizador, despegable, tarjeta,
-- párrafo, separador, progreso, imagen, expandible y formulario.

systemSection:AddButton({
    Title = "Destruir ventana secundaria por Id",
    Callback = function()
        ui:DestroyWindow("settings")
        settingsWindow = nil
        notify("WindowManager", "Se solicitó la destrucción de la ventana settings.")
    end,
})

systemSection:AddButton({
    Title = "Cerrar Harkening UI por completo",
    Description = "Destruye ventanas, overlays, notificaciones, listeners y el ScreenGui.",
    Callback = function()
        if themeSubscription then themeSubscription:Disconnect(); themeSubscription = nil end
        ui:Destroy()
    end,
})

---------------------------------------------------------------------
-- 12. NOTAS DE API
---------------------------------------------------------------------

-- Controles que almacenan valor suelen exponer GetValue() y SetValue(value, fireCallback).
-- SetEnabled(false) deshabilita un control; SetVisible(false) lo oculta; Destroy() lo elimina.
-- Button expone SetText / SetDescription; Label y Paragraph exponen SetText;
-- Paragraph también expone SetTitle; Image expone SetImage / GetImage.
-- Dropdown/MultiSelect exponen AddOption, RemoveOption, SetOptions, ClearOptions,
-- Open, Close, ToggleOpen e IsOpen.
-- Form expone GetValues, GetField, Submit y SetEnabled.
-- Collapsible expone SetExpanded e IsExpanded.
-- Window expone Show, Hide, SetVisible, Focus, SetTitle, SetDescription,
-- SetMinimized, Close, AdaptToViewport y Destroy.
--
-- Nota de la implementación actual de Keybind: su callback se ejecuta al asignar
-- una tecla nueva; la versión actual no dispara automáticamente la callback al
-- presionar la tecla asignada durante el juego.

print("[Harkening] Showcase completo iniciado para", player.Name)
