# Harkening UI 2.2.1 — Visual Refresh

## Interfaz
- Revisión de la paleta oscura con superficies más limpias y bordes menos agresivos.
- Sombra externa sincronizada con posición, tamaño, visibilidad y orden de foco de cada ventana.
- Degradado suave en la barra superior y una jerarquía visual más consistente.
- Menos líneas de acento repetidas: secciones y tarjetas muestran el acento únicamente cuando `Accent = true`.
- Feedback más claro en los botones de la barra superior.

## Catálogo
- Se amplió la normalización de campos comunes de imagen/icono.
- Se ampliaron variantes de rareza en inglés y español, y la inferencia de iconos para nombres/categorías de objetos en ambos idiomas.
- Las etiquetas de rareza, categoría, equipado, bloqueado y etiquetas personalizadas quedan limitadas para no desbordar las tarjetas.
- Se corrigió la capa de selección para que las acciones y botones internos mantengan prioridad de interacción.
- Se añadió el icono de ordenación en la barra de herramientas del catálogo y se conservan los tintes definidos en descriptores de icono.
- El hover muestra mejor el borde/estado seleccionado.

## Iconos
- Los controles principales reutilizan IDs de iconos que ya aparecen en la UI de referencia.
- Se añadieron alias semánticos y glifos para más acciones y categorías.

## Validación
Este paquete se revisó de forma estática. La compilación de Darklua y la interacción real deben comprobarse en Roblox Studio.
