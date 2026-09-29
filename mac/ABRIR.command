#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUPPORT_DIR="$HOME/Library/Application Support/Codex Local v3"
CODEX_HOME_LOCAL="$SUPPORT_DIR/codex-home"
DATA_DIR="$SUPPORT_DIR/data"
RUNTIME_DIR="$SUPPORT_DIR/runtime"
LOG_DIR="$SUPPORT_DIR/logs"
MODEL_FILE="$SUPPORT_DIR/model.txt"
PROJECT_ROOT_FILE="$SUPPORT_DIR/projects-root.txt"
CONFIG_VERSION_FILE="$SUPPORT_DIR/config-version.txt"
SECRET_FILE="$SUPPORT_DIR/session-secret.txt"
PID_FILE="$RUNTIME_DIR/backend.pid"
RUNNING_BUILD_FILE="$RUNTIME_DIR/running-build.txt"
LOG_FILE="$LOG_DIR/backend.log"
PORT=4173
CONFIG_VERSION=4

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

choose_projects_root() {
  if [[ -d "$HOME/Desktop/PROYECTOS" ]]; then
    echo "$HOME/Desktop/PROYECTOS"
    return 0
  fi
  osascript <<'APPLESCRIPT' | sed 's:/*$::'
try
  set selectedFolder to choose folder with prompt "Elegí la carpeta principal de proyectos para Codex Local"
  return POSIX path of selectedFolder
on error number -128
  return ""
end try
APPLESCRIPT
}

CODEX_BIN="$(find_codex || true)"
OLLAMA_BIN="$(find_ollama || true)"

if [[ -z "$CODEX_BIN" ]]; then
  echo "❌ No encontré Codex CLI."
  read "?Enter para cerrar..."
  exit 1
fi
if [[ -z "$OLLAMA_BIN" ]]; then
  echo "❌ No encontré Ollama."
  read "?Enter para cerrar..."
  exit 1
fi

if [[ ! -f "$PROJECT_ROOT_FILE" ]]; then
  PROJECT_ROOT="$(choose_projects_root || true)"
  if [[ -z "$PROJECT_ROOT" ]]; then
    echo "❌ No se eligió una carpeta de proyectos."
    exit 1
  fi
  printf "%s\n" "$PROJECT_ROOT" > "$PROJECT_ROOT_FILE"
  chmod 600 "$PROJECT_ROOT_FILE"
fi

PROJECT_ROOT="$(cat "$PROJECT_ROOT_FILE" | tr -d '\r\n')"
if [[ ! -d "$PROJECT_ROOT" ]]; then
  echo "❌ La carpeta permitida ya no existe: $PROJECT_ROOT"
  echo "Usá CAMBIAR_CARPETA.command y reiniciá."
  read "?Enter para cerrar..."
  exit 1
fi
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd -P)"

if ! curl -fsS --max-time 2 http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
  echo "Iniciando Ollama…"
  open -a Ollama >/dev/null 2>&1 || true
  for _ in {1..30}; do
    curl -fsS --max-time 2 http://127.0.0.1:11434/api/tags >/dev/null 2>&1 && break
    sleep 1
  done
fi

if ! curl -fsS --max-time 2 http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
  echo "❌ Ollama no respondió en 127.0.0.1:11434"
  read "?Enter para cerrar..."
  exit 1
fi

INSTALLED_MODELS="$("$OLLAMA_BIN" list 2>/dev/null | awk 'NR>1 {print $1}')"

config_model() {
  if [[ -f "$CODEX_HOME_LOCAL/config.toml" ]]; then
    awk -F'"' '/^model = "/ { print $2; exit }' "$CODEX_HOME_LOCAL/config.toml"
  fi
}

MODEL="$(config_model || true)"
if [[ -z "$MODEL" ]] && [[ -f "$MODEL_FILE" ]]; then
  MODEL="$(cat "$MODEL_FILE" | tr -d '\r\n')"
fi

if [[ -z "$MODEL" ]] || ! printf "%s\n" "$INSTALLED_MODELS" | grep -Fxq "$MODEL"; then
  if printf "%s\n" "$INSTALLED_MODELS" | grep -Fxq "qwen3.5:9b"; then
    MODEL="qwen3.5:9b"
  elif printf "%s\n" "$INSTALLED_MODELS" | grep -Fxq "gpt-oss:20b"; then
    MODEL="gpt-oss:20b"
  else
    MODEL="qwen3.5:9b"
    echo "No encontré Qwen 3.5 9B ni gpt-oss 20B."
    read "ANSWER?¿Descargar qwen3.5:9b ahora? [S/n] "
    if [[ -z "$ANSWER" ]]; then ANSWER="S"; fi
    if [[ "$ANSWER" =~ ^[SsYy]$ ]]; then
      "$OLLAMA_BIN" pull "$MODEL"
      INSTALLED_MODELS="$("$OLLAMA_BIN" list 2>/dev/null | awk 'NR>1 {print $1}')"
    else
      exit 1
    fi
  fi
fi
printf "%s\n" "$MODEL" > "$MODEL_FILE"

LOCAL_MODEL_NAMES="$(printf "%s\n" "$INSTALLED_MODELS" | grep -E '^(qwen3\.5|gpt-oss)(:|$)' || true)"
if ! printf "%s\n" "$LOCAL_MODEL_NAMES" | grep -Fxq "$MODEL"; then
  LOCAL_MODEL_NAMES="$(printf "%s\n%s\n" "$MODEL" "$LOCAL_MODEL_NAMES" | awk 'NF && !seen[$0]++')"
fi

LOCAL_MODELS_JSON="$(LOCAL_MODEL_NAMES="$LOCAL_MODEL_NAMES" SELECTED_MODEL="$MODEL" python3 - <<'PY'
import json, os
names = [line.strip() for line in os.environ.get("LOCAL_MODEL_NAMES", "").splitlines() if line.strip()]
selected = os.environ.get("SELECTED_MODEL", "")
items = []
for name in names:
    if name.startswith("qwen3.5"):
        display = "Qwen 3.5 9B · Local" if name == "qwen3.5:9b" else f"{name} · Local"
        desc = "Rápido y recomendado para esta Mac."
    elif name.startswith("gpt-oss"):
        display = f"{name} · Local"
        desc = "Modelo local más pesado; puede ser más lento con 16 GB."
    else:
        display = f"{name} · Local"
        desc = "Modelo local vía Ollama."
    items.append({
        "id": name,
        "displayName": display,
        "description": desc,
        "defaultReasoningEffort": "medium",
        "supportedReasoningEfforts": ["low", "medium", "high"],
        "additionalSpeedTiers": [],
        "inputModalities": ["text"],
        "supportsPersonality": True,
        "isDefault": name == selected,
    })
print(json.dumps(items, ensure_ascii=False))
PY
)"

CURRENT_CONFIG_VERSION="$(cat "$CONFIG_VERSION_FILE" 2>/dev/null || true)"
if [[ "$CURRENT_CONFIG_VERSION" != "$CONFIG_VERSION" ]]; then
  if [[ -f "$CODEX_HOME_LOCAL/config.toml" ]]; then
    cp "$CODEX_HOME_LOCAL/config.toml" "$CODEX_HOME_LOCAL/config.toml.pre-v$CONFIG_VERSION.bak"
  fi
  cat > "$CODEX_HOME_LOCAL/config.toml" <<EOF
model = "$MODEL"
model_provider = "codex-local-ollama"
model_context_window = 32768
approval_policy = "on-request"
sandbox_mode = "workspace-write"
web_search = "disabled"

[sandbox_workspace_write]
network_access = false

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
  printf "%s\n" "$CONFIG_VERSION" > "$CONFIG_VERSION_FILE"
else
  if ! grep -q '^\[model_providers\.codex-local-ollama\]' "$CODEX_HOME_LOCAL/config.toml"; then
    cat >> "$CODEX_HOME_LOCAL/config.toml" <<'EOF'

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
  fi
fi

if [[ ! -f "$SECRET_FILE" ]]; then
  openssl rand -hex 32 > "$SECRET_FILE"
  chmod 600 "$SECRET_FILE"
fi
SESSION_SECRET="$(cat "$SECRET_FILE" | tr -d '\r\n')"

BACKEND_BIN="$ROOT_DIR/dist/backend/aarch64-apple-darwin/backend"
if [[ ! -x "$BACKEND_BIN" ]]; then
  echo "❌ Falta el backend precompilado."
  exit 1
fi

PACKAGE_BUILD_COMMIT="$(awk -F= '/^source_commit=/ {print $2; exit}' "$ROOT_DIR/BUILD_INFO.txt" 2>/dev/null || true)"
RUNNING_BUILD_COMMIT="$(cat "$RUNNING_BUILD_FILE" 2>/dev/null || true)"

if [[ -f "$PID_FILE" ]]; then
  OLD_PID="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [[ -n "$OLD_PID" ]] && kill -0 "$OLD_PID" >/dev/null 2>&1; then
    if [[ -n "$PACKAGE_BUILD_COMMIT" && "$RUNNING_BUILD_COMMIT" == "$PACKAGE_BUILD_COMMIT" ]]; then
      open "http://127.0.0.1:$PORT/"
      echo "✅ Esta misma build de Codex Local ya estaba ejecutándose."
      exit 0
    fi

    echo "Actualizando el backend en ejecución…"
    kill "$OLD_PID" >/dev/null 2>&1 || true
    for _ in {1..40}; do
      kill -0 "$OLD_PID" >/dev/null 2>&1 || break
      sleep 0.2
    done
  fi
  rm -f "$PID_FILE" "$RUNNING_BUILD_FILE"
fi

PORT_PID="$(lsof -nP -tiTCP:$PORT -sTCP:LISTEN 2>/dev/null | head -n 1 || true)"
if [[ -n "$PORT_PID" ]]; then
  echo "❌ El puerto $PORT ya está ocupado por otro proceso (PID $PORT_PID)."
  echo "No voy a cerrarlo automáticamente porque podría no pertenecer a Codex Local."
  read "?Enter para cerrar..."
  exit 1
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

echo "Iniciando Codex Local…"
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
    CODEX_WEBUI_ALLOWED_ROOTS="$PROJECT_ROOT" \
    CODEX_WEBUI_LOCAL_MODELS_JSON="$LOCAL_MODELS_JSON" \
    CODEX_WEBUI_DEFAULT_MODEL="$MODEL" \
    CODEX_WEBUI_SESSION_SECRET="$SESSION_SECRET" \
    CODEX_WEBUI_REQUIRE_OWNER="false" \
    CODEX_WEBUI_REQUIRE_ORIGIN_HEADER="true" \
    CODEX_WEBUI_COOKIE_SAMESITE="strict" \
    CODEX_WEBUI_TRUST_PROXY_HEADERS="false" \
    CODEX_WEBUI_ENABLE_SYSTEM_SHUTDOWN="false" \
    CODEX_WEBUI_PER_SESSION_APP_SERVERS="true" \
    CODEX_WEBUI_MAX_APP_SERVERS="2" \
    CODEX_WEBUI_APP_SERVER_TIMEOUT_SECONDS="3600" \
    CODEX_WEBUI_APP_SERVER_HANDOFF="true" \
    "$BACKEND_BIN" >> "$LOG_FILE" 2>&1 &
  echo $! > "$PID_FILE"
)

PID="$(cat "$PID_FILE")"
if [[ -n "$PACKAGE_BUILD_COMMIT" ]]; then
  printf "%s\n" "$PACKAGE_BUILD_COMMIT" > "$RUNNING_BUILD_FILE"
else
  printf "unknown\n" > "$RUNNING_BUILD_FILE"
fi
chmod 600 "$RUNNING_BUILD_FILE"

for _ in {1..50}; do
  curl -fsS --max-time 2 "http://127.0.0.1:$PORT/healthz" >/dev/null 2>&1 && break
  if ! kill -0 "$PID" >/dev/null 2>&1; then
    echo "❌ El backend terminó antes de arrancar."
    tail -n 50 "$LOG_FILE" || true
    read "?Enter para cerrar..."
    exit 1
  fi
  sleep 0.4
done

if ! curl -fsS --max-time 2 "http://127.0.0.1:$PORT/healthz" >/dev/null 2>&1; then
  echo "❌ El servidor no quedó listo a tiempo."
  tail -n 50 "$LOG_FILE" || true
  read "?Enter para cerrar..."
  exit 1
fi

open "http://127.0.0.1:$PORT/"

echo ""
echo "✅ Codex Local está abierto."
echo "Codex: $("$CODEX_BIN" --version 2>/dev/null || echo desconocido)"
echo "Modelo: $MODEL"
echo "Modelos gratis detectados:"
printf "%s\n" "$LOCAL_MODEL_NAMES" | sed 's/^/  • /'
echo "Carpeta principal: $PROJECT_ROOT"
echo "Servidor privado: 127.0.0.1:$PORT"
echo ""
echo "Acceso local sin contraseña: el gateway está limitado a 127.0.0.1 y exige Origin estricto."
echo "Desde el chat: /max activa potencia máxima y /safe vuelve al modo protegido."
sleep 3
