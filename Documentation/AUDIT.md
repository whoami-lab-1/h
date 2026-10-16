# Auditoría de la versión original

## Problemas funcionales identificados

1. **`mergeDefaults` pierde valores `false`.** La expresión `condición and valor or default` sustituye `false` por el valor predeterminado. La nueva función `Defaults.Merge` selecciona por `~= nil`, clona tablas anidadas y conserva claves de extensión.
2. **Configuración y validación mezcladas.** `DatosDefaultsVerificar` estaba dentro de `DatosDefaults`; la nueva implementación separa datos (`Utilities/Defaults.lua`) y validación (`Utilities/Validation.lua`).
3. **Selección de entorno frágil y específica de executors.** La biblioteca original elegía servicios a partir de `IsStudio()` y referenciaba `cloneref`, `identifyexecutor` y `CoreGui`. Esa detección no representa de forma fiable el contexto de ejecución. La versión nueva utiliza APIs documentadas y monta por defecto en `LocalPlayer.PlayerGui`; permite un `Parent` explícito y falla con un mensaje claro si se llama desde servidor.
4. **Botón de cerrar inerte.** `SalirBoton` era un `ImageLabel`, no un botón accionable. El nuevo control es un botón con opciones `CloseBehavior = "Hide" | "Destroy"`.
5. **Slider con conexiones globales perpetuas.** Cada slider escuchaba `UserInputService.InputChanged` e `InputEnded` y no desconectaba esos eventos. `InputManager` centraliza el seguimiento del puntero y `Cleanup` administra las conexiones compartidas y locales.
6. **Arrastre solo con mouse.** El código original comprobaba únicamente `MouseButton1` y `MouseMovement`. El manejador de entrada admite puntero de mouse y táctil.
7. **Tweakers de botón recreados repetidamente.** `AnimadorBoton` construía un tween por transición y no guardaba conexiones de hover/Activated. `TweenManager` cancela tweens previos por instancia y permite secuencias cancelables.
8. **Secuencias de tweens no cancelaban la continuación.** `Completed:Once` avanzaba la secuencia sin comprobar si se canceló; `Play` repetido podía duplicar la cadena. El controlador de secuencia ahora administra su generación, conexión y tween actual.
9. **Dropdown con estado incoherente.** La versión original podía llamar al callback al inicializar (`Set(ValorActual)`), no normalizaba opciones, no exponía `Get`, `SetValue` consistente, ni una API para actualizar opciones; además conectaba el clic mediante `InputBegan`. La versión nueva utiliza `Activated`, valida valores y no dispara callback durante la configuración inicial.
10. **Estado inicial del slider sin normalizar visualmente.** Se asignaba el texto del valor por separado y no se llamaba a `SetValue` para renderizar barra y handle. Ahora el valor inicial pasa por la misma normalización y renderizado.
11. **Slider sin protección para `Max == Min`, pasos o números inválidos.** La nueva API valida `Max > Min`, paso positivo, números finitos y cuantiza el valor.
12. **APIs inconsistentes.** El código original mezclaba `Set`/`Get`, `SetValue`/`GetValue` y `SetEnabled`; la nueva convención utiliza `GetValue`, `SetValue(value, fireCallback)`, `SetEnabled`, `SetVisible`, `SetText` cuando aplica, y `Destroy`. Los alias mínimos de compatibilidad están disponibles en algunos controles.
13. **Elementos de navegación sin reflujo.** Los botones de navegación se posicionaban con offsets indexados manualmente; al eliminar uno no se recalculaban. La nueva navegación usa `UIListLayout` y `AutomaticCanvasSize` para páginas.
14. **No existía ciclo de vida común.** Ventanas y componentes no tenían un mecanismo uniforme para destruir conexiones y objetos. Se añaden `Cleanup`, `ComponentBase`, `LifecycleManager` y `WindowManager`.

## Decisiones de diseño

- Se eliminan dependencias de APIs propias de executors para que el módulo sea apropiado para proyectos normales de Roblox Studio.
- `Harkening.new()` crea una instancia aislada: su ScreenGui, ventanas, tema, tweens, entrada y ciclo de vida no dependen de variables globales compartidas entre instancias.
- Las ventanas son independientes; un modal cubre el área del ScreenGui solo cuando se solicita. Una `Card`, `Collapsible`, `Form` o `Popup` sirve como contenedor compuesto.
- Los callbacks interactivos se disparan tras una interacción o commit de usuario, no por asignar el valor inicial. `SetValue(value, true)` solicita explícitamente un callback programático; el valor predeterminado `false` evita efectos secundarios inesperados.

## Limitaciones que deben probarse en Studio

Esta entrega no se ha ejecutado dentro del motor Roblox. Deben probarse especialmente las dimensiones táctiles en móviles, el comportamiento del foco/selección con gamepad, las restricciones de tamaño en distintas relaciones de aspecto, las capas de ventanas muy numerosas y la accesibilidad de los diálogos. Algunas combinaciones de opciones (por ejemplo, controles con tamaños personalizados extremos) pueden requerir ajustes visuales propios del proyecto.
