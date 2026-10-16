# Harkening UI 2 — API

## Inicialización

```lua
local Harkening = require(game:GetService("ReplicatedStorage"):WaitForChild("Harkening"))
local ui = Harkening.new({
    Name = "MiInterfaz",
    Parent = nil, -- por defecto PlayerGui; una Instance explícita válida puede cambiar el montaje
    ResetOnSpawn = false,
    DisplayOrder = 50,
    Animation = true,
    Theme = { Accent = Color3.fromRGB(190, 108, 255), AccentSecondary = Color3.fromRGB(255, 91, 193) },
})
```

`Harkening.new` debe ejecutarse en cliente desde un `LocalScript`. En servidor no hay `LocalPlayer`, y el framework devuelve un error explicativo en vez de montar silenciosamente la interfaz en un contenedor incorrecto.

## Ventanas

```lua
local window = ui:CreateWindow({
    Id = "principal", Title = "Herramientas", Description = "Panel de juego",
    Icon = "rbxassetid://0", -- opcional
    Size = UDim2.fromOffset(580, 390), Position = UDim2.fromScale(0.5, 0.5),
    MinSize = Vector2.new(260, 200), MaxSize = Vector2.new(1200, 900),
    Draggable = true, Resizable = true, Minimizable = true, Closable = true,
    CloseBehavior = "Hide", -- también admite "Destroy"
    AdaptiveSize = true, Animation = true,
})
```

- `ui:CreateWindow(options)`: crea otra ventana independiente.
- `ui:GetWindow(id)`, `ui:GetWindows()`: consulta instancias existentes.
- `ui:ShowWindow(id)`, `ui:HideWindow(id)`, `ui:DestroyWindow(id)`: administración por id.
- `window:Show()`, `window:Hide()`, `window:SetVisible(boolean)`, `window:Focus()`.
- `window:SetTitle(string)`, `window:SetDescription(string)`, `window:SetMinimized(boolean)`, `window:Destroy()`.
- `window:AddTab({ Title, Icon, Selected })`: crea navegación y página.
- `window:ShowTab(tabOrTitle)`: activa una pestaña.

## Pestañas y secciones

```lua
local tab = window:AddTab({ Title = "General" })
local section = tab:AddSection({ Title = "Comportamiento", Description = "Opciones principales", Icon = "settings" })
```

Las secciones y tarjetas respetan el tema común; `Accent = true` añade una regla de acento opcional, desactivada por defecto para evitar saturación visual. `Icon` admite nombres semánticos, IDs de assets o descriptores con color.

Una sección permite `AddButton`, `AddToggle`, `AddSlider`, `AddDropdown`, `AddMultiSelect`, `AddTextInput`, `AddNumericInput`, `AddLabel`, `AddParagraph`, `AddDivider`, `AddCard`, `AddProgress`, `AddImage`, `AddKeybind`, `AddSegmented`, `AddCollapsible` y `AddForm`. Los controles pueden anidarse en `Card`, `Collapsible`, `Form` y `Popup` usando métodos equivalentes.

También puedes usar la fábrica explícita: `ui.Components:Create("Toggle", parentInstance, options)`.

## Valores y callbacks

Los componentes interactivos que almacenan valores exponen `GetValue()` y `SetValue(value, fireCallback)`. `fireCallback` es `false` por defecto; el callback de usuario solo se solicita si se pasa `true`. Los controles también ofrecen `SetEnabled(boolean)`, `SetVisible(boolean)` y `Destroy()`. Los componentes de texto ofrecen `SetText` o `SetTitle` cuando corresponda.

### Button

`{ Title, Description?, Icon?, Height?, Enabled?, Callback }`

Callback: `Callback(component)`.

### Toggle

`{ Title, Description?, Value? | Default?, Callback }`

Callback: `Callback(boolean, component)`.

### Slider

`{ Title, Min=0, Max=100, Step=1, Value? | Default?, Height?, Callback }`. `Max` debe ser mayor que `Min` y `Step` debe ser positivo.

Callback: `Callback(number, component)`.

### Dropdown / MultiSelect

`{ Title, Options, Value? | Default?, Placeholder?, MaxListHeight?, Callback }`. Cada opción puede ser una cadena/número o `{ Value = ..., Text = ... }`. `Dropdown` usa un único valor; `MultiSelect` usa un array. Métodos adicionales: `AddOption`, `RemoveOption`, `SetOptions`, `ClearOptions`, `Open`, `Close`, `ToggleOpen`, `IsOpen`.

Callback: `Callback(value, component)` (para MultiSelect el valor es un array).

### TextInput / NumericInput

`TextInput`: `{ Title, Description?, Placeholder?, Value? | Default?, Required?, MaxLength?, MultiLine?, Validator?, Callback }`. `Validate()` devuelve si el contenido es válido. El callback se dispara al perder el foco después de validar.

`NumericInput`: añade `Min?`, `Max?` e `Integer?`; `GetValue()` devuelve número o `nil` si el campo está vacío. El callback recibe el número confirmado.

### Otros controles

- `Label`: `{ Text, Color?, TextSize?, Bold? }`.
- `Paragraph`: `{ Title?, Text | Description, TextSize? }`.
- `Divider`: `{ Color?, Thickness? }`.
- `Card`: `{ Title?, Description?, BackgroundColor? }`, métodos de composición `Add...`.
- `Progress`: `{ Title?, Min=0, Max=100, Value?, ShowPercent? }`, método `SetValue(number)`.
- `Image`: `{ Image, Height?, Width?, FixedWidth?, ScaleType?, CornerRadius? }`.
- `Keybind`: `{ Title, Value? | Default? = Enum.KeyCode.Unknown, Callback }`; usa `Capture()` para iniciar captura por código.
- `Segmented`: `{ Options, Value? | Default?, Callback }`.
- `Collapsible`: `{ Title, Expanded? }`, `SetExpanded`, `IsExpanded` y métodos `Add...`.
- `Form`: `{ Fields = { { Name, Type, ... } }, SubmitText?, OnSubmit }`, métodos `GetValues`, `GetField`, `Submit`. `Submit()` valida los campos compatibles antes de ejecutar `OnSubmit`; si falla, devuelve `nil, false, nombreCampo, mensaje`.

## Marca de agua / HUD automático

La marca de agua se crea automáticamente desde `Harkening.new()` salvo que la desactives. Comparte el mismo `ScreenGui` y no depende de que haya una ventana visible.

```lua
local ui = Harkening.new({
    Watermark = {
        Enabled = true, Title = "PROJECT HARKENING", Text = "RUNNING",
        ShowLogo = true, LogoText = "H", ShowGameName = true, ShowGameIcon = true,
        ShowFPS = true, ShowClock = false, ShowStatus = true,
        Position = "TopRight", Style = "Compact", Status = "READY", Width = 300,
    },
})

ui:SetStatus("RUNNING")
ui:SetWatermarkVisible(false)
ui:SetWatermarkVisible(true)
ui:UpdateWatermark({ Position = "BottomRight", Style = "Expanded", ShowClock = true })
local watermark = ui:GetWatermark()
```

Desactivar con `Watermark = false` o `{ Enabled = false }`. `SetWatermarkVisible(true)` puede crearla de nuevo si fue desactivada al inicializar. Opciones relevantes: `Title`, `Text`, `LogoText`, `LogoImage`, `ShowLogo`, `ShowGameName`, `ShowGameIcon`, `ShowFPS`, `ShowClock`, `ShowStatus`, `Position`, `Style`, `Status`, `Width`, `BackgroundTransparency`. `GetWatermark()` devuelve el controlador con `SetVisible`, `Show`, `Hide`, `Update`, `SetStatus`, `IsVisible` y `Destroy`.

## Componentes de datos y selección adicionales

- `AddCheckbox({ Title, Description?, Value?, Callback? })`: control booleano con `GetValue` y `SetValue(value, fireCallback)`.
- `AddRadioGroup({ Title?, Options, Value?, Direction?, Callback? })`: selección única en grupo. Opciones pueden usar `{ Value, Text, Description?, Disabled? }`.
- `AddRangeSlider({ Min, Max, Step?, MinValue?, MaxValue?, Callback? })`: intervalo con `GetValue()` (dos valores) y `SetValue(min, max, fireCallback)`.
- `AddTextArea({ Title, Description?, Value?, Placeholder?, MaxLength?, Callback? })`: campo multilínea.
- `AddColorPicker({ Title, Value?: Color3, Callback? })`: selector de color por valor hexadecimal; `GetValue` y `SetValue`.
- `AddBadge({ Text, Variant?, Icon? })`, `AddStatusIndicator({ Status, Text? })`, `AddMetricCard({ Title, Value, Description?, Icon? })`, `AddKeyValueList({ Data })`. `Badge` ofrece `SetText`, `SetVariant`, `SetIcon`; `MetricCard`, `SetTitle`, `SetValue`, `SetDescription`, `SetIcon`.
- `AddItemCatalog({ Items, MaxRender?, SortBy?, OnItemSelected?, OnAction? })`: catálogo con búsqueda, categoría/rareza o filtro por predicado, ordenación, selección y acción. Cada item admite `Image`/`ThumbnailId` para una miniatura, `Icon`/`IconName`/`IconId` para un icono semántico o asset, `IconColor`, `Rarity`/`Quality`/`Tier`, `Tags`, `Stats`, `Meta`, `Price`/`Cost` y acciones. Los nombres semánticos incluyen `sword`, `gem`, `potion`, `paw`, `box`, `book`, `food`, `shield`, `key`, `car` y `house`; también puedes usar `Icon = { Name = "gem", Color = Color3.fromRGB(...) }`. `MaxRender` usa carga incremental, no virtualización completa. Métodos: `SetItems`, `SetSearch`, `SetFilter`, `SetSort`, `GetSelected`, `Select`.
- `AddDataTable({ Columns, Data, OnRowSelected? })`: tabla ordenable y seleccionable; `SetData`, `SetSort`, `GetSelectedRow`. Columnas admiten `Key`, `Field`, `Title`, `Width` y un `Render` opcional.
- `AddTreeView({ Nodes, OnNodeSelected? })`: árbol jerárquico con IDs estables, expandir/contraer y selección. Métodos: `SetNodes`, `ExpandAll`, `CollapseAll`, `SetExpanded`, `Select`, `GetSelected`.
- `AddCarousel({ Items, OnItemSelected? })`, `AddLogViewer({ Lines, MaxLines? })` (`Append`, `SetLines`, `Clear`), y `AddEmptyState({ Title, Description, Icon?, ActionText?, Callback? })`; admite `SetIcon`, `SetTitle`, `SetDescription` y `SetAction(text, callback)`.

Los alias de `ComponentFactory` son accesos convenientes que reutilizan módulos centrales; por ejemplo `PrimaryButton` es una variante de `Button`, `SearchableDropdown` es `Dropdown` con búsqueda y `MultiSelectDropdown` reutiliza `Dropdown` en modo múltiple. No todos los nombres del catálogo conceptual son módulos independientes.

## Modales, popups, notificaciones y temas

```lua
ui:CreateModal({ Title, Description, ConfirmText, CancelText, OnConfirm, OnCancel })
ui:CreatePopup({ Parent?, Position?, Size?, Visible? })
ui:Notify({ Title, Description, Duration = 4, Color? })
ui:SetTheme({ Accent = Color3.fromRGB(190, 108, 255), AccentSecondary = Color3.fromRGB(255, 91, 193) })
ui:GetTheme()
```

Un modal bloquea la superficie visual posterior por defecto; `BlockInput = false` evita interceptar el input y `CloseOnOverlayClick = true` permite cerrarlo pulsando el fondo. Un popup puede recibir `Parent` para anidarse en un contenedor específico. Las notificaciones se destruyen automáticamente si `Duration` es mayor que cero.

La paleta se usa al crear componentes nuevos. Las instancias ya creadas no se reconstruyen automáticamente cuando se llama `SetTheme`; si necesitas un cambio de tema en caliente, actualiza/recrea la vista o conecta `Theme:Subscribe` para componentes personalizados.

## Migración desde la API anterior

| API anterior | API recomendada |
|---|---|
| `CrearVentanaPrincipal` | `ui:CreateWindow` / `ui:CrearVentanaPrincipal` |
| `CrearSeccion(nombre)` | `window:AddTab({Title = nombre}):AddSection(...)` |
| `CrearBotonNormal(seccion, datos)` | `section:AddButton(datos)` |
| `CrearBotonInterruptor(seccion, datos)` | `section:AddToggle({Title=..., Value=..., Callback=...})` |
| `CrearBotonDeslizador(seccion, datos)` | `section:AddSlider({Title=..., Min=..., Max=..., Value=...})` |
| `CrearBotonDespegable(seccion, datos)` | `section:AddDropdown({Title=..., Options=..., Value=...})` |
| `Get()` / `Set()` | `GetValue()` / `SetValue(value, fireCallback)` |

Se incluyen wrappers de transición para `ui:CrearVentanaPrincipal`, `window:CrearSeccion`, `window:MostrarSeccion`, `window:CambiarInfoDeContenedorInformacion`, `section:CrearBotonNormal`, `section:CrearBotonDeslizador`, `section:CrearBotonInterruptor`, `section:CrearBotonDespegable` y `section:AgregarBoton`. Los wrappers convierten `Titulo`, `Descripcion`, `Valor`, `ValorInicial`, `Opciones` y `Paso` al esquema nuevo y usan los componentes nuevos. La protección Premium del módulo anterior no se replica: su autorización debe implementarse en la lógica del proyecto, no en los componentes visuales.
