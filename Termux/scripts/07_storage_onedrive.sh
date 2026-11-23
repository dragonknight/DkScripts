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

# 4. Crear script de sincronización bidireccional / descarga: onedrive-sync
cat << 'EOF' > "$HOME/.local/bin/onedrive-sync"
#!/data/data/com.termux/files/usr/bin/bash
# Descarga y sincroniza tus archivos de OneDrive en local (~/OneDrive)
REMOTE="${ONEDRIVE_REMOTE:-onedrive}"
LOCAL="$HOME/OneDrive"
mkdir -p "$LOCAL"

if ! rclone listremotes 2>/dev/null | grep -q "^${REMOTE}:"; then
    echo "Aviso: No se ha configurado el remoto '${REMOTE}:' en rclone."
    echo "Ejecuta 'rclone config' para vincular tu cuenta de Microsoft OneDrive primero."
    exit 1
fi

echo "--> Sincronizando desde OneDrive (${REMOTE}:) hacia $LOCAL ..."
rclone sync "${REMOTE}:" "$LOCAL" --progress "$@"
echo "--> Sincronización completada."
EOF
chmod +x "$HOME/.local/bin/onedrive-sync"

# 5. Crear script para subir cambios a OneDrive: onedrive-push
cat << 'EOF' > "$HOME/.local/bin/onedrive-push"
#!/data/data/com.termux/files/usr/bin/bash
# Sube tus archivos locales de ~/OneDrive hacia Microsoft OneDrive
REMOTE="${ONEDRIVE_REMOTE:-onedrive}"
LOCAL="$HOME/OneDrive"

if ! rclone listremotes 2>/dev/null | grep -q "^${REMOTE}:"; then
    echo "Aviso: No se ha configurado el remoto '${REMOTE}:' en rclone."
    echo "Ejecuta 'rclone config' para vincular tu cuenta de Microsoft OneDrive primero."
    exit 1
fi

echo "--> Subiendo cambios desde $LOCAL hacia OneDrive (${REMOTE}:) ..."
rclone sync "$LOCAL" "${REMOTE}:" --progress "$@"
echo "--> Subida completada."
EOF
chmod +x "$HOME/.local/bin/onedrive-push"

# 6. Comprobar si ya está configurado el remoto
echo "--> Verificando conexión con OneDrive..."
if rclone listremotes 2>/dev/null | grep -qi "onedrive"; then
    echo "--> Remoto de OneDrive detectado en rclone."
else
    echo ""
    echo "------------------------------------------------------------------------"
    echo "💡 Para conectar tu cuenta de Microsoft OneDrive:"
    echo "   1. Ejecuta: rclone config"
    echo "   2. Escribe 'n' (New remote) y nómbralo 'onedrive'"
    echo "   3. Selecciona el tipo de almacenamiento 'onedrive' (Microsoft OneDrive)"
    echo "   4. Sigue los pasos para iniciar sesión con tu cuenta de Microsoft"
    echo ""
    echo "   Una vez vinculado, podrás usar:"
    echo "      onedrive-sync   (descarga tus archivos de OneDrive a ~/OneDrive)"
    echo "      onedrive-push   (sube tus archivos locales de ~/OneDrive a la nube)"
    echo "------------------------------------------------------------------------"
    echo ""
fi

echo "==> [07/07] Almacenamiento Android y utilidades de OneDrive configurados exitosamente."
