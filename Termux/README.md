# 📱 DkScripts - Termux AI & Dev Setup Recipe

Receta automatizada y modular para configurar un entorno de desarrollo con herramientas de Inteligencia Artificial (**GitHub Copilot CLI**, **Cursor CLI** y **Antigravity CLI**) en **Termux (Android)**, ideal para móviles y tablets.

---

## 💡 ¿Por qué es necesaria esta receta en Android?

En Termux nativo, el sistema utiliza la biblioteca C de Android (**Bionic libc** y `/system/bin/linker64`). Sin embargo, los binarios oficiales de **Copilot CLI** y los módulos nativos de **Cursor CLI** están compilados para GNU/Linux tradicional (**glibc** con `/lib/ld-linux-aarch64.so.1`).

Al ejecutarlos sin configuración previa, Android devuelve:
```text
cannot execute: required file not found
```

Esta receta soluciona el problema de forma transparente:
1. Instala y configura un contenedor Debian ligero mediante `proot-distro` con certificados SSL y dependencias glibc.
2. Descarga e instala los CLIs oficiales.
3. Genera **wrappers transparentes** en `$PREFIX/bin` y `~/.local/bin` que delegan la ejecución al entorno glibc conservando tu directorio de trabajo actual (`$PWD`), tus variables de terminal (`$TERM`) y tu `$HOME`.

---

## 🚀 Replicación rápida en una nueva tablet o dispositivo

En tu tablet (con Termux recién instalado), solo corre:

```bash
pkg update -y && pkg install -y git gh
gh auth login
gh repo clone dragonknight/DkScripts ~/DkScripts
cd ~/DkScripts/Termux
./setup.sh --all
```

---

## 📂 Estructura de la receta

```text
Termux/
├── setup.sh                 # Orquestador principal (acepta flags o corre todo)
├── README.md                # Esta guía
└── scripts/
    ├── 01_termux_base.sh    # Instala proot-distro, git, gh, curl, jq, nano...
    ├── 02_debian_proot.sh   # Configura el contenedor Debian glibc y ca-certificates
    ├── 03_copilot_cli.sh    # Instala GitHub Copilot CLI + wrapper transparente
    ├── 04_cursor_cli.sh     # Instala Cursor CLI (cursor-agent) + wrapper
    └── 05_antigravity_cli.sh# Instala Google Antigravity CLI (agy)
```

---

## 🛠️ Uso y Opciones

Puedes ejecutar módulos individuales o todo en conjunto:

```bash
# Ejecutar todo
./setup.sh --all

# Solo paquetes base de Termux
./setup.sh --base

# Solo contenedor Debian glibc
./setup.sh --debian

# Solo GitHub Copilot CLI
./setup.sh --copilot

# Solo Cursor CLI
./setup.sh --cursor

# Solo Antigravity CLI
./setup.sh --agy
```

---

## 🔑 Primer inicio de sesión

### GitHub Copilot CLI
```bash
copilot login --device-code
```
Te dará un código de 8 dígitos y una URL para autenticarte en tu navegador. Luego inicia el chat con:
```bash
copilot
```

### Cursor CLI
```bash
NO_OPEN_BROWSER=1 cursor login
```
*(O exporta tu clave directamente con `export CURSOR_API_KEY="..."`).*
Luego puedes usarlo con cualquiera de estos comandos:
```bash
cursor
# o
cursor-agent
# o
agent
```

### Google Antigravity CLI
```bash
agy
```

---

**Autor:** Carlos J. Castillo N. ([@dragonknight](https://github.com/dragonknight))  
**Licencia:** GNU GPL v3
