#!/bin/zsh
set -euo pipefail
SUPPORT_DIR="$HOME/Library/Application Support/Codex Local v3"
PID_FILE="$SUPPORT_DIR/runtime/backend.pid"

if [[ ! -f "$PID_FILE" ]]; then
  echo "Codex Local v3 no parece estar ejecutándose."
  exit 0
fi

PID="$(cat "$PID_FILE" 2>/dev/null || true)"
if [[ -n "$PID" ]] && kill -0 "$PID" >/dev/null 2>&1; then
  kill "$PID" >/dev/null 2>&1 || true
  for _ in {1..30}; do
    kill -0 "$PID" >/dev/null 2>&1 || break
    sleep 0.2
  done
fi
rm -f "$PID_FILE"
echo "✅ Codex Local v3 detenido."
