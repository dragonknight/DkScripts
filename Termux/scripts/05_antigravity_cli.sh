#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# 05_antigravity_cli.sh - Instalación de Google Antigravity CLI (agy)
# ==============================================================================
set -euo pipefail

echo "==> [05/05] Instalando / Actualizando Antigravity CLI (agy)..."

if command -v agy >/dev/null 2>&1; then
    echo "--> Antigravity CLI ya está instalado."
else
    echo "--> Descargando Antigravity CLI..."
    curl -fsSL https://antigravity.google/cli/install.sh | bash
fi

echo "--> Verificando Antigravity CLI:"
if command -v agy >/dev/null 2>&1; then
    agy --version 2>/dev/null || echo "Antigravity CLI listo."
fi

echo "==> [05/05] Antigravity CLI verificado."
