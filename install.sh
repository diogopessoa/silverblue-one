#!/usr/bin/env bash

# Descrição: Script pessoal de configuração do Fedora Silverblue
# Author: Diogo Pessoa
# Versão: v2.0.1 - Correções de Sintaxe, Sudo e Ajustes de Execução
# GitHub: https://github.com/diogopessoa/silverblue-one/

set -Eeuo pipefail
export SYSTEMD_PAGER=""
export NONINTERACTIVE=1

# ============================================================
# FUNÇÕES DE LOG E CORES
# ============================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warning() { echo -e "${YELLOW}[AVISO]${NC} $1"; }

# ---------------- Verificação de Usuário ---------------- 
if [[ $EUID -eq 0 ]]; then
  echo "Não execute este script como root: ./install-one.sh"
  exit 1
fi

# ============================================================
# SUDO KEEP-ALIVE (Solicita senha 1x e renova até o fim)
# ============================================================
info "Solicitando privilégios de administrador..."
sudo -v

# Mantém o sudo ativo em segundo plano enquanto o script estiver rodando
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" 2>/dev/null || exit
done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!

trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

# Variáveis de Status (Padrão: Falha)
status_rpm="${RED} ✗${NC}"
status_brew="${RED} ✗${NC}"
status_brew_update="${RED} ✗${NC}"
status_distrobox_upgrade="${RED} ✗${NC}"
status_zsh_packages="${RED} ✗${NC}"
status_zshrc="${RED} ✗${NC}"
status_default_shell="${RED} ✗${NC}"
status_brew_bash="${RED} ✗${NC}"
status_network="${RED} ✗${NC}"
status_fonts="${RED} ✗${NC}"
status_icons="${RED} ✗${NC}"
status_rpm_manager="${RED} ✗${NC}"
status_flatpak="${RED} ✗${NC}"

echo -e "${BLUE}╭───────────────────╮${NC}"
echo -e "${GREEN}│  ${BOLD}Silverblue-One ${NC}${GREEN}  │${NC}"
echo -e "${BLUE}╰───────────────────╯${NC}\n"

# ============================================================
# PACOTES RPM (DISTROBOX)
# ============================================================
info "Verificando Distrobox..."

if command -v distrobox >/dev/null 2>&1; then
    status_rpm="${GREEN} ✓${NC}"
    success "Distrobox já está instalado"
else
    info "Instalando Distrobox via rpm-ostree..."
    if rpm-ostree install distrobox >/dev/null 2>&1; then
        status_rpm="${GREEN} ✓${NC}"
        success "Distrobox adicionado à próxima implantação"
        warning "Reinicie o sistema para concluir a instalação do Distrobox"
    else
        warning "Falha ao adicionar Distrobox via rpm-ostree"
    fi
fi

# ============================================================
# HOMEBREW
# ============================================================
BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"

if [[ -x "$BREW_BIN" ]]; then
    status_brew="${GREEN} ✓${NC}"
    success "Homebrew já instalado"
else
    info "Instalando Homebrew..."

    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
        >/dev/null 2>&1 \
        && [[ -x "$BREW_BIN" ]]; then

        status_brew="${GREEN} ✓${NC}"
        success "Homebrew instalado com sucesso"
    else
        warning "Falha ao instalar o Homebrew"
    fi
fi

# Garantir que o ambiente do Brew esteja ativo nesta sessão
if [[ -x "$BREW_BIN" ]]; then
    eval "$("$BREW_BIN" shellenv)"
else
    warning "Homebrew não está disponível; etapas dependentes do Brew serão ignoradas"
fi

# ============================================================
# HOMEBREW AUTO-UPDATE
# ============================================================
if [[ -x "$BREW_BIN" ]]; then
    info "Instalando Homebrew Auto-Update..."
    if curl -fsSL https://raw.githubusercontent.com/diogopessoa/brew-update/main/install.sh | bash; then
        status_brew_update="${GREEN} ✓${NC}"
        success "Homebrew Auto-Update instalado com sucesso"
    else
        warning "Falha ao instalar o Homebrew Auto-Update"
    fi
fi

# ============================================================
# DISTROBOX CONTAINERS AUTO-UPDATE
# ============================================================
info "Instalando Distrobox Containers Auto-Update..."
if curl -fsSL https://raw.githubusercontent.com/diogopessoa/distrobox-upgrade/main/distrobox-upgrade.sh | bash; then
    status_distrobox_upgrade="${GREEN} ✓${NC}"
    success "Distrobox Containers Auto-Update instalado com sucesso"
else
    warning "Falha ao instalar o Distrobox Containers Auto-Update"
fi

# ============================================================
# INSTALAÇÃO ZSH + STARSHIP + PLUGINS (VIA HOMEBREW)
# ============================================================
if [[ -x "$BREW_BIN" ]]; then
    info "Instalando Zsh, Starship e plugins via Homebrew..."
    if brew install -y zsh starship zsh-syntax-highlighting zsh-autosuggestions; then
        status_zsh_packages="${GREEN} ✓${NC}"
        success "Pacotes do Zsh e Starship instalados"
    else
        warning "Falha ao instalar Zsh, Starship ou plugins"
    fi
else
    warning "Zsh, Starship e plugins não foram instalados porque o Homebrew não está disponível"
fi

# ============================================================
# CONFIGURAÇÃO DO ~/.zshrc
# ============================================================
info "Configurando o arquivo ~/.zshrc..."

cat << 'EOF' > "$HOME/.zshrc"
# ============================================================
# MENSAGEM DE BOAS-VINDAS DO ZSH
if [[ -o interactive ]]; then
    echo "\033[1;32m>_ Zsh\033[0m está pronto!"
    echo ""
fi

# ============================================================
# HOMEBREW ENV
# ============================================================
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# ============================================================
# INTERPRETA # COMO COMENTARIO MESMO EM MODO INTERATIVO
# ============================================================
setopt INTERACTIVE_COMMENTS

# ============================================================
# ALIASES (DISTROBOX & SISTEMA)
# ============================================================
alias apt="distrobox enter ubuntu -- sudo apt"
alias dnf="distrobox enter fedora -- sudo dnf"

# ============================================================
# STARSHIP PROMPT
# ============================================================
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# ============================================================
# PLUGINS DO ZSH (A ORDEM DE CARREGAMENTO É CRUCIAL!)
# ============================================================
BREW_SHARE="/home/linuxbrew/.linuxbrew/share"

# 1. Autosuggestions
if [ -f "$BREW_SHARE/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$BREW_SHARE/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# 2. Syntax Highlighting (DEVE SER O ÚLTIMO!)
if [ -f "$BREW_SHARE/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$BREW_SHARE/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
EOF

status_zshrc="${GREEN} ✓${NC}"
success "Arquivo ~/.zshrc gerado com sucesso"

# ============================================================
# DEFINIR ZSH DO BREW COMO SHELL PADRÃO
# ============================================================
BREW_ZSH="/home/linuxbrew/.linuxbrew/bin/zsh"

if [[ -x "$BREW_ZSH" ]]; then
    info "Definindo Zsh do Brew como Shell padrão do usuário..."

    if grep -Fxq "$BREW_ZSH" /etc/shells 2>/dev/null; then
        success "Caminho $BREW_ZSH já está em /etc/shells"
    else
        if echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null; then
            success "Caminho $BREW_ZSH adicionado ao /etc/shells"
        else
            warning "Não foi possível adicionar $BREW_ZSH ao /etc/shells"
        fi
    fi

    if sudo usermod --shell "$BREW_ZSH" "$USER"; then
        status_default_shell="${GREEN} ✓${NC}"
        success "Shell padrão alterado para Zsh"
    else
        warning "Não foi possível alterar o shell padrão para Zsh"
    fi
else
    warning "Zsh do Homebrew não está disponível; shell padrão não foi alterado"
fi

# ============================================================
# INTEGRAÇÃO HOMEBREW + BASH
# ============================================================
if [[ -x "$BREW_BIN" ]]; then
    info "Configurando Homebrew para Bash..."
    if sudo tee /etc/profile.d/homebrew.sh >/dev/null << 'EOF'
# Homebrew (Fedora Silverblue / Atomic)
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
EOF
    then
        status_brew_bash="${GREEN} ✓${NC}"
        success "Integração Homebrew/Bash criada"
    else
        warning "Não foi possível criar a integração Homebrew/Bash"
    fi
fi

# ============================================================
# DISABLE NETWORK WAIT-ONLINE
# ============================================================
info "Desativando NetworkManager-wait-online.service..."
if sudo systemctl disable NetworkManager-wait-online.service 2>/dev/null; then
    status_network="${GREEN} ✓${NC}"
    success "NetworkManager-wait-online.service desativado"
else
    warning "Falha ao desativar NetworkManager-wait-online.service"
fi

# ============================================================
# OFFICE FONTS
# ============================================================
info "Instalando Office Fonts..."
FONTS_DIR="$HOME/.local/share/fonts/office_fonts"
TMP_ZIP="/tmp/office_fonts.zip"

mkdir -p "$FONTS_DIR"
if curl -fsSL https://raw.githubusercontent.com/diogopessoa/my-packages-lists/main/silverblue/office_fonts.zip -o "$TMP_ZIP"     && python3 -c "import zipfile; zipfile.ZipFile('$TMP_ZIP').extractall('$FONTS_DIR')"     && fc-cache -f "$HOME/.local/share/fonts"; then
    status_fonts="${GREEN} ✓${NC}"
    success "Fontes instaladas"
else
    warning "Falha ao instalar as Office Fonts"
fi
rm -f "$TMP_ZIP"

# ============================================================
# HATTER ICONS THEME
# ============================================================
info "Instalando Hatter Icons Theme..."
ICONS_DIR="$HOME/.local/share/icons"
HATTER_DIR="/tmp/Hatter_clone"

rm -rf "$HATTER_DIR"
if git clone --depth 1 https://github.com/Mibea/Hatter.git "$HATTER_DIR" 2>/dev/null; then
    mkdir -p "$ICONS_DIR"
    rm -rf "$ICONS_DIR/Hatter"
    cp -r "$HATTER_DIR/Hatter" "$ICONS_DIR/"
    if gtk-update-icon-cache -f "$ICONS_DIR/Hatter"; then
        status_icons="${GREEN} ✓${NC}"
        success "Tema de ícones Hatter instalado"
    else
        warning "Tema de ícones Hatter foi copiado, mas falhou ao atualizar o cache de ícones"
    fi
else
    warning "Falha ao baixar o tema de ícones Hatter"
fi
rm -rf "$HATTER_DIR"

# ============================================================
# BOOTC MANAGER
# ============================================================
info "Instalando Bootc Manager..."
if curl -fsSL https://raw.githubusercontent.com/diogopessoa/bootc-manager/main/install.sh | bash; then
    status_rpm_manager="${GREEN} ✓${NC}"
    success "Bootc Manager instalado com sucesso"
else
    warning "Falha ao instalar o Bootc Manager"
fi

# ============================================================
# FLATHUB E PACOTES FLATPAK
# ============================================================
info "Iniciando migração Flatpak para o Flathub..."

# Evita que o GNOME Software interrompa o script
pkill -f gnome-software || true

if flatpak config --system --set languages "pt"     && flatpak remote-add --if-not-exists         --system         flathub         https://dl.flathub.org/repo/flathub.flatpakrepo; then

    # Remove Flatpaks instalados a partir dos remotos Fedora, se existirem.
    if apps_fedora=$(flatpak list --system --columns=application,origin |
        awk '$2 ~ /^fedora(-testing)?$/ {print $1}'); then

        if [[ -n "$apps_fedora" ]]; then
            if echo "$apps_fedora" | xargs -r flatpak uninstall --system --assumeyes; then
                success "Flatpaks dos remotos Fedora removidos"
            else
                warning "Falha ao remover um ou mais Flatpaks dos remotos Fedora"
            fi
        fi
    else
        warning "Não foi possível verificar os Flatpaks do repositório Fedora"
    fi

    lista_apps=(
    app.zen_browser.zen
    com.bitwarden.desktop
    com.brave.Browser
    com.github.Bleuzen.FFaudioConverter
    com.github.finefindus.eyedropper
    com.github.jeromerobert.pdfarranger
    com.github.neithern.g4music
    com.github.tchx84.Flatseal
    com.github.tenderowl.frog
    com.github.wwmm.easyeffects
    com.github.zocker_160.SyncThingy
    com.mattjakeman.ExtensionManager
    com.obsproject.Studio
    com.protonvpn.www
    com.ranfdev.DistroShelf
    com.rustdesk.RustDesk
    com.valvesoftware.Steam
    de.haeckerfelix.Fragments
    fr.handbrake.ghb
    io.ente.auth
    io.github.flattool.Ignition
    io.github.flattool.Warehouse
    io.github.kolunmi.Bazaar
    io.github.thetumultuousunicornofdarkness.cpu-x
    io.github.wartybix.Constrict
    it.mijorus.collector
    it.mijorus.smile
    md.obsidian.Obsidian
    net.ankiweb.Anki
    net.nokyan.Resources
    no.mifi.losslesscut
    org.fedoraproject.MediaWriter
    org.freefilesync.FreeFileSync
    org.gnome.Boxes
    org.gnome.Calculator
    org.gnome.Calendar
    org.gnome.Contacts
    org.gnome.Evince
    org.gnome.FileRoller
    org.gnome.Logs
    org.gnome.Loupe
    org.gnome.Shotwell
    org.gnome.Showtime
    org.gnome.SimpleScan
    org.gnome.Snapshot
    org.gnome.TextEditor
    org.gnome.World.PikaBackup
    org.gnome.baobab
    org.gnome.clocks
    org.localsend.localsend_app
    org.onlyoffice.desktopeditors
    org.pvermeer.WebAppHub
    org.telegram.desktop
    page.codeberg.libre_menu_editor.LibreMenuEditor
    page.tesk.Refine    
    )

    if flatpak install --system --assumeyes flathub "${lista_apps[@]}"; then
        flatpak_cleanup_ok=true

        if flatpak remote-list --columns=name | grep -Fxq "fedora"; then
            if flatpak remote-delete fedora --force 2>/dev/null; then
                success "Remoto Fedora removido"
            else
                warning "Não foi possível remover o remoto Fedora"
                flatpak_cleanup_ok=false
            fi
        fi

        if flatpak remote-list --columns=name | grep -Fxq "fedora-testing"; then
            if flatpak remote-delete fedora-testing --force 2>/dev/null; then
                success "Remoto Fedora Testing removido"
            else
                warning "Não foi possível remover o remoto Fedora Testing"
                flatpak_cleanup_ok=false
            fi
        fi

        if flatpak uninstall --system --unused --assumeyes; then
            success "Runtimes e extensões Flatpak não utilizados removidos"
        else
            warning "Falha ao remover runtimes e extensões Flatpak não utilizados"
            flatpak_cleanup_ok=false
        fi

        if [[ "$flatpak_cleanup_ok" == true ]]; then
            status_flatpak="${GREEN} ✓${NC}"
            success "Flatpaks do Flathub sincronizados"
        else
            status_flatpak="${YELLOW} !${NC}"
            warning "Flatpaks instalados, mas uma ou mais etapas de limpeza falharam"
        fi
    else
        warning "Falha ao instalar um ou mais Flatpaks"
    fi
else
    warning "Não foi possível configurar o Flathub"
fi

# ============================================================
# PAINEL RESUMO DE STATUS
# ============================================================
echo -e "\n"
echo "▶ Sumário de Modificações: " 
echo -e " $status_rpm Distrobox (rpm-ostree)"
echo -e " $status_brew Homebrew"
echo -e " $status_brew_update Homebrew Auto-Update"
echo -e " $status_distrobox_upgrade Distrobox Auto-Update"
echo -e " $status_zsh_packages Zsh + Starship + Plugins (Brew)"
echo -e " $status_zshrc Configuração ~/.zshrc"
echo -e " $status_default_shell Zsh definido como Shell Padrão"
echo -e " $status_brew_bash Integração Homebrew/Bash"
echo -e " $status_network Network wait-online desativado"
echo -e " $status_fonts Office Fonts"
echo -e " $status_icons Hatter Icons Theme"
echo -e " $status_rpm_manager Bootc Manager"
echo -e " $status_flatpak Transição Flatpak Fedora para Flathub"
echo ""
echo -e "${BLUE}${BOLD}Tudo pronto! Reinicie o sistema para aplicar as mudanças.${NC}"
read -rp "Pressione Enter para encerrar..."
echo ""
