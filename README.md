# Harkening UI v2

Framework modular de interfaz para Roblox Luau (versión 2.2.3). Esta revisión refina la ventana, los controles, la navegación y el catálogo con superficies carbón, contornos suaves y acentos violeta-fucsia inspirados en la referencia. Su código fuente se mantiene separado por responsabilidades y Darklua lo empaqueta en un único archivo distribuible.

## Compilar un único archivo

**Instalación:** usa `rokit add seaofvoices/darklua` (versión fijada en `rokit.toml`) o instala el binario oficial.

**Windows:** ejecuta `build.bat`.

**Linux/macOS:** ejecuta `bash build/build.sh`.

Ambos producen `dist/Harkening.lua`. Pega ese contenido en un `ModuleScript` llamado `Harkening` en Roblox Studio y cárgalo mediante `require(...)`.

Consulta [`Documentation/CHANGELOG-2.2.3.md`](Documentation/CHANGELOG-2.2.3.md) para los últimos cambios visuales. También puedes revisar [`Documentation/VISUAL-REFRESH.md`](Documentation/VISUAL-REFRESH.md) para el rediseño y catálogo, [`Documentation/DARKLUA.md`](Documentation/DARKLUA.md) para el flujo de compilación, [`Documentation/API.md`](Documentation/API.md) para la API y [`Documentation/ADVANCED.md`](Documentation/ADVANCED.md) para marca de agua, catálogos, tablas y componentes avanzados.

## Revisión visual 2.2.3

- Menos líneas de acento repetidas; se reservan para secciones destacadas.
- Ventana con sombra externa sincronizada, encabezado mejor jerarquizado e iconos consistentes.
- Catálogo con imagen o icono, rareza, cantidad, estado, favorito, acción y panel de detalles.
- `Badge`, `MetricCard` y `EmptyState` admiten iconos y métodos para actualizar su contenido.
- Paleta violeta/fucsia más cercana al estilo de referencia, manteniendo las superficies oscuras.

## Desarrollo

Edita los módulos de `Harkening/`. Los `require` internos usan rutas relativas para que Darklua los resuelva en `build/darklua.config.json`. El archivo `dist/Harkening.lua` es generado: no se edita manualmente.

## Verificación

La ruta de bundling se ha configurado para invocar Darklua directamente, sin un script Python que modifique los imports. Darklua no está instalado en el entorno donde se preparó este paquete, por lo que debes ejecutar la compilación en tu máquina y probar el resultado dentro de Roblox Studio. Usa `Documentation/TESTING.md` como lista de validación funcional.
## Ejemplos

- `Harkening/Examples/Basic.client.lua`: introducción breve.
- `Harkening/Examples/Showcase.client.lua`: ejemplo amplio de componentes, ventanas, formularios, popup, modal, tema, fábrica y ciclo de vida.
- `Harkening/Examples/Advanced.client.lua`: ejemplo avanzado de marca de agua automática, catálogo de objetos, tabla ordenable, árbol, carrusel, entradas y composición.
- `Harkening/Examples/VisualRefresh.client.lua`: ejemplo del nuevo estilo oscuro, estados visuales y catálogo con iconos semánticos, assets, rarezas y acciones.
- Consulta `Documentation/SHOWCASE.md` para importarlo en Roblox Studio.
