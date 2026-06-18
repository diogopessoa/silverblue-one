#!/usr/bin/env bash

# Descrição: Script de configuração do meu Fedora Silverblue
# Author: Diogo Pessoa
# Versão: 1.0

set -Eeuo pipefail

# ============================================================
# CORES
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

trap 'echo ""; error "Ocorreu um erro inesperado."; exit 1' ERR

# ============================================================
# VERIFICAÇÃO ROOT
# ============================================================

if [[ $EUID -eq 0 ]]; then
    error "Não execute este script como root."
    exit 1
fi

# ============================================================
# DIRETÓRIOS
# ============================================================

FISH_CONFIG="$HOME/.config/fish/config.fish"
FISH_FUNCTIONS="$HOME/.config/fish/functions"

mkdir -p "$(dirname "$FISH_CONFIG")"
mkdir -p "$FISH_FUNCTIONS"

# ============================================================
# RPM-OSTREE
# ============================================================

info "Instalando Fish e Distrobox (rpm-ostree)..."

rpm-ostree install fish distrobox >/dev/null 2>&1 || true

success "rpm-ostree executado"

# ============================================================
# HOMEBREW
# ============================================================

BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"

if [[ ! -x "$BREW_BIN" ]]; then
    info "Instalando Homebrew..."

    NONINTERACTIVE=1 \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    success "Homebrew instalado"
else
    success "Homebrew já instalado"
fi

# ============================================================
# HOMEBREW + FISH
# ============================================================

BREW_FISH_BLOCK='
# Homebrew (Fedora Silverblue / Atomic)
if test -x /home/linuxbrew/.linuxbrew/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew shellenv | source
end
'

if ! grep -q "Homebrew (Fedora Silverblue / Atomic)" "$FISH_CONFIG" 2>/dev/null; then
    printf "%s\n" "$BREW_FISH_BLOCK" >> "$FISH_CONFIG"
    success "Integração Homebrew/Fish adicionada"
else
    success "Integração Homebrew/Fish já existe"
fi

# ============================================================
# HOMEBREW + BASH
# ============================================================

info "Configurando Homebrew para Bash..."

sudo tee /etc/profile.d/homebrew.sh >/dev/null <<'EOF'
# Homebrew (Fedora Silverblue / Atomic)
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
EOF

success "Integração Homebrew/Bash criada"

# ============================================================
# NOTIFICAÇÕES FISH
# ============================================================

if ! grep -q "fish_preexec" "$FISH_CONFIG" 2>/dev/null; then

cat >> "$FISH_CONFIG" <<'EOF'

# ============================================================
# Notificações para comandos longos
# ============================================================

function preexec --on-event fish_preexec
    set -g last_command_start (date +%s)
end

function notify_command_end --on-event fish_postexec
    set duration (math (date +%s) - $last_command_start)

    if test $duration -ge 3
        set cmd_name (string split ' ' -- $argv[1])[1]

        notify-send ">_ Comando concluído" \
            "'$cmd_name' finalizado em $duration segundos"
    end
end

EOF

success "Notificações do Fish configuradas"

else
    success "Notificações do Fish já configuradas"
fi

# ============================================================
# FISH GREETING
# ============================================================

cat > "$FISH_FUNCTIONS/fish_greeting.fish" <<'EOF'
function fish_greeting
    echo -n "🐟 Fish-shell pronto! Digite "
    set_color green
    echo -n help
    set_color normal
    echo " para instruções"
    echo ""
end
EOF

success "Mensagem de boas-vindas configurada"

# ============================================================
# ALIAS APT
# ============================================================

cat > "$FISH_FUNCTIONS/apt.fish" <<'EOF'
function apt
    distrobox enter ubuntu -- sudo apt $argv
end
EOF

success "Função apt criada"

# ============================================================
# ALIAS DNF
# ============================================================

cat > "$FISH_FUNCTIONS/dnf.fish" <<'EOF'
function dnf
    distrobox enter fedora -- sudo dnf $argv
end
EOF

success "Função dnf criada"

# ============================================================
# FLATPAK BUILDER
# ============================================================

cat > "$FISH_FUNCTIONS/flatpak-builder.fish" <<'EOF'
function flatpak-builder --wraps org.flatpak.Builder --description 'alias flatpak-builder=flatpak run org.flatpak.Builder'
    flatpak run org.flatpak.Builder $argv
end
EOF

success "Função flatpak-builder criada"

# ============================================================
# FISHER
# ============================================================

if command -v fish >/dev/null 2>&1; then

    if ! fish -c "functions -q fisher" 2>/dev/null; then
        info "Instalando Fisher..."

        fish -c '
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
        fisher install jorgebucaran/fisher
        '

        success "Fisher instalado"
    else
        success "Fisher já instalado"
    fi

else
    warning "Fish ainda não disponível nesta sessão"
fi

# ============================================================
# FINAL
# ============================================================

echo ""
echo "================================================"
success "Configuração concluída!"
echo "================================================"
echo ""

echo "Recomenda-se reiniciar o sistema para aplicar"
echo "os pacotes instalados via rpm-ostree."
echo ""

echo -e "${BLUE}${BOLD}Finished!${NC}"
read -rp "Press Enter to close..."
echo ""
