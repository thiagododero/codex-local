# Codex Local v3 · prueba Mac segura

Esta rama usa **Codex app-server real** como agente y Ollama como proveedor local.

## Seguridad por defecto

El launcher arranca en modo conservador:

- servidor sólo en `127.0.0.1`;
- `workspace-write`, no `danger-full-access`;
- aprobaciones `on-request`, no `never`;
- red del sandbox desactivada por defecto;
- `FORCE_YOLO` desactivado;
- cookies `SameSite=Strict`;
- mutaciones HTTP requieren `Origin`;
- acciones de terminal/runtime requieren rol owner;
- sólo se expone una carpeta de proyectos, no todo el home;
- los datos de Codex Local viven separados de `~/.codex`.

Si existe `~/Desktop/PROYECTOS`, se usa como raíz permitida. Si no, el primer inicio te pide elegir una carpeta.

El modo Full Access sigue disponible en la interfaz para una sesión concreta si alguna tarea realmente lo necesita, pero ya no se fuerza globalmente.

## Antes de abrir

Ejecutá primero `VERIFICAR.command`. Comprueba los SHA-256 de los archivos contra el manifiesto generado durante el build.

macOS puede mostrar un aviso de Gatekeeper porque este build de prueba no está notarizado con un certificado Apple Developer ID. Eso es distinto de que el archivo sea malware. Para eliminar ese aviso de forma correcta necesitaremos firmar y notarizar una release futura.

## Probar

1. Descomprimí el artifact de **Build Mac Test Package**.
2. Ejecutá `VERIFICAR.command`.
3. Doble clic en `ABRIR.command`.
4. Si aparece login, pegá con ⌘V: la contraseña local queda copiada al portapapeles.
5. `CAMBIAR_CARPETA.command` cambia la única raíz visible para la app.
6. `CERRAR.command` detiene el servidor.
