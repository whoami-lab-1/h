# Harkening UI 2.2.2 — Visual refresh

## Diseño y jerarquía

- Refinada la paleta oscura hacia carbón/grafito, con azul-violeta como acento reservado para selección, foco y acciones primarias.
- Reducidas las líneas decorativas repetidas: `Section` y `Card` no dibujan una regla de acento salvo que `Accent = true` sea explícito.
- Suavizados contornos de ventana, tarjetas y paneles para distinguir mejor el contenido sin crear demasiadas cajas.
- Mejorada la cabecera de ventana con esquinas superiores redondeadas y un acento superior más corto.
- Añadidas sombras externas sincronizadas con el tamaño, posición, visibilidad y ZIndex en ventanas, popups y modales.
- Homogeneizados los fondos elevados, campos incrustados, estados de hover y contraste del texto.

## Catálogo e iconos

- Corregido el orden de definición entre `rarityColor` e `iconColor` para que los iconos inferidos no accedan a una función local inexistente.
- Añadidos glifos para todos los nombres semánticos usados por la inferencia de iconos del catálogo (`book`, `food`, `car`, `key`, `wrench`).
- El catálogo acepta `Icon` como nombre semántico, número/ID de asset, cadena `rbxassetid://...` o descriptor como `{ Name = "gem", Color = Color3.fromRGB(...) }`.
- Conservados los aliases de datos (`ThumbnailId`, `ImageAsset`, `Quality`, `Tier`, `Count`, `Quantity`, `Cost`, `Worth`) y los colores por rareza.
- Mejorada la composición de tarjetas para que imagen/icono, nombre, descripción, rareza, favorito, bloqueado, precio y acciones compartan un mismo estilo.

## Compilación y compatibilidad

- La fuente sigue modular y usa imports relativos para el bundling nativo con Darklua.
- Se agregó `Harkening/Examples/VisualRefresh.client.lua` para visualizar la identidad y probar el catálogo con iconos semánticos, assets y tintes.
- No se eliminó la API previa: los cambios visuales se aplican sobre los módulos que ya existían.
