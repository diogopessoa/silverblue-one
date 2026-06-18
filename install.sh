#!/usr/bin/env bash

# Descrição: Script pessoal de configuração do Fedora Silverblue
# Author: Diogo Pessoa
# Versão: 1.2
# GitHub: https://github.com/diogopessoa/silverblue-one/

set -Eeuo pipefail

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
status_brew_fish="${RED} ✗${NC}"
status_brew_bash="${RED} ✗${NC}"
status_fish_notify="${RED} ✗${NC}"
status_fish_greeting="${RED} ✗${NC}"
status_apt_dnf="${RED} ✗${NC}"
status_fisher="${RED} ✗${NC}"
status_network="${RED} ✗${NC}"
status_fonts="${RED} ✗${NC}"
status_icons="${RED} ✗${NC}"
status_rpm_manager="${RED} ✗${NC}"
status_flatpak="${RED} ✗${NC}"

echo -e "${BLUE}╭────────────────────────────────────╮${NC}"
echo -e "${GREEN}│  ${BOLD}Silverblue-One ${NC}${GREEN}  │${NC}"
echo -e "${BLUE}╰────────────────────────────────────╯${NC}\n"

# ============================================================
# DIRETÓRIOS DE CONFIGURAÇÃO
# ============================================================
FISH_CONFIG="$HOME/.config/fish/config.fish"
FISH_FUNCTIONS="$HOME/.config/fish/functions"

mkdir -p "$FISH_FUNCTIONS"

# ============================================================
# PACOTES RPM
# ============================================================
info "Solicitando instalação de Fish e Distrobox via rpm-ostree..."
if rpm-ostree install fish distrobox >/dev/null 2>&1 || true; then
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

# ============================================================
# HOMEBREW + FISH
# ============================================================
if ! grep -q "Homebrew (Fedora Silverblue / Atomic)" "$FISH_CONFIG" 2>/dev/null; then
    cat << 'EOF' >> "$FISH_CONFIG"

# Homebrew (Fedora Silverblue / Atomic)
if test -x /home/linuxbrew/.linuxbrew/bin/brew
    /home/linuxbrew/.linuxbrew/bin/brew shellenv | source
end
EOF
    status_brew_fish="${GREEN} ✓${NC}"
    success "Integração Homebrew/Fish adicionada"
else
    status_brew_fish="${GREEN} ✓${NC}"
    success "Integração Homebrew/Fish já existe"
fi

# ============================================================
# HOMEBREW + BASH
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
# NOTIFICAÇÕES FISH
# ============================================================
if ! grep -q "fish_preexec" "$FISH_CONFIG" 2>/dev/null; then
    cat << 'EOF' >> "$FISH_CONFIG"

# Notificações para comandos longos
function preexec --on-event fish_preexec
    set -g last_command_start (date +%s)
end

function notify_command_end --on-event fish_postexec
    set duration (math (date +%s) - $last_command_start)
    if test $duration -ge 3
        set cmd_name (string split ' ' -- $argv[1])[1]
        notify-send ">_ Comando concluído" "'$cmd_name' finalizado em $duration segundos"
    fi
end
EOF
    status_fish_notify="${GREEN} ✓${NC}"
    success "Notificações do Fish configuradas"
else
    status_fish_notify="${GREEN} ✓${NC}"
    success "Notificações do Fish já configuradas"
fi

# ============================================================
# FISH GREETING
# ============================================================
cat << 'EOF' > "$FISH_FUNCTIONS/fish_greeting.fish"
function fish_greeting
    echo -n "🐟 Fish-shell pronto! Digite "
    set_color green
    echo -n help
    set_color normal
    echo " para instruções"
    echo ""
end
EOF
status_fish_greeting="${GREEN} ✓${NC}"
success "Mensagem de boas-vindas do Fish configurada"

# ============================================================
# ALIAS DISTROBOX (APT & DNF)
# ============================================================
cat << 'EOF' > "$FISH_FUNCTIONS/apt.fish"
function apt
    distrobox enter ubuntu -- sudo apt $argv
end
EOF

cat << 'EOF' > "$FISH_FUNCTIONS/dnf.fish"
function dnf
    distrobox enter fedora -- sudo dnf $argv
end
EOF
status_apt_dnf="${GREEN} ✓${NC}"
success "Funções analógicas apt e dnf criadas via Distrobox"

# ============================================================
# FISHER (MÉTODO DECLARATIVO SEGURO)
# ============================================================
# Baixa a função diretamente no diretório do Fish. Funciona mesmo antes do primeiro reboot.
if [ ! -f "$FISH_FUNCTIONS/fisher.fish" ]; then
    info "Instalando gerenciador Fisher de forma declarativa..."
    if curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish -o "$FISH_FUNCTIONS/fisher.fish"; then
        status_fisher="${GREEN} ✓${NC}"
        success "Fisher injetado com sucesso (estará ativo no próximo login)"
    fi
else
    status_fisher="${GREEN} ✓${NC}"
    success "Fisher já configurado"
fi

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
# RPM-OSTREE MANAGER
# ============================================================
info "Instalando RPM-OSTree Manager..."
if curl -fsSL https://raw.githubusercontent.com/diogopessoa/rpm-ostree-manager/main/install.sh | bash; then
    status_rpm_manager="${GREEN} ✓${NC}"
fi

# ============================================================
# REPOSITÓRIO E PACOTES FLATPAK
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
    com.warlordsoftwares.youtube-downloader-4ktube
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
    org.feichtmeier.Musicpod
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
echo -e " $status_rpm Pacotes RPM"
echo -e " $status_brew Homebrew"
echo -e " $status_brew_fish Homebrew/Fish integrado"
echo -e " $status_brew_bash Homebrew/Bash integrado"
echo -e " $status_fish_notify Notificações longas do terminal"
echo -e " $status_fish_greeting Boas-vindas do Fish"
echo -e " $status_apt_dnf Alias \"apt\" e \"dnf\" via Distrobox"
echo -e " $status_fisher Fisher instalado"
echo -e " $status_network Network wait-online desativado"
echo -e " $status_fonts Office Fonts aplicadas"
echo -e " $status_icons Hatter Icons Theme instalado"
echo -e " $status_rpm_manager RPM-OSTree Manager pronto"
echo -e " $status_flatpak Transição Flathub concluída"
echo ""
echo -e "${BLUE}${BOLD}Tudo pronto! Reinicie o sistema para aplicar as mudanças.${NC}"
read -rp "Pressione Enter para encerrar..."
echo ""
