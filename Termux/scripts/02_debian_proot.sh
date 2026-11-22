#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# 02_debian_proot.sh - Configuración del contenedor Debian glibc vía proot-distro
# ==============================================================================
set -euo pipefail

echo "==> [02/05] Verificando contenedor Debian en proot-distro..."

if ! command -v proot-distro >/dev/null 2>&1; then
    echo "ERROR: proot-distro no está instalado. Ejecute 01_termux_base.sh primero." >&2
    exit 1
fi

DEBIAN_DIR="${PREFIX:-/data/data/com.termux/files/usr}/var/lib/proot-distro/containers/debian"

# Verificar si Debian ya está instalado
if [ -d "$DEBIAN_DIR" ] || proot-distro login debian -- true 2>/dev/null; then
    echo "--> Contenedor Debian ya instalado."
else
    echo "--> Descargando e instalando contenedor Debian..."
    proot-distro install debian
fi

echo "--> Configurando dependencias del sistema dentro de Debian..."
# Actualizar repositorios e instalar paquetes necesarios (ca-certificates, git, procps, openssh-client)
proot-distro login debian -- apt-get update
proot-distro login debian -- apt-get install -y ca-certificates git procps openssh-client curl

# Actualizar certificados SSL en Debian
proot-distro login debian -- update-ca-certificates

echo "==> [02/05] Contenedor Debian glibc listo y actualizado."
