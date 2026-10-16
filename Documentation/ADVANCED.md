# Harkening UI 2.1 — expansión avanzada

Esta ampliación conserva el patrón modular del framework y el punto de entrada `Harkening/init.lua`. Los componentes nuevos se cargan por `ComponentFactory`, por lo que pueden usarse desde secciones y desde contenedores que exponen la misma API `Add...`.

## Marca de agua automática

La marca de agua se crea durante `Harkening.new()` y comparte el mismo `ScreenGui` y ciclo de vida. No necesitas crear otra instancia ni invocar un constructor de HUD.

```lua
local ui = Harkening.new({
    Name = "MiProyecto",
    Animation = true,
    Watermark = {
        Enabled = true,
        Title = "PROJECT HARKENING",
        Text = "CLIENT READY",
        LogoText = "H",
        -- LogoImage = "rbxassetid://123456789", -- opcional
        ShowLogo = true,
        ShowGameName = true,
        ShowGameIcon = true,
        ShowFPS = true,
        ShowClock = false,
        ShowStatus = true,
        Position = "TopRight", -- TopLeft, TopRight, BottomLeft, BottomRight, TopCenter, BottomCenter
        Style = "Compact", -- Compact | Expanded
        Status = "READY", -- INITIALIZING | READY | RUNNING | ERROR u otro texto
        Width = 300,
        BackgroundTransparency = 0.12,
    },
})

ui:SetStatus("RUNNING")
ui:SetWatermarkVisible(false)
ui:SetWatermarkVisible(true)
ui:UpdateWatermark({
    Title = "PROJECT HARKENING",
    Position = "BottomRight",
    Style = "Expanded",
    ShowFPS = true,
    ShowClock = true,
    Text = "Local preview",
})

local watermark = ui:GetWatermark()
print(watermark and watermark:IsVisible())
```

`Watermark = false` o `Watermark = { Enabled = false }` desactiva el HUD automático. Puede habilitarse más tarde con `SetWatermarkVisible(true)` o `UpdateWatermark({...})`. La consulta de metadatos del juego se ejecuta de forma asíncrona y nunca bloquea `Harkening.new()`. La información del juego usa valores de respaldo si Roblox no devuelve detalles.

El FPS se mide con una única conexión `Heartbeat` por marca de agua, se refresca cada medio segundo y se desconecta al destruir la instancia. `ui:Destroy()` destruye también la marca de agua y cancela sus tweens.

## Colecciones y componentes de datos

### Catálogo de objetos / inventario

```lua
local catalog = section:AddItemCatalog({
    Height = 300,
    MaxRender = 100,
    SortBy = "Name",
    Items = {
        { Id = "sword-01", Name = "Training Blade", Description = "Starter weapon", Category = "Weapon", Rarity = "Common", Value = 25, Amount = 1 },
        { Id = "potion-02", Name = "Healing Potion", Category = "Consumable", Value = 10, Amount = 3 },
    },
    OnItemSelected = function(item) print(item.Id, item.Name) end,
    OnAction = function(item) print("Inspect", item.Name) end,
})

catalog:SetSearch("blade")
catalog:SetFilter("Weapon")
catalog:SetSort("Value", true)
local selected = catalog:GetSelected()
catalog:SetItems({ { Id = "new", Name = "New entry" } })
```

El catálogo implementa búsqueda por nombre/descripción/categoría/rareza, filtro por categoría o predicado, ordenación y acciones. `MaxRender` limita el primer lote de filas, con acción de cargar más; es paginación incremental, no virtualización completa de filas.

### Tabla de datos

```lua
local tableView = section:AddDataTable({
    Columns = {
        { Key = "Name", Title = "Name", Width = 0.5 },
        { Key = "Count", Title = "Count", Width = 0.5 },
    },
    Data = {
        { Id = "a", Name = "Buttons", Count = 8 },
        { Id = "b", Name = "Windows", Count = 3 },
    },
    OnRowSelected = function(row) print(row.Name) end,
})

tableView:SetSort("Count", true)
tableView:SetData({ { Id = "c", Name = "Watermark", Count = 1 } })
print(tableView:GetSelectedRow())
```

La tabla permite ordenar pulsando un encabezado y seleccionar una fila. `SetData` reemplaza los registros sin reconstruir el componente exterior. Los anchos de las columnas se expresan como fracciones entre `0` y `1`.

### Otros componentes nuevos

```lua
section:AddBadge({ Text = "BETA", Variant = "Warning" })
local status = section:AddStatusIndicator({ Status = "READY", Text = "Services initialized" })
status:SetStatus("ERROR", "Could not connect")

local metric = section:AddMetricCard({ Title = "FPS", Value = "60", Description = "Client" })
metric:SetValue("144", "Updated")

local properties = section:AddKeyValueList({ Data = { Framework = "Harkening", Version = "2.1.0" } })
properties:SetData({ Framework = "Harkening", State = "READY" })

local range = section:AddRangeSlider({ Min = 0, Max = 100, Step = 5, MinValue = 15, MaxValue = 80 })
local low, high = range:GetValue()
range:SetValue(20, 75, true)

local tree = section:AddTreeView({ Nodes = {
    { Id = "core", Name = "Core", Expanded = true, Children = {
        { Id = "framework", Name = "Framework.lua" },
    } },
} })
tree:ExpandAll()
```

Los otros módulos añadidos son `Checkbox`, `TextArea`, `ColorPicker`, `EmptyState`, `LogViewer`, `Carousel` y `RadioGroup`. `SearchableDropdown`, `MultiSelectDropdown`, `TagSelector`, variantes de botones y otros nombres de acceso son alias de la fábrica para reutilizar las implementaciones centrales; no son módulos duplicados independientes.

## Animaciones y ciclo de vida

- Usa `Animation = false` en `Harkening.new()` para desactivar las animaciones coordinadas por `TweenManager`.
- `Destroy()` debe ejecutarse al acabar con la interfaz. Los componentes que re-renderizan registros desconectan las conexiones de sus filas anteriores.
- La gestión de catálogos utiliza paginación incremental, por lo que listas extremadamente grandes siguen necesitando medir el coste con los datos reales del proyecto.
- Se recomienda probar el resultado compilado con Darklua dentro de Studio: una revisión estática no sustituye la ejecución real de Roblox.
