#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# 07_storage_onedrive.sh - Almacenamiento Android y sincronización de OneDrive
# ==============================================================================
set -euo pipefail

echo "==> [07/07] Configurando almacenamiento de Android y soporte para OneDrive..."

# 1. Asegurar permisos de almacenamiento en Android (termux-setup-storage)
if [ ! -d "$HOME/storage" ] || [ ! -e "$HOME/storage/shared" ]; then
    echo "--> Solicitando permisos de almacenamiento a Android (termux-setup-storage)..."
    termux-setup-storage || true
    echo "--> Permisos solicitados. Acepta el diálogo emergente en Android si aparece."
else
    echo "--> Permisos y directorios de almacenamiento en ~/storage ya activos."
fi

# 2. Asegurar que rclone esté instalado
if ! command -v rclone >/dev/null 2>&1; then
    echo "--> Instalando rclone para soporte de OneDrive en la nube..."
    pkg install -y rclone
fi

# 3. Crear directorio local dedicado para OneDrive
ONEDRIVE_DIR="$HOME/OneDrive"
mkdir -p "$ONEDRIVE_DIR" "$HOME/.local/bin"

# 4. Crear script para listar carpetas de OneDrive: onedrive-ls
cat << 'EOF' > "$HOME/.local/bin/onedrive-ls"
#!/data/data/com.termux/files/usr/bin/bash
# Lista carpetas y archivos en tu Microsoft OneDrive
DETECTED_REMOTE=$(rclone listremotes 2>/dev/null | grep -i '^onedrive:' | head -n 1 | tr -d ':' || echo "OneDrive")
REMOTE="${ONEDRIVE_REMOTE:-${DETECTED_REMOTE:-OneDrive}}"
SUBPATH="${1:-}"

if ! rclone listremotes 2>/dev/null | grep -qi "^${REMOTE}:"; then
    echo "Aviso: No se ha configurado el remoto '${REMOTE}:' en rclone."
    echo "Ejecuta 'rclone config' para vincular tu cuenta de Microsoft OneDrive primero."
    exit 1
fi

echo "Carpetas en ${REMOTE}:${SUBPATH}:"
rclone lsd "${REMOTE}:${SUBPATH}"
EOF
chmod +x "$HOME/.local/bin/onedrive-ls"

# 5. Crear script de sincronización / descarga: onedrive-sync (soporta subcarpetas)
cat << 'EOF' > "$HOME/.local/bin/onedrive-sync"
#!/data/data/com.termux/files/usr/bin/bash
# Descarga y sincroniza tus archivos de OneDrive en local (~/OneDrive)
# Uso: onedrive-sync [carpeta_opcional] [flags_rclone...]
DETECTED_REMOTE=$(rclone listremotes 2>/dev/null | grep -i '^onedrive:' | head -n 1 | tr -d ':' || echo "OneDrive")
REMOTE="${ONEDRIVE_REMOTE:-${DETECTED_REMOTE:-OneDrive}}"

if ! rclone listremotes 2>/dev/null | grep -qi "^${REMOTE}:"; then
    echo "Aviso: No se ha configurado el remoto '${REMOTE}:' en rclone."
    echo "Ejecuta 'rclone config' para vincular tu cuenta de Microsoft OneDrive primero."
    exit 1
fi

SUBPATH="${1:-}"
if [ -n "$SUBPATH" ] && [ "${SUBPATH:0:1}" != "-" ]; then
    shift
    REMOTE_PATH="${REMOTE}:${SUBPATH}"
    LOCAL_PATH="$HOME/OneDrive/${SUBPATH}"
else
    REMOTE_PATH="${REMOTE}:"
    LOCAL_PATH="$HOME/OneDrive"
fi

mkdir -p "$LOCAL_PATH"
echo "--> Sincronizando desde $REMOTE_PATH hacia $LOCAL_PATH ..."
rclone sync "$REMOTE_PATH" "$LOCAL_PATH" --progress "$@"
echo "--> Sincronización completada."
EOF
chmod +x "$HOME/.local/bin/onedrive-sync"

# 6. Crear script para subir cambios a OneDrive: onedrive-push (soporta subcarpetas)
cat << 'EOF' > "$HOME/.local/bin/onedrive-push"
#!/data/data/com.termux/files/usr/bin/bash
# Sube tus archivos locales de ~/OneDrive hacia Microsoft OneDrive
# Uso: onedrive-push [carpeta_opcional] [flags_rclone...]
DETECTED_REMOTE=$(rclone listremotes 2>/dev/null | grep -i '^onedrive:' | head -n 1 | tr -d ':' || echo "OneDrive")
REMOTE="${ONEDRIVE_REMOTE:-${DETECTED_REMOTE:-OneDrive}}"

if ! rclone listremotes 2>/dev/null | grep -qi "^${REMOTE}:"; then
    echo "Aviso: No se ha configurado el remoto '${REMOTE}:' en rclone."
    echo "Ejecuta 'rclone config' para vincular tu cuenta de Microsoft OneDrive primero."
    exit 1
fi

SUBPATH="${1:-}"
if [ -n "$SUBPATH" ] && [ "${SUBPATH:0:1}" != "-" ]; then
    shift
    LOCAL_PATH="$HOME/OneDrive/${SUBPATH}"
    REMOTE_PATH="${REMOTE}:${SUBPATH}"
else
    LOCAL_PATH="$HOME/OneDrive"
    REMOTE_PATH="${REMOTE}:"
fi

if [ ! -d "$LOCAL_PATH" ]; then
    echo "Error: La carpeta local $LOCAL_PATH no existe." >&2
    exit 1
fi

echo "--> Subiendo cambios desde $LOCAL_PATH hacia $REMOTE_PATH ..."
rclone sync "$LOCAL_PATH" "$REMOTE_PATH" --progress "$@"
echo "--> Subida completada."
EOF
chmod +x "$HOME/.local/bin/onedrive-push"

# 7. Comprobar si ya está configurado el remoto
echo "--> Verificando conexión con OneDrive..."
DETECTED=$(rclone listremotes 2>/dev/null | grep -i '^onedrive:' | head -n 1 | tr -d ':' || true)
if [ -n "$DETECTED" ]; then
    echo "--> Remoto '$DETECTED:' detectado y conectado correctamente en rclone."
    echo "    (Espacio disponible en la nube: $(rclone about "$DETECTED:" 2>/dev/null | grep -E '^Free:' || echo 'Verificado'))"
else
    echo ""
    echo "------------------------------------------------------------------------"
    echo "💡 Para conectar tu cuenta de Microsoft OneDrive:"
    echo "   1. Ejecuta: rclone config"
    echo "   2. Escribe 'n' (New remote) y nómbralo 'OneDrive'"
    echo "   3. Selecciona el tipo de almacenamiento 'onedrive' (Microsoft OneDrive)"
    echo "   4. Sigue los pasos para iniciar sesión con tu cuenta de Microsoft"
    echo ""
    echo "   Una vez vinculado, podrás usar:"
    echo "      onedrive-ls               (listar carpetas en la nube)"
    echo "      onedrive-sync [carpeta]   (descargar carpeta a ~/OneDrive)"
    echo "      onedrive-push [carpeta]   (subir cambios a la nube)"
    echo "------------------------------------------------------------------------"
    echo ""
fi

echo "==> [07/07] Almacenamiento Android y utilidades de OneDrive configurados exitosamente."
