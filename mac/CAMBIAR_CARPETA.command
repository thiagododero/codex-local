#!/bin/zsh
set -euo pipefail

SUPPORT_DIR="$HOME/Library/Application Support/Codex Local v3"
PROJECT_ROOT_FILE="$SUPPORT_DIR/projects-root.txt"
mkdir -p "$SUPPORT_DIR"
chmod 700 "$SUPPORT_DIR" 2>/dev/null || true

SELECTED="$(osascript <<'APPLESCRIPT'
try
  set selectedFolder to choose folder with prompt "Elegí la carpeta que Codex Local puede ver y modificar"
  return POSIX path of selectedFolder
on error number -128
  return ""
end try
APPLESCRIPT
)"
SELECTED="$(printf "%s" "$SELECTED" | sed 's:/*$::')"

if [[ -z "$SELECTED" ]]; then
  echo "No se cambió la carpeta permitida."
  exit 0
fi

printf "%s
" "$SELECTED" > "$PROJECT_ROOT_FILE"
chmod 600 "$PROJECT_ROOT_FILE"
echo "✅ Carpeta permitida:"
echo "$SELECTED"
echo ""
echo "Reiniciá Codex Local para aplicar el cambio."
