#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# 01_termux_base.sh - Configuración base para Termux en Android
# ==============================================================================
set -euo pipefail

echo "==> [01/05] Actualizando repositorios e instalando paquetes base en Termux..."

# Verificar que se ejecuta en Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo "ERROR: Este script debe ejecutarse dentro del entorno Termux en Android." >&2
    exit 1
fi

# Actualizar lista de paquetes
pkg update -y

# Instalar dependencias esenciales
REQUIRED_PKGS=(
    proot
    proot-distro
    git
    gh
    curl
    jq
    tar
    gzip
    nano
    openssl
    which
)

for pkg_name in "${REQUIRED_PKGS[@]}"; do
    if ! command -v "$pkg_name" >/dev/null 2>&1; then
        echo "--> Instalando $pkg_name..."
        pkg install -y "$pkg_name"
    else
        echo "--> $pkg_name ya está instalado."
    fi
done

# Asegurar directorios de usuario
mkdir -p "$HOME/.local/bin" "$HOME/.local/share" "$HOME/.config"

# Configurar PATH en ~/.bashrc si no existe
if ! grep -q 'PATH.*\.local/bin' "$HOME/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    echo "--> PATH actualizado en ~/.bashrc"
fi

echo "==> [01/05] Entorno base de Termux configurado correctamente."
