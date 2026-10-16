# Harkening UI v2

Framework modular de interfaz para Roblox Luau. Su código fuente se mantiene separado por responsabilidades y Darklua lo empaqueta en un único archivo distribuible.

## Compilar un único archivo

**Instalación:** usa `rokit add seaofvoices/darklua` (versión fijada en `rokit.toml`) o instala el binario oficial.

**Windows:** ejecuta `build.bat`.

**Linux/macOS:** ejecuta `bash build/build.sh`.

Ambos producen `dist/Harkening.lua`. Pega ese contenido en un `ModuleScript` llamado `Harkening` en Roblox Studio y cárgalo mediante `require(...)`.

Consulta [`Documentation/DARKLUA.md`](Documentation/DARKLUA.md) para el flujo de compilación y [`Documentation/API.md`](Documentation/API.md) para la API.

## Desarrollo

Edita los módulos de `Harkening/`. Los `require` internos usan rutas relativas para que Darklua los resuelva en `build/darklua.config.json`. El archivo `dist/Harkening.lua` es generado: no se edita manualmente.

## Verificación

La ruta de bundling se ha configurado para invocar Darklua directamente, sin un script Python que modifique los imports. Darklua no está instalado en el entorno donde se preparó este paquete, por lo que debes ejecutar la compilación en tu máquina y probar el resultado dentro de Roblox Studio. Usa `Documentation/TESTING.md` como lista de validación funcional.
