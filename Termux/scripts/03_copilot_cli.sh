#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# 03_copilot_cli.sh - Instalación de GitHub Copilot CLI con wrapper glibc
# ==============================================================================
set -euo pipefail

echo "==> [03/05] Instalando / Actualizando GitHub Copilot CLI..."

COPILOT_DIR="$HOME/.local/share/copilot"
COPILOT_BIN="$COPILOT_DIR/copilot"
PREFIX_BIN="${PREFIX:-/data/data/com.termux/files/usr}/bin"

mkdir -p "$COPILOT_DIR" "$PREFIX_BIN" "$HOME/.local/bin"

# Descargar la versión oficial de Copilot CLI si no existe o se requiere reinstalar
if [ ! -f "$COPILOT_BIN" ]; then
    echo "--> Descargando Copilot CLI oficial..."
    curl -fsSL https://gh.io/copilot-install | bash

    # El instalador coloca el binario en $PREFIX_BIN/copilot.
    # En Termux nativo ese binario falla porque requiere glibc.
    if [ -f "$PREFIX_BIN/copilot" ] && [ ! -L "$PREFIX_BIN/copilot" ]; then
        mv "$PREFIX_BIN/copilot" "$COPILOT_BIN"
        chmod +x "$COPILOT_BIN"
    fi
else
    echo "--> Binario de Copilot ya presente en $COPILOT_BIN."
fi

# Crear el script wrapper transparente en $PREFIX_BIN/copilot
echo "--> Configurando wrapper transparente en $PREFIX_BIN/copilot..."
cat << 'EOF' > "$PREFIX_BIN/copilot"
#!/data/data/com.termux/files/usr/bin/bash
# Wrapper transparente para GitHub Copilot CLI sobre PRoot Debian
BIN="$HOME/.local/share/copilot/copilot"
if [ ! -x "$BIN" ]; then
    echo "Error: copilot binary no encontrado en $BIN" >&2
    exit 1
fi
exec proot-distro login --work-dir "$PWD" debian -- env HOME="$HOME" TERM="${TERM:-xterm-256color}" "$BIN" "$@"
EOF
chmod +x "$PREFIX_BIN/copilot"

# Vincular también dentro de Debian para coherencia
proot-distro login debian -- ln -sf "$COPILOT_BIN" /usr/local/bin/copilot

# Probar ejecución
echo "--> Verificando Copilot CLI:"
"$PREFIX_BIN/copilot" --version || {
    echo "ADVERTENCIA: La verificación de Copilot falló. Revisa que Debian tenga ca-certificates." >&2
}

echo "==> [03/05] GitHub Copilot CLI instalado exitosamente."
