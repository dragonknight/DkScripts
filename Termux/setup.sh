#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# setup.sh - Orquestador de configuración para Termux (DkScripts)
# Automatiza el entorno de desarrollo y CLIs de IA en Android / Tablets
# Copyright (c) Carlos J. Castillo N. (@dragonknight)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

# Colores para salida en consola
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
RESET="\033[0m"

log_info() {
    echo -e "${BLUE}${BOLD}[INFO]${RESET} $1"
}

log_success() {
    echo -e "${GREEN}${BOLD}[OK]${RESET} $1"
}

log_warn() {
    echo -e "${YELLOW}${BOLD}[WARN]${RESET} $1"
}

log_error() {
    echo -e "${RED}${BOLD}[ERROR]${RESET} $1" >&2
}

print_banner() {
    echo -e "${GREEN}${BOLD}"
    cat << 'EOF'
  ____  _     ____            _       _       
 |  _ \| | __/ ___|  ___ _ __(_)_ __ | |_ ___ 
 | | | | |/ /\___ \ / __| '__| | '_ \| __/ __|
 | |_| |   <  ___) | (__| |  | | |_) | |_\__ \
 |____/|_|\_\|____/ \___|_|  |_| .__/ \__|___/
                               |_|            
         Termux AI & Dev Setup Recipe
EOF
    echo -e "${RESET}"
    echo -e "Autor: Carlos J. Castillo N. (@dragonknight)"
    echo -e "Receta automatizada para Termux en Android / Tablets"
    echo -e "--------------------------------------------------------"
}

usage() {
    cat << EOF
Uso: $(basename "$0") [OPCIONES]

Opciones:
  --all         Ejecutar toda la receta (Base + Debian + Copilot + Cursor + Antigravity)
  --base        Instalar solo paquetes base de Termux
  --debian      Configurar solo contenedor Debian glibc
  --copilot     Instalar solo GitHub Copilot CLI y su wrapper
  --cursor      Instalar solo Cursor CLI y su wrapper
  --agy         Instalar solo Antigravity CLI
  -h, --help    Mostrar este mensaje de ayuda

Ejemplo:
  ./setup.sh --all
EOF
    exit 0
}

run_step() {
    local script_file="$1"
    local desc="$2"
    log_info "Iniciando: $desc"
    if [ -f "$script_file" ]; then
        bash "$script_file"
        log_success "Completado: $desc"
    else
        log_error "Archivo no encontrado: $script_file"
        exit 1
    fi
    echo ""
}

main() {
    print_banner

    # Comprobar entorno Termux
    if [ ! -d "/data/data/com.termux" ]; then
        log_error "Este script debe ejecutarse exclusivamente dentro de Termux en Android."
        exit 1
    fi

    # Hacer ejecutables todos los scripts auxiliares
    chmod +x "$SCRIPTS_DIR"/*.sh 2>/dev/null || true

    local target="${1:---all}"

    case "$target" in
        --base)
            run_step "$SCRIPTS_DIR/01_termux_base.sh" "Paquetes base de Termux"
            ;;
        --debian)
            run_step "$SCRIPTS_DIR/02_debian_proot.sh" "Contenedor Debian glibc"
            ;;
        --copilot)
            run_step "$SCRIPTS_DIR/03_copilot_cli.sh" "GitHub Copilot CLI"
            ;;
        --cursor)
            run_step "$SCRIPTS_DIR/04_cursor_cli.sh" "Cursor CLI"
            ;;
        --agy)
            run_step "$SCRIPTS_DIR/05_antigravity_cli.sh" "Antigravity CLI"
            ;;
        --all)
            log_info "Ejecutando configuración completa..."
            run_step "$SCRIPTS_DIR/01_termux_base.sh" "Paquetes base de Termux"
            run_step "$SCRIPTS_DIR/02_debian_proot.sh" "Contenedor Debian glibc"
            run_step "$SCRIPTS_DIR/03_copilot_cli.sh" "GitHub Copilot CLI"
            run_step "$SCRIPTS_DIR/04_cursor_cli.sh" "Cursor CLI"
            run_step "$SCRIPTS_DIR/05_antigravity_cli.sh" "Antigravity CLI"
            ;;
        -h|--help)
            usage
            ;;
        *)
            log_error "Opción desconocida: $target"
            usage
            ;;
    esac

    log_success "¡Configuración finalizada con éxito!"
    echo -e "${BOLD}Comandos disponibles en tu terminal:${RESET}"
    echo -e "  - ${GREEN}copilot${RESET}       (GitHub Copilot CLI interactivo)"
    echo -e "  - ${GREEN}cursor${RESET}        (Cursor CLI / cursor-agent)"
    echo -e "  - ${GREEN}cursor-agent${RESET}  (Cursor CLI)"
    echo -e "  - ${GREEN}agent${RESET}         (Cursor CLI)"
    echo -e "  - ${GREEN}agy${RESET}           (Google Antigravity CLI)"
    echo ""
    echo -e "${YELLOW}Nota de autenticación:${RESET}"
    echo -e "  - Para iniciar sesión en Copilot: ${BOLD}copilot login --device-code${RESET}"
    echo -e "  - Para iniciar sesión en Cursor:  ${BOLD}NO_OPEN_BROWSER=1 cursor login${RESET}"
    echo ""
}

main "$@"
