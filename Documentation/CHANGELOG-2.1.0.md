# Harkening UI 2.1.0 — registro de cambios

## Integración y arranque

- Marca de agua/HUD integrada automáticamente en `Harkening.new()` y administrada por la misma instancia del framework.
- Configuración para título, texto, logo, nombre/icono del juego, FPS, reloj, estado, posición, estilo, ancho y transparencia.
- API pública `SetWatermarkVisible`, `UpdateWatermark`, `GetWatermark` y `SetStatus`, más alias en español.
- Prevención de instancias duplicadas con el mismo nombre y padre; el framework destruye la instancia anterior antes de inicializar otra.
- El HUD resuelve metadatos del juego en segundo plano y mantiene valores de respaldo.

## Componentes añadidos

- `Badge`, `StatusIndicator`, `MetricCard`, `KeyValueList`.
- `Checkbox`, `RadioGroup`, `RangeSlider`, `TextArea`, `ColorPicker`.
- `ItemCatalog`, `DataTable`, `TreeView`, `Carousel`, `LogViewer`, `EmptyState`.
- Búsqueda en dropdown, metadatos por opción, estados deshabilitados y límites para selección múltiple.
- Variantes de botones, icon-only y estado de carga.
- Métodos `Add...` consistentes para composición en sección, tarjeta, panel expandible y popup.

## Rendimiento y ciclo de vida

- Se desconectan listeners por fila al actualizar catálogo, tabla o árbol.
- El cálculo FPS se actualiza cada medio segundo en lugar de en cada frame de presentación.
- `Destroy()` cancela tweens y elimina las conexiones registradas por los controladores.
- Las listas del catálogo usan carga incremental por lotes; aún no implementan virtualización real por viewport.

## Verificación

El empaquetado de Darklua está configurado y las rutas relativas fueron verificadas estáticamente. Este paquete no se debe considerar validado en el motor hasta compilarlo con Darklua y ejecutar `Documentation/TESTING.md` en Roblox Studio.
