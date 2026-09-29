# Codex Local v3

Codex Local usa **Codex app-server real** y modelos gratuitos de Ollama.

## Inicio automático

`ABRIR.command`:

- detecta Codex dentro de ChatGPT.app, Codex.app o PATH;
- inicia Ollama si hace falta;
- detecta automáticamente `qwen3.5:9b` y `gpt-oss:20b`;
- usa Qwen 3.5 9B como preferido en esta Mac cuando está instalado;
- muestra sólo los modelos locales detectados en el selector de la interfaz;
- mantiene un `CODEX_HOME` aislado del Codex normal;
- abre el servidor únicamente en `127.0.0.1`;
- genera login y secreto de sesión aleatorios;
- permite dos app-server de Codex simultáneos.

## Potencia del agente

La seguridad externa de la aplicación y los permisos del agente son cosas separadas.

La app mantiene localhost, login, cookies estrictas y control de Origin incluso cuando el agente está en modo máximo.

Desde **Security & Session** podés controlar:

- Full Access;
- confirmaciones;
- auto-aprobación de la sesión;
- acceso a Internet.

El botón **TODO AL PALO** activa:

- `danger-full-access`;
- `approval_policy = "never"`;
- auto-aprobación de sesión;
- red habilitada.

**Modo seguro** vuelve a:

- `workspace-write`;
- `approval_policy = "on-request"`;
- aprobación manual;
- red deshabilitada.

También podés escribir en el chat:

- `/max` — potencia máxima para la sesión;
- `/safe` — vuelve al modo seguro;
- `/power` — abre el panel de permisos.

Los ajustes predeterminados para chats nuevos están también en **Settings → Session defaults**.

## Persistencia

La primera ejecución de esta versión migra configuraciones anteriores inseguras a los valores protegidos y deja un backup de `config.toml`.

Después de esa migración, los cambios que hagas desde la interfaz se conservan entre reinicios.

Los datos viven en:

`~/Library/Application Support/Codex Local v3/`

No modifica `~/.codex/config.toml`.

## Antes de abrir

Ejecutá `VERIFICAR.command` para validar los SHA-256 del paquete.

Este build de prueba todavía no está notarizado con Apple Developer ID, por lo que Gatekeeper puede mostrar un aviso la primera vez.

## Archivos

- `ABRIR.command`: inicia Codex Local.
- `CERRAR.command`: detiene el backend.
- `CAMBIAR_CARPETA.command`: cambia la carpeta principal visible en la interfaz.
- `VERIFICAR.command`: comprueba integridad.
- `BUILD_INFO.txt`: commit y workflow de origen.
- `SHA256SUMS.txt`: hashes del contenido.
