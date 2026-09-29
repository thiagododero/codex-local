#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT_DIR"

if [[ ! -f "SHA256SUMS.txt" ]]; then
  echo "❌ No se encontró SHA256SUMS.txt"
  exit 1
fi

echo "Verificando integridad del paquete…"
shasum -a 256 -c SHA256SUMS.txt

echo ""
echo "✅ Los archivos coinciden con el manifiesto generado por GitHub Actions."
if [[ -f "BUILD_INFO.txt" ]]; then
  echo ""
  cat BUILD_INFO.txt
fi
