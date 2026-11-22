#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# 06_ansible.sh - Instalación de Ansible con wrapper transparente sobre PRoot Debian
# ==============================================================================
set -euo pipefail

echo "==> [06/06] Configurando Ansible Automation Engine vía PRoot Debian..."

PREFIX_BIN="${PREFIX:-/data/data/com.termux/files/usr}/bin"
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$PREFIX_BIN" "$LOCAL_BIN" "$HOME/.ansible"

# 1. Asegurar contenedor Debian
if ! command -v proot-distro >/dev/null 2>&1; then
    echo "ERROR: proot-distro no está instalado. Ejecute 01_termux_base.sh y 02_debian_proot.sh primero." >&2
    exit 1
fi

# 2. Instalar Ansible y dependencias dentro de Debian
echo "--> Verificando Ansible dentro del contenedor Debian..."
if ! proot-distro login debian -- which ansible >/dev/null 2>&1; then
    echo "--> Instalando ansible y ssh en Debian..."
    proot-distro login debian -- apt-get update
    proot-distro login debian -- apt-get install -y --no-install-recommends ansible openssh-client
fi

# 3. Limpiar binarios locales rotos en Termux si existen
ANSIBLE_CMDS=(
    ansible
    ansible-playbook
    ansible-galaxy
    ansible-vault
    ansible-doc
    ansible-inventory
    ansible-config
    ansible-console
    ansible-pull
    ansible-community
    ansible-test
)

echo "--> Limpiando ejecutables obsoletos locales en Termux..."
for cmd in "${ANSIBLE_CMDS[@]}"; do
    if [ -f "$PREFIX_BIN/$cmd" ] && [ ! -L "$PREFIX_BIN/$cmd" ]; then
        if grep -q "python3.12" "$PREFIX_BIN/$cmd" 2>/dev/null; then
            rm -f "$PREFIX_BIN/$cmd"
        fi
    fi
    rm -f "$LOCAL_BIN/$cmd"
done

# Eliminar paquetes residuales de python3.12 si existen
rm -rf "${PREFIX:-/data/data/com.termux/files/usr}/lib/python3.12/site-packages/ansible"* 2>/dev/null || true

# 4. Crear el wrapper dinámico en $PREFIX_BIN/ansible
echo "--> Configurando wrapper transparente en $PREFIX_BIN/ansible..."
cat << 'EOF' > "$PREFIX_BIN/ansible"
#!/data/data/com.termux/files/usr/bin/bash
# Wrapper transparente para Ansible sobre PRoot Debian
CMD="$(basename "$0")"
exec proot-distro login --work-dir "$PWD" debian -- env HOME="$HOME" TERM="${TERM:-xterm-256color}" "$CMD" "$@"
EOF
chmod +x "$PREFIX_BIN/ansible"

# 5. Crear symlinks para todas las herramientas de Ansible
for cmd in "${ANSIBLE_CMDS[@]}"; do
    if [ "$cmd" != "ansible" ]; then
        ln -sf ansible "$PREFIX_BIN/$cmd"
        ln -sf "$PREFIX_BIN/ansible" "$LOCAL_BIN/$cmd"
    else
        ln -sf "$PREFIX_BIN/ansible" "$LOCAL_BIN/ansible"
    fi
done

# 6. Probar ejecución
echo "--> Verificando Ansible:"
"$PREFIX_BIN/ansible" --version || {
    echo "ADVERTENCIA: La verificación de Ansible falló." >&2
}

echo "==> [06/06] Ansible Automation Engine configurado exitosamente."
