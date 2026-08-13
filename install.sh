#!/usr/bin/env bash

# Descrição: Script pessoal de configuração do Fedora Silverblue
# Author: Diogo Pessoa
# Versão: 2.0 (Zsh + Starship Edition + Bootc-Manager)
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
# SUDO KEEP-ALIVE
# ============================================================
sudo -v
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

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

echo -e "${BLUE}╭────────────────────────────────────╮${NC}"
echo -e "${GREEN}│  ${BOLD}Silverblue-One ${NC}${GREEN}  │${NC}"
echo -e "${BLUE}╰────────────────────────────────────╯${NC}\n"

# ============================================================
# PACOTES RPM (DISTROBOX)
# ============================================================
info "Solicitando instalação do Distrobox via rpm-ostree..."
if rpm-ostree install distrobox >/dev/null 2>&1 || true; then
    status_rpm="${GREEN} ✓${NC}"
    success "Comando rpm-ostree enviado com sucesso"
fi

# ============================================================
# HOMEBREW
# ============================================================
BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"

if [[ ! -x "$BREW_BIN" ]]; then
    info "Instalando Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    status_brew="${GREEN} ✓${NC}"
    success "Homebrew instalado"
else
    status_brew="${GREEN} ✓${NC}"
    success "Homebrew já instalado"
fi

# Garantir que o ambiente do Brew esteja ativo nesta sessão do script
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# ============================================================
# HOMEBREW AUTO-UPDATE
# ============================================================
info "Instalando Homebrew Auto-Update..."
if curl -fsSL https://raw.githubusercontent.com/diogopessoa/brew-update/main/install.sh | bash; then
    status_brew_update="${GREEN} ✓${NC}"
    success "Homebrew Auto-Update instalado com sucesso"
fi

# ============================================================
# DISTROBOX CONTAINERS AUTO-UPDATE
# ============================================================
info "Instalando Distrobox Containers Auto-Update..."
if curl -fsSL https://raw.githubusercontent.com/diogopessoa/distrobox-upgrade/main/distrobox-upgrade.sh | bash; then
    status_distrobox_upgrade="${GREEN} ✓${NC}"
    success "Distrobox Containers Auto-Update instalado com sucesso"
fi

# ============================================================
# INSTALAÇÃO ZSH + STARSHIP + PLUGINS (VIA HOMEBREW)
# ============================================================
info "Instalando Zsh, Starship e plugins via Homebrew..."
if brew install -y zsh starship zsh-syntax-highlighting zsh-autosuggestions; then
    status_zsh_packages="${GREEN} ✓${NC}"
    success "Pacotes do Zsh e Starship instalados"
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
info "Definindo Zsh do Homebrew como Shell padrão do usuário..."
BREW_ZSH="/home/linuxbrew/.linuxbrew/bin/zsh"

if grep -q "$BREW_ZSH" /etc/shells 2>/dev/null; then
    success "Caminho $BREW_ZSH já está em /etc/shells"
else
    echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
    success "Caminho $BREW_ZSH adicionado ao /etc/shells"
fi

if sudo usermod --shell "$BREW_ZSH" "$USER"; then
    # Reseta comando customizado do Ptyxis se existir
    gsettings reset org.gnome.Ptyxis default-profile-command 2>/dev/null || true
    status_default_shell="${GREEN} ✓${NC}"
    success "Shell padrão alterado para Zsh"
fi

# ============================================================
# INTEGRAÇÃO HOMEBREW + BASH
# ============================================================
info "Configurando Homebrew para Bash..."
sudo tee /etc/profile.d/homebrew.sh >/dev/null << 'EOF'
# Homebrew (Fedora Silverblue / Atomic)
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi
EOF
status_brew_bash="${GREEN} ✓${NC}"
success "Integração Homebrew/Bash criada"

# ============================================================
# DISABLE NETWORK WAIT-ONLINE
# ============================================================
info "Desativando NetworkManager-wait-online.service..."
if sudo systemctl disable NetworkManager-wait-online.service 2>/dev/null; then
    status_network="${GREEN} ✓${NC}"
fi

# ============================================================
# OFFICE FONTS
# ============================================================
info "Instalando Office Fonts..."
FONTS_DIR="$HOME/.local/share/fonts/office_fonts"
TMP_ZIP="/tmp/office_fonts.zip"

mkdir -p "$FONTS_DIR"
if curl -fsSL https://raw.githubusercontent.com/diogopessoa/my-packages-lists/main/silverblue/office_fonts.zip -o "$TMP_ZIP"; then
    python3 -c "import zipfile; zipfile.ZipFile('$TMP_ZIP').extractall('$FONTS_DIR')"
    fc-cache -f "$HOME/.local/share/fonts"
    status_fonts="${GREEN} ✓${NC}"
    success "Fontes instaladas"
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
    gtk-update-icon-cache -f "$ICONS_DIR/Hatter" || true
    status_icons="${GREEN} ✓${NC}"
    success "Tema de ícones Hatter instalado"
fi
rm -rf "$HATTER_DIR"

# ============================================================
# BOOTC MANAGER
# ============================================================
info "Instalando Bootc Manager..."
if curl -fsSL https://raw.githubusercontent.com/diogopessoa/bootc-manager/main/install.sh | bash; then
    status_rpm_manager="${GREEN} ✓${NC}"
fi

# ============================================================
# FLATHUB E PACOTES FLATPAK
# ============================================================
info "Iniciando migração Flatpak para o Flathub..."
pkill -f gnome-software || true
flatpak config --system --set languages "pt" || true
sudo flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Remove Flatpaks nativos do repositório Fedora corporativo se existirem
apps_fedora=$(flatpak list --system --columns=application,origin | awk '$2 ~ /^fedora(-testing)?$/ {print $1}')
if [ -n "$apps_fedora" ]; then
    echo "$apps_fedora" | xargs sudo flatpak uninstall --system --assumeyes || true
fi

FFMPEG_LATEST=$(flatpak remote-ls flathub --runtime --columns=ref | grep "org.freedesktop.Platform.ffmpeg-full" | sort -V | tail -n 1)

lista_apps=(
    "$FFMPEG_LATEST"
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
    sudo flatpak remote-delete fedora --force 2>/dev/null || true
    sudo flatpak remote-delete fedora-testing --force 2>/dev/null || true
    sudo flatpak uninstall --system --unused --assumeyes || true
    status_flatpak="${GREEN} ✓${NC}"
    success "Flatpaks do Flathub sincronizados"
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
