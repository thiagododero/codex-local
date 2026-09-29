# Codex Local v3 · prueba Mac

Esta rama usa **Codex app-server real** como agente y Ollama como proveedor local.

El launcher detecta Codex y Ollama, crea un CODEX_HOME aislado, usa qwen3.5:9b a 32k, configura reintentos de stream, habilita full access y permite 2 app-servers simultáneos.

## Probar

1. Descargá el artifact de la Action **Build Mac Test Package** de la rama `codex-local-v3`.
2. Descomprimilo.
3. Doble clic en `ABRIR.command`.
4. Si aparece login, pegá con ⌘V: la contraseña local queda copiada al portapapeles.
5. `CERRAR.command` detiene el servidor.

Los datos viven en `~/Library/Application Support/Codex Local v3/` y no pisan `~/.codex/config.toml`.
