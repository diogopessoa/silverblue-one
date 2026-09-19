#!/usr/bin/env bash

# Descrição: Script pessoal de configuração do Fedora Silverblue
# Author: Diogo Pessoa
# Versão: v2.1.0 - bash+starship+fzf no lugar de zsh, helper de status genérico
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

# ============================================================
# HELPER DE STATUS
# ============================================================
declare -A STATUS
for k in rpm brew brew_update distrobox_upgrade brew_packages \
         bashrc brew_bash network fonts icons rpm_manager flatpak; do
    STATUS["$k"]="${RED} ✗${NC}"
done

step_ok()   { STATUS["$1"]="${GREEN} ✓${NC}"; success "$2"; }
step_fail() { STATUS["$1"]="${RED} ✗${NC}";   warning "$2"; }
step_warn() { STATUS["$1"]="${YELLOW} !${NC}"; warning "$2"; }

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

while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" 2>/dev/null || exit
done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!

trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT

echo -e "${BLUE}╭───────────────────╮${NC}"
echo -e "${GREEN}│  ${BOLD}Silverblue-One ${NC}${GREEN}  │${NC}"
echo -e "${BLUE}╰───────────────────╯${NC}\n"

# ============================================================
# PACOTES RPM (DISTROBOX)
# ============================================================
info "Verificando Distrobox..."

rpm_note=""
if command -v distrobox >/dev/null 2>&1; then
    step_ok rpm "Distrobox já está instalado"
else
    info "Instalando Distrobox via rpm-ostree..."
    if rpm-ostree install distrobox >/dev/null 2>&1; then
        step_ok rpm "Distrobox adicionado à próxima implantação"
        rpm_note=" (disponível após o reinício)"
        warning "Reinicie o sistema para concluir a instalação do Distrobox"
    else
        step_fail rpm "Falha ao adicionar Distrobox via rpm-ostree"
    fi
fi

# ============================================================
# HOMEBREW
# ============================================================
BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"

if [[ -x "$BREW_BIN" ]]; then
    step_ok brew "Homebrew já instalado"
else
    info "Instalando Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" \
        >/dev/null 2>&1 \
        && [[ -x "$BREW_BIN" ]]; then
        step_ok brew "Homebrew instalado com sucesso"
    else
        step_fail brew "Falha ao instalar o Homebrew"
    fi
fi

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
        step_ok brew_update "Homebrew Auto-Update instalado com sucesso"
    else
        step_fail brew_update "Falha ao instalar o Homebrew Auto-Update"
    fi
fi

# ============================================================
# DISTROBOX CONTAINERS AUTO-UPDATE
# ============================================================
info "Instalando Distrobox Containers Auto-Update..."
if curl -fsSL https://raw.githubusercontent.com/diogopessoa/distrobox-upgrade/main/distrobox-upgrade.sh | bash; then
    step_ok distrobox_upgrade "Distrobox Containers Auto-Update instalado com sucesso"
else
    step_fail distrobox_upgrade "Falha ao instalar o Distrobox Containers Auto-Update"
fi

# ============================================================
# INSTALAÇÃO DE PROGRAMAS VIA HOMEBREW
# ============================================================
if [[ -x "$BREW_BIN" ]]; then
    info "Instalando Starship, fzf e utilitários via Homebrew..."
    if brew install -y starship fzf micro btop fastfetch; then
        step_ok brew_packages "Starship + fzf + Micro + Btop + fastfetch instalados"
    else
        step_fail brew_packages "Falha ao instalar Starship, fzf ou utilitários"
    fi
else
    step_fail brew_packages "Pacotes não instalados porque o Homebrew não está disponível"
fi

# ============================================================
# CONFIGURAÇÃO ~/.bashrc
# ============================================================
info "Configurando o arquivo ~/.bashrc..."

if cat << 'EOF' >> "$HOME/.bashrc"

# ============================================================
# HISTÓRICO DE COMANDOS (compartilhado entre sessões)
# ============================================================
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend
PROMPT_COMMAND="history -a; history -c; history -r; ${PROMPT_COMMAND:-}"

# ============================================================
# ALIASES (DISTROBOX & SISTEMA)
# ============================================================
alias apt="distrobox enter ubuntu -- sudo apt"
alias dnf="distrobox enter fedora -- sudo dnf"

# ============================================================
# FZF (Ctrl+R histórico, Ctrl+T arquivos, Alt+C diretórios)
# ============================================================
command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash)"

# ============================================================
# STARSHIP PROMPT
# ============================================================
command -v starship >/dev/null 2>&1 && eval "$(starship init bash)"
EOF
then
    step_ok bashrc "Arquivo ~/.bashrc configurado"
else
    step_fail bashrc "Falha ao configurar ~/.bashrc"
fi

# ============================================================
# INTEGRAÇÃO HOMEBREW + BASH (system-wide, /etc/profile.d)
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
        step_ok brew_bash "Integração Homebrew/Bash criada"
    else
        step_fail brew_bash "Não foi possível criar a integração Homebrew/Bash"
    fi
fi

# ============================================================
# DISABLE NETWORK WAIT-ONLINE
# ============================================================
info "Desativando NetworkManager-wait-online.service..."
if sudo systemctl disable NetworkManager-wait-online.service 2>/dev/null; then
    step_ok network "NetworkManager-wait-online.service desativado"
else
    step_fail network "Falha ao desativar NetworkManager-wait-online.service"
fi

# ============================================================
# OFFICE FONTS
# ============================================================
info "Instalando Office Fonts..."
FONTS_DIR="$HOME/.local/share/fonts/office_fonts"
TMP_ZIP="/tmp/office_fonts.zip"

mkdir -p "$FONTS_DIR"
if curl -fsSL https://raw.githubusercontent.com/diogopessoa/my-packages-lists/main/silverblue/office_fonts.zip -o "$TMP_ZIP" \
    && python3 -c "import zipfile; zipfile.ZipFile('$TMP_ZIP').extractall('$FONTS_DIR')" \
    && fc-cache -f "$HOME/.local/share/fonts"; then
    step_ok fonts "Fontes instaladas"
else
    step_fail fonts "Falha ao instalar as Office Fonts"
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
        step_ok icons "Tema de ícones Hatter instalado"
    else
        step_warn icons "Tema de ícones Hatter foi copiado, mas falhou ao atualizar o cache de ícones"
    fi
else
    step_fail icons "Falha ao baixar o tema de ícones Hatter"
fi
rm -rf "$HATTER_DIR"

# ============================================================
# BOOTC MANAGER
# ============================================================
info "Instalando Bootc Manager..."
if curl -fsSL https://raw.githubusercontent.com/diogopessoa/bootc-manager/main/install.sh | bash; then
    step_ok rpm_manager "Bootc Manager instalado com sucesso"
else
    step_fail rpm_manager "Falha ao instalar o Bootc Manager"
fi

# ============================================================
# FLATHUB E PACOTES FLATPAK
# ============================================================
info "Iniciando migração Flatpak para o Flathub..."

pkill -f gnome-software || true

if flatpak config --system --set languages "pt" \
    && flatpak remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo; then

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
    org.gtk.Gtk3theme.adw-gtk3
    org.gtk.Gtk3theme.adw-gtk3-dark
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
    org.gnome.font-viewer
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
            step_ok flatpak "Flatpaks do Flathub sincronizados"
        else
            step_warn flatpak "Flatpaks instalados, mas uma ou mais etapas de limpeza falharam"
        fi
    else
        step_fail flatpak "Falha ao instalar um ou mais Flatpaks"
    fi
else
    step_fail flatpak "Não foi possível configurar o Flathub"
fi

# ============================================================
# PAINEL RESUMO DE STATUS
# ============================================================
echo -e "\n"
echo "▶ Sumário de Modificações: "
echo -e " ${STATUS[rpm]} Distrobox (rpm-ostree)${rpm_note}"
echo -e " ${STATUS[brew]} Homebrew"
echo -e " ${STATUS[brew_update]} Homebrew Auto-Update"
echo -e " ${STATUS[distrobox_upgrade]} Distrobox Auto-Update"
echo -e " ${STATUS[brew_packages]} Starship + fzf + Micro + Btop + fastfetch"
echo -e " ${STATUS[bashrc]} Configuração ~/.bashrc (histórico, aliases, fzf, starship)"
echo -e " ${STATUS[brew_bash]} Integração Homebrew/Bash"
echo -e " ${STATUS[network]} Network wait-online desativado"
echo -e " ${STATUS[fonts]} Office Fonts"
echo -e " ${STATUS[icons]} Hatter Icons Theme"
echo -e " ${STATUS[rpm_manager]} Bootc Manager"
echo -e " ${STATUS[flatpak]} Transição Flatpak Fedora para Flathub"
echo ""
echo -e "${BLUE}${BOLD}Tudo pronto! Reinicie o sistema para aplicar as mudanças.${NC}"
read -rp "Pressione Enter para encerrar..."
echo ""
