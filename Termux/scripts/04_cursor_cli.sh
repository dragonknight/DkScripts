#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# 04_cursor_cli.sh - Instalación de Cursor CLI (cursor-agent) con wrapper glibc
# ==============================================================================
set -euo pipefail

echo "==> [04/05] Instalando / Actualizando Cursor CLI (cursor-agent)..."

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN" "$HOME/.local/share/cursor-agent"

# Descargar e instalar Cursor Agent oficial
echo "--> Ejecutando instalador oficial de Cursor..."
curl https://cursor.com/install -fsS | bash || true

# Eliminar symlinks previos que apuntaban al script nativo de node
rm -f "$LOCAL_BIN/cursor-agent" "$LOCAL_BIN/agent" "$LOCAL_BIN/cursor"

# Crear wrapper dinámico en ~/.local/bin/cursor-agent
echo "--> Configurando wrapper dinámico en $LOCAL_BIN/cursor-agent..."
cat << 'EOF' > "$LOCAL_BIN/cursor-agent"
#!/data/data/com.termux/files/usr/bin/bash
# Wrapper transparente para Cursor CLI (cursor-agent) sobre PRoot Debian
VERSIONS_DIR="$HOME/.local/share/cursor-agent/versions"
LATEST_DIR=$(ls -1d "$VERSIONS_DIR"/* 2>/dev/null | tail -n 1)

if [ -n "$LATEST_DIR" ] && [ -x "$LATEST_DIR/cursor-agent" ]; then
    CMD="$LATEST_DIR/cursor-agent"
else
    echo "Error: no se encontró cursor-agent en $VERSIONS_DIR" >&2
    exit 1
fi

exec proot-distro login --work-dir "$PWD" debian -- env HOME="$HOME" TERM="${TERM:-xterm-256color}" "$CMD" "$@"
EOF
chmod +x "$LOCAL_BIN/cursor-agent"

# Crear symlinks para cursor y agent
ln -sf cursor-agent "$LOCAL_BIN/agent"
ln -sf cursor-agent "$LOCAL_BIN/cursor"

# Vincular dentro de Debian también
proot-distro login debian -- bash -c '
    LATEST=$(ls -1d /data/data/com.termux/files/home/.local/share/cursor-agent/versions/* 2>/dev/null | tail -n 1)
    if [ -n "$LATEST" ]; then
        ln -sf "$LATEST/cursor-agent" /usr/local/bin/cursor-agent
        ln -sf /usr/local/bin/cursor-agent /usr/local/bin/cursor
        ln -sf /usr/local/bin/cursor-agent /usr/local/bin/agent
    fi
'

# Probar ejecución
echo "--> Verificando Cursor CLI:"
"$LOCAL_BIN/cursor-agent" --version || {
    echo "ADVERTENCIA: La verificación de Cursor falló." >&2
}

echo "==> [04/05] Cursor CLI (cursor, cursor-agent, agent) instalado exitosamente."
