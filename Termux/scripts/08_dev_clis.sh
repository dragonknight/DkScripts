#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# 08_dev_clis.sh - Instalación de CLIs de desarrollo e integraciones MCP
# (Node.js LTS, Railway CLI, Firebase Tools, Vercel CLI y configuración MCP)
# ==============================================================================
set -euo pipefail

echo "==> [08/08] Instalando / Configurando CLIs de desarrollo e integraciones MCP..."

PREFIX_BIN="${PREFIX:-/data/data/com.termux/files/usr}/bin"

# 1. Asegurar Node.js y npm en Termux nativo
if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
    echo "--> Instalando Node.js LTS en Termux..."
    pkg install -y nodejs-lts
else
    echo "--> Node.js ya instalado: $(node --version)"
fi

# 2. Instalar Railway CLI en Debian PRoot y configurar wrapper en Termux
if ! command -v railway >/dev/null 2>&1; then
    echo "--> Instalando Railway CLI vía PRoot Debian..."
    proot-distro login debian -- bash -c 'curl -fsSL https://railway.com/install.sh | sh -s -- -y'
    proot-distro login debian -- ln -sf /root/.railway/bin/railway /usr/local/bin/railway
    cat << 'EOF' > "$PREFIX_BIN/railway"
#!/data/data/com.termux/files/usr/bin/bash
# Wrapper transparente para Railway CLI sobre PRoot Debian
exec proot-distro login --work-dir "$PWD" debian -- env HOME="$HOME" TERM="${TERM:-xterm-256color}" /usr/local/bin/railway "$@"
EOF
    chmod +x "$PREFIX_BIN/railway"
    echo "--> Railway CLI configurado."
else
    echo "--> Railway CLI ya instalado: $(railway --version 2>/dev/null || echo 'OK')"
fi

# 3. Instalar Firebase CLI y Vercel CLI vía npm
if ! command -v firebase >/dev/null 2>&1; then
    echo "--> Instalando firebase-tools vía npm..."
    npm install -g --omit=dev firebase-tools
else
    echo "--> Firebase CLI ya instalado: $(firebase --version 2>/dev/null || echo 'OK')"
fi

if ! command -v vercel >/dev/null 2>&1; then
    echo "--> Instalando vercel CLI vía npm..."
    npm install -g --omit=dev vercel
else
    echo "--> Vercel CLI ya instalado: $(vercel --version 2>/dev/null || echo 'OK')"
fi

# 4. Configurar plantilla de MCP en ~/.cursor/mcp.json si no existe
CURSOR_CONFIG_DIR="$HOME/.cursor"
mkdir -p "$CURSOR_CONFIG_DIR"

if [ ! -f "$CURSOR_CONFIG_DIR/mcp.json" ]; then
    echo "--> Configurando plantilla de servidores MCP en ~/.cursor/mcp.json..."
    cat << 'EOF' > "$CURSOR_CONFIG_DIR/mcp.json"
{
  "mcpServers": {
    "clickup": {
      "command": "npx",
      "args": ["-y", "@hauptsache.net/clickup-mcp@latest"],
      "env": {
        "CLICKUP_API_KEY": "${CLICKUP_API_KEY}",
        "CLICKUP_TEAM_ID": "${CLICKUP_TEAM_ID}",
        "CLICKUP_MCP_MODE": "read-minimal"
      }
    },
    "google-drive": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-gdrive"],
      "env": {
        "CLIENT_ID": "${GOOGLE_CLIENT_ID}",
        "CLIENT_SECRET": "${GOOGLE_CLIENT_SECRET}"
      }
    },
    "railway": {
      "command": "npx",
      "args": ["-y", "railway-mcp"],
      "env": {
        "RAILWAY_API_TOKEN": "${RAILWAY_API_TOKEN}"
      }
    },
    "firebase": {
      "command": "npx",
      "args": ["-y", "@gannonh/firebase-mcp"],
      "env": {
        "SERVICE_ACCOUNT_KEY_PATH": "${FIREBASE_SERVICE_ACCOUNT_PATH}",
        "FIREBASE_STORAGE_BUCKET": "${FIREBASE_STORAGE_BUCKET}"
      }
    },
    "vercel": {
      "command": "npx",
      "args": ["-y", "vercel-mcp"],
      "env": {
        "VERCEL_API_KEY": "${VERCEL_API_KEY}"
      }
    }
  }
}
EOF
    echo "--> Plantilla MCP creada en ~/.cursor/mcp.json"
fi

# 5. Resumen de versiones
echo "--> Verificación de herramientas instaladas:"
echo "    - Node:     $(node --version 2>/dev/null || echo 'No disponible')"
echo "    - npm:      v$(npm --version 2>/dev/null || echo 'No disponible')"
echo "    - Railway:  $(railway --version 2>/dev/null || echo 'No disponible')"
echo "    - Firebase: $(firebase --version 2>/dev/null || echo 'No disponible')"
echo "    - Vercel:   $(vercel --version 2>/dev/null || echo 'No disponible')"

echo "==> [08/08] CLIs de desarrollo e integraciones MCP configurados exitosamente."
