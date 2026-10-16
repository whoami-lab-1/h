# Visual refresh — guía rápida

La nueva dirección visual utiliza fondos carbón, superficies diferenciadas por pocos tonos, contornos sutiles y un acento violeta-fucsia inspirado en la referencia. Las reglas de acento ya no se repiten en todas las secciones o tarjetas.

## Ejemplo del estilo

```lua
local ui = Harkening.new({
    Name = "MiProyecto",
    Animation = true,
    Theme = {
        Background = Color3.fromRGB(12, 14, 19),
        Surface = Color3.fromRGB(17, 20, 27),
        SurfaceRaised = Color3.fromRGB(24, 29, 39),
        SurfaceHover = Color3.fromRGB(31, 38, 51),
        SurfaceInset = Color3.fromRGB(9, 11, 16),
        Border = Color3.fromRGB(47, 56, 73),
        BorderSubtle = Color3.fromRGB(34, 41, 54),
        Accent = Color3.fromRGB(190, 108, 255),
        AccentSecondary = Color3.fromRGB(255, 91, 193),
    },
})

local window = ui:CreateWindow({
    Title = "Mi panel",
    Description = "Una interfaz oscura y limpia",
    Icon = "sparkles",
    Size = UDim2.fromOffset(900, 620),
})

local tab = window:AddTab({ Title = "Inventario", Icon = "inventory" })
local section = tab:AddSection({
    Title = "Objetos",
    Description = "Tarjetas con iconos y metadatos",
    Icon = "box",
})
```

## Reglas de acento

- Para una sección corriente, omite `Accent`.
- Usa `Accent = true` solo para una sección protagonista.
- En una tarjeta, también puedes usar `Accent = true`, pero no lo actives en todas las tarjetas de una vista.
- Usa `Icon` para un nombre semántico (`"sword"`, `"gem"`, `"potion"`), un ID numérico, `"rbxassetid://..."` o un descriptor `{ Name = "gem", Color = Color3.fromRGB(...) }`.
- Usa `Image` cuando quieras una ilustración/miniatura real y `Icon` cuando quieras un símbolo compacto. Los assets específicos del proyecto los proporciona el usuario de la biblioteca.

## Ejemplo de catálogo

```lua
section:AddItemCatalog({
    Layout = "Grid",
    Height = 420,
    ActionText = "Inspect",
    Items = {
        {
            Id = "frostblade",
            Name = "Frostblade",
            Description = "Una hoja de evento",
            Category = "Weapon",
            Rarity = "Legendary",
            Icon = { Name = "sword", Color = Color3.fromRGB(145, 187, 255) },
            Amount = 1,
            Price = 1250,
            Currency = "Coins",
            Stats = { Damage = 140, Speed = 1.2 },
            Meta = { Origin = "Winter event" },
        },
        { Id = "azure-gem", Name = "Azure Gem", Category = "Material", Rarity = "Rare", Icon = "gem" },
        { Id = "relic", Name = "Sealed Relic", Icon = "rbxassetid://70534796161944", Locked = true },
    },
})
```

El `IconRenderer` puede interpretar nombres conocidos y assets, pero no descarga iconos de internet ni genera automáticamente una imagen nueva para cualquier objeto. Cuando quieras una ilustración concreta, proporciona su asset ID en `Image` o `Icon`.

## Ejemplo integrado

Importa el paquete compilado en un `ModuleScript` llamado `Harkening` dentro de `ReplicatedStorage`. Ejecuta `Harkening/Examples/VisualRefresh.client.lua` desde `StarterPlayerScripts` para revisar ventanas, catálogo, iconos, controles y notificaciones.


## Iconos en catálogo y componentes de datos

`Icon` acepta nombres como `"sword"`, `"gem"`, `"potion"`, `"package"`, `"paw"`, `"search"` y `"heart"`, IDs numéricos o cadenas `rbxassetid://...`. Los descriptores permiten personalizar el tinte: `{ Name = "gem", Color = Color3.fromRGB(190, 108, 255) }`. Para miniaturas de objetos usa `Image` o `ThumbnailId`; no hace falta usar un icono para reemplazar una imagen real.

`Badge` admite `Icon` y variantes; `MetricCard` admite `Icon` y `SetIcon`; `EmptyState` muestra el icono con un contenedor visual y admite `SetIcon` y una acción opcional mediante `SetAction(text, callback)`.
