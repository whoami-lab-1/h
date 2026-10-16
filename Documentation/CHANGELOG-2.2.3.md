# Harkening UI 2.2.3 — Visual polish

## Dirección visual

- Se adopta una paleta carbón con acentos violeta/fucsia inspirada en la referencia, pero con menos elementos decorativos repetidos.
- Las líneas de acento quedan reservadas para secciones y tarjetas destacadas, en lugar de aparecer en todos los contenedores.
- La ventana conserva un encabezado ordenado, navegación con iconos, sombra exterior sincronizada y bordes de bajo contraste.
- Los controles del catálogo mantienen estados de selección y hover, tarjetas con metadatos y un inspector para detalles.

## Componentes

- `Badge`: variantes coherentes (`Accent`, `Success`, `Warning`, `Danger`, `Info`, `Neutral`), icono opcional y actualización mediante `SetIcon`, `SetText` y `SetVariant`.
- `MetricCard`: presentación de métricas con icono opcional, tile de icono, jerarquía de texto y métodos `SetTitle`, `SetValue`, `SetDescription` y `SetIcon`.
- `EmptyState`: icono renderizado por el resolvedor compartido y acción opcional. Incluye `SetIcon`, `SetTitle`, `SetDescription` y `SetAction`.
- `IconRenderer`: mantiene compatibilidad con assets e incorpora nombres semánticos; se mejora el glifo de mascota/pata.

## Compatibilidad y validación

- Se conservan los nombres públicos existentes. Los métodos nuevos son aditivos.
- El catálogo sigue aceptando `Image`/`ThumbnailId` para imágenes reales e `Icon` para símbolos compactos. Los assets específicos se deben proporcionar mediante sus IDs de Roblox.
- No se pudo ejecutar el framework dentro de Roblox Studio ni compilar con Darklua en el entorno de preparación. Se deben ejecutar los pasos de `Documentation/TESTING.md` antes de publicación.
