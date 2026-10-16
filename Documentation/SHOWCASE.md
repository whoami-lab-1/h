# Showcase completo de Harkening UI v2

El ejemplo ejecutable está en `Harkening/Examples/Showcase.client.lua`.

## Cómo ejecutarlo

1. Ejecuta `build.bat` en la raíz del repositorio (o `bash build/build.sh` en Linux/macOS).
2. Copia el archivo `dist/Harkening.lua` generado a un `ModuleScript` llamado `Harkening` dentro de `ReplicatedStorage`.
3. Crea un `LocalScript` en `StarterPlayer > StarterPlayerScripts`.
4. Copia el contenido de `Harkening/Examples/Showcase.client.lua` en ese `LocalScript`.
5. Ejecuta Play en Roblox Studio y prueba las pestañas. Las acciones de demostración escriben valores en Output.

El ejemplo requiere ejecución en cliente porque usa `Players.LocalPlayer` y GUI local.

## Cobertura del ejemplo

- Framework: `Harkening.new`, opciones de inicialización, tema, suscripción al tema y lista de componentes disponibles.
- Ventanas: tamaño/posición, restricciones, arrastrar, redimensionar, minimizar, foco, mostrar/ocultar, descripción/título, pestañas, restaurar tamaño al viewport y administración por `Id`.
- Controles: `Button`, `Toggle`, `Slider`, `Dropdown`, `MultiSelect`, `TextInput`, `NumericInput`, `Segmented` y `Keybind`.
- Componentes informativos: `Label`, `Paragraph`, `Divider`, `Image` y `Progress`.
- Compuestos: `Card`, `Collapsible` y `Form`, incluyendo campos, validación y envío.
- Elementos flotantes: `Modal`, `Popup` y `Notification` temporal o persistente.
- Métodos programáticos: `GetValue`, `SetValue`, `SetEnabled`, `SetVisible`, `SetText`, `SetDescription`, `SetTitle`, `SetImage`, `Open`, `Close`, `Destroy`, entre otros.
- Dropdown dinámico: `AddOption`, `RemoveOption`, `SetOptions`, `ClearOptions`, `Open`, `Close`, `ToggleOpen` e `IsOpen`.
- Composición avanzada: `ui.Components:Create(...)` dentro de un contenedor GUI creado por el proyecto.
- Limpieza: destrucción de componentes, ventana secundaria y framework completo.

## Consideraciones

Este archivo es un ejemplo de integración, no una suite automatizada de pruebas. Revisa el comportamiento en Roblox Studio en mouse, táctil y distintos tamaños de pantalla.

En la implementación actual, el callback de `Keybind` se invoca cuando se reasigna una tecla; todavía no funciona como un listener de atajo que ejecute el callback cada vez que se presiona la tecla asignada.

`SetTheme` cambia la paleta del tema para los componentes creados después. No reconstruye automáticamente los controles existentes.
