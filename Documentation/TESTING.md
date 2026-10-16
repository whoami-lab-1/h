# Harkening UI — verificación

## Comprobaciones estáticas realizadas en este paquete

- Se convirtieron los imports internos del formato `require(script.Parent...)` al formato de rutas relativas que usa el bundler de Darklua.
- Se verificaron 141 imports relativos: cada ruta apunta a un módulo fuente existente.
- Se validaron como JSON la configuración de Darklua y la estructura del archivo ZIP.
- Se comprobó que el build ya no depende de `tools/prepare_darklua.py`: invoca directamente `darklua process` desde `Harkening/init.lua`.

Estas comprobaciones no sustituyen la compilación con Darklua ni las pruebas del compilador Luau de Roblox. El binario de Darklua no estaba disponible en el entorno donde se preparó el proyecto, así que el bundle final debe generarse localmente.

## Checklist de compilación y pruebas en Roblox Studio

1. Instala Darklua 0.19.0 con Rokit (`rokit add seaofvoices/darklua`) o instala el binario y pon `darklua` en `PATH`.
2. Ejecuta `build.bat` en Windows o `bash build/build.sh` en Linux/macOS.
3. Confirma que se genere `dist/Harkening.lua` sin errores.
4. Crea un `ModuleScript` llamado `Harkening` y pega el contenido del archivo generado; ejecuta el ejemplo desde un `LocalScript` que haga `require` de ese módulo.
5. Prueba botones con mouse y táctil, sliders con `Min` distinto de cero y `Step` fraccionario; destruye un slider mientras arrastras y comprueba que no siga actualizándose.
6. Abre/cierra y minimiza/restaura ventanas; prueba el botón de cierre, arrastre de barra superior y redimensionamiento.
7. Crea varias ventanas, enfoca cada una y comprueba el orden visual y los botones de título.
8. Prueba dropdowns con opciones añadidas/eliminadas mientras están abiertos, selecciones múltiples y valores de distinto tipo (`5` y `"5"`).
9. Prueba `NumericInput:SetValue(...)`, límites y callbacks al perder foco y mediante asignación programática con `fireCallback = true`.
10. Destruye tarjeta, popup, pestaña, ventana y la instancia completa (`ui:Destroy()`); verifica que las conexiones no sigan actuando.
11. Prueba resolución pequeña, ventanas táctiles, foco/gamepad y cambios de cámara.
12. Prueba modales superpuestos, cierre por fondo, callbacks confirmado/cancelado e interacción con ventanas detrás.
13. Prueba temas distintos y verifica que los cambios visuales se reflejen como está documentado.
14. Confirma que el HUD automático aparece sin método manual; ocúltalo, muéstralo, cambia estilo/posición, desactívalo y vuelve a habilitarlo.
15. Verifica que el nombre/icono del juego se resuelva con valores de respaldo y que la marca de agua no duplique conexiones al reinicializar la misma instancia.
16. Prueba `ItemCatalog` con más de `MaxRender` registros, búsqueda, filtro, ordenación, IDs duplicados y acción de cargar más.
17. Comprueba ordenación y selección de `DataTable`, expandir/seleccionar/destruir `TreeView`, y arrastrar/destruir `RangeSlider` durante un gesto.

No marques las pruebas del motor como completas hasta ejecutarlas en Studio.
