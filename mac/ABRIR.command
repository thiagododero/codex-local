#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUPPORT_DIR="$HOME/Library/Application Support/Codex Local v3"
CODEX_HOME_LOCAL="$SUPPORT_DIR/codex-home"
DATA_DIR="$SUPPORT_DIR/data"
RUNTIME_DIR="$SUPPORT_DIR/runtime"
LOG_DIR="$SUPPORT_DIR/logs"
MODEL_FILE="$SUPPORT_DIR/model.txt"
PASSWORD_FILE="$SUPPORT_DIR/ui-password.txt"
SECRET_FILE="$SUPPORT_DIR/session-secret.txt"
PID_FILE="$RUNTIME_DIR/backend.pid"
LOG_FILE="$LOG_DIR/backend.log"
PORT=4173

mkdir -p "$CODEX_HOME_LOCAL" "$DATA_DIR" "$RUNTIME_DIR" "$LOG_DIR"
chmod 700 "$SUPPORT_DIR" "$CODEX_HOME_LOCAL" "$DATA_DIR" "$RUNTIME_DIR" "$LOG_DIR" 2>/dev/null || true

find_codex() {
  local candidates=(
    "/Applications/ChatGPT.app/Contents/Resources/codex-cli/bin/codex"
    "/Applications/ChatGPT.app/Contents/Resources/codex-cli/CodexCLI.app/Contents/MacOS/codex"
    "/Applications/Codex.app/Contents/Resources/codex"
    "/Applications/Codex.app/Contents/Resources/codex-cli/bin/codex"
    "$HOME/.local/bin/codex"
    "/opt/homebrew/bin/codex"
    "/usr/local/bin/codex"
  )
  local c
  for c in "$candidates[@]"; do
    if [[ -x "$c" ]]; then echo "$c"; return 0; fi
  done
  if command -v codex >/dev/null 2>&1; then command -v codex; return 0; fi
  return 1
}

find_ollama() {
  local candidates=(
    "/Applications/Ollama.app/Contents/Resources/ollama"
    "/opt/homebrew/bin/ollama"
    "/usr/local/bin/ollama"
  )
  local c
  for c in "$candidates[@]"; do
    if [[ -x "$c" ]]; then echo "$c"; return 0; fi
  done
  if command -v ollama >/dev/null 2>&1; then command -v ollama; return 0; fi
  return 1
}

CODEX_BIN="$(find_codex || true)"
if [[ -z "$CODEX_BIN" ]]; then
  echo "❌ No encontré Codex CLI en esta Mac."
  read "?Enter para cerrar..."
  exit 1
fi

OLLAMA_BIN="$(find_ollama || true)"
if [[ -z "$OLLAMA_BIN" ]]; then
  echo "❌ No encontré Ollama."
  read "?Enter para cerrar..."
  exit 1
fi

if ! curl -fsS --max-time 2 http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
  echo "Iniciando Ollama…"
  open -a Ollama >/dev/null 2>&1 || true
  for _ in {1..30}; do
    curl -fsS --max-time 2 http://127.0.0.1:11434/api/tags >/dev/null 2>&1 && break
    sleep 1
  done
fi

if ! curl -fsS --max-time 2 http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
  echo "❌ Ollama no respondió en http://127.0.0.1:11434"
  read "?Enter para cerrar..."
  exit 1
fi

MODEL="qwen3.5:9b"
[[ -f "$MODEL_FILE" ]] && MODEL="$(cat "$MODEL_FILE" | tr -d '\r\n')"

if ! "$OLLAMA_BIN" list 2>/dev/null | awk 'NR>1 {print $1}' | grep -Fxq "$MODEL"; then
  echo "No encontré el modelo local $MODEL."
  read "ANSWER?¿Querés descargarlo ahora con Ollama? [S/n] "
  ANSWER="\${ANSWER:-S}"
  if [[ "$ANSWER" =~ ^[SsYy]$ ]]; then
    "$OLLAMA_BIN" pull "$MODEL"
  else
    exit 1
  fi
fi

echo "$MODEL" > "$MODEL_FILE"

cat > "$CODEX_HOME_LOCAL/config.toml" <<EOF
model = "$MODEL"
model_provider = "codex-local-ollama"
model_context_window = 32768
approval_policy = "never"
sandbox_mode = "danger-full-access"

[model_providers.codex-local-ollama]
name = "Codex Local · Ollama"
base_url = "http://127.0.0.1:11434/v1"
wire_api = "responses"
requires_openai_auth = false
request_max_retries = 2
stream_max_retries = 4
stream_idle_timeout_ms = 3600000
supports_websockets = false
EOF

if [[ ! -f "$PASSWORD_FILE" ]]; then
  openssl rand -hex 10 > "$PASSWORD_FILE"
  chmod 600 "$PASSWORD_FILE"
fi
UI_PASSWORD="$(cat "$PASSWORD_FILE" | tr -d '\r\n')"

if [[ ! -f "$SECRET_FILE" ]]; then
  openssl rand -hex 32 > "$SECRET_FILE"
  chmod 600 "$SECRET_FILE"
fi
SESSION_SECRET="$(cat "$SECRET_FILE" | tr -d '\r\n')"

BACKEND_BIN="$ROOT_DIR/dist/backend/aarch64-apple-darwin/backend"
if [[ ! -x "$BACKEND_BIN" ]]; then
  echo "❌ Falta el backend precompilado para Apple Silicon."
  echo "Descargá el ZIP generado por GitHub Actions para la rama codex-local-v3."
  read "?Enter para cerrar..."
  exit 1
fi

if [[ -f "$PID_FILE" ]]; then
  OLD_PID="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [[ -n "$OLD_PID" ]] && kill -0 "$OLD_PID" >/dev/null 2>&1; then
    printf "%s" "$UI_PASSWORD" | pbcopy
    open "http://127.0.0.1:$PORT/"
    echo "✅ Ya estaba abierto. Contraseña copiada al portapapeles."
    exit 0
  fi
  rm -f "$PID_FILE"
fi

PROFILES_JSON="$(CODEX_HOME_LOCAL="$CODEX_HOME_LOCAL" DATA_DIR="$DATA_DIR" python3 - <<'PY'
import json, os
print(json.dumps([{
  "id": "local",
  "label": "Local · Ollama",
  "codexHome": os.environ["CODEX_HOME_LOCAL"],
  "dataDir": os.path.join(os.environ["DATA_DIR"], "profiles", "local"),
}]))
PY
)"

echo "Iniciando Codex Local v3…"
(
  cd "$ROOT_DIR"
  env \
    HOST="127.0.0.1" \
    PORT="$PORT" \
    CODEX_WEBUI_BASE_PATH="/" \
    CODEX_WEBUI_CODEX_BIN="$CODEX_BIN" \
    CODEX_HOME="$CODEX_HOME_LOCAL" \
    CODEX_WEBUI_DATA_DIR="$DATA_DIR" \
    CODEX_WEBUI_DEFAULT_PROFILE_ID="local" \
    CODEX_WEBUI_PROFILES_JSON="$PROFILES_JSON" \
    CODEX_WEBUI_ALLOWED_ROOTS="$HOME" \
    CODEX_WEBUI_PASSWORD="$UI_PASSWORD" \
    CODEX_WEBUI_OWNER_PASSWORD="$UI_PASSWORD" \
    CODEX_WEBUI_SESSION_SECRET="$SESSION_SECRET" \
    CODEX_WEBUI_FORCE_YOLO="true" \
    CODEX_WEBUI_PER_SESSION_APP_SERVERS="true" \
    CODEX_WEBUI_MAX_APP_SERVERS="2" \
    CODEX_WEBUI_APP_SERVER_TIMEOUT_SECONDS="3600" \
    CODEX_WEBUI_APP_SERVER_HANDOFF="true" \
    "$BACKEND_BIN" >> "$LOG_FILE" 2>&1 &
  echo $! > "$PID_FILE"
)

PID="$(cat "$PID_FILE")"
for _ in {1..50}; do
  curl -fsS --max-time 2 "http://127.0.0.1:$PORT/healthz" >/dev/null 2>&1 && break
  if ! kill -0 "$PID" >/dev/null 2>&1; then
    echo "❌ El backend terminó antes de arrancar."
    tail -n 40 "$LOG_FILE" || true
    read "?Enter para cerrar..."
    exit 1
  fi
  sleep 0.4
done

if ! curl -fsS --max-time 2 "http://127.0.0.1:$PORT/healthz" >/dev/null 2>&1; then
  echo "❌ El servidor no quedó listo a tiempo."
  tail -n 40 "$LOG_FILE" || true
  read "?Enter para cerrar..."
  exit 1
fi

printf "%s" "$UI_PASSWORD" | pbcopy
open "http://127.0.0.1:$PORT/"

echo ""
echo "✅ Codex Local v3 está abierto."
echo "Motor: $("$CODEX_BIN" --version 2>/dev/null || echo Codex)"
echo "Modelo: $MODEL · Ollama"
echo "Contexto: 32k"
echo "App servers simultáneos: 2"
echo "Acceso: danger-full-access / aprobación never"
echo "Contraseña local copiada al portapapeles."
echo "Podés cerrar esta Terminal."
sleep 2
