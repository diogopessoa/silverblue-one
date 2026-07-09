# Scrip Pós-Instalação Pessoal 

<p align="center">
  <img src="https://github.com/diogopessoa/silverblue-one/blob/main/files/banner_silverblueone.png" alt="Silverblue One Banner" width="90%" style="border-radius: 8px;">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Fedora-Atomic%20OS-blue?style=for-the-badge&logo=fedora&logoColor=white" alt="Fedora OS">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="MIT License">
</p>

Script de pós-instalação para [Fedora Atomic](https://fedoraproject.org/atomic-desktops/) versões 42-44+.

## O que o script entrega

- **Fish Shell**:  Uma linha de comando inteligente com auto-sugestão e auto-completar
- **Fisher**: gerenciador de plugins do Fish
- **Homebrew**: gerenciador de pacotes para programas CLI
- **Terminal**: `brew` integrado e configurado com **Bash** e **Fish**
- **RPM-OSTree Manager**: CLI simples e intuitiva de gestão de camadas, rollback, instalar/remover pacotes RPM
- **Distrobox**: contâiner para instalar e executar qualquer distribuição Linux via terminal
- **Alias Distrobox (APT & DNF)**: cria `alias` para executar `apt` (Ubuntu) e `dnf` (Fedora) via Distrobox
- **Fontes Office**: compatível com OnlyOffice, LibreOffice e etc.
- **Ícones Hatter**: um visual moderno e consistente sem perder o estilo original
- **Desativa network wait-online**: acelera a inicialização do sistema
- **Flatpak Flathub (lista pessoal)**: Migra Flatpak Fedora para Flathub

## Compatibilidade

- Fedora Silverblue
- Fedora Kinoite
- Fedora COSMIC Atomic
- Fedora Atomic base

## Instalação

Execute:

```bash
curl -fsSL https://raw.githubusercontent.com/diogopessoa/silverblue-one/main/install.sh | bash
````

Após a instalação, reinicie o sistema para aplicar todos os ajustes.

```bash
systemctl reboot
```

## Destino dos Arquivos

Após a execução do script, os arquivos estarão localizados em:

```text
/ (Raiz do Sistema)
├── etc/
│   └── profile.d/
│       └── homebrew.sh              <-- Script de inicialização do Brew para Bash
│
└── var/home/seu_usuario/            <-- Sua pasta $HOME (Diretório real no Silverblue)
    ├── .config/
    │   └── fish/
    │       ├── config.fish          <-- Configuração principal (Blocos do Brew e Notificações)
    │       └── functions/
    │           ├── apt.fish         <-- Alias do comando apt via Distrobox
    │           ├── dnf.fish         <-- Alias do comando dnf via Distrobox
    │           ├── fish_greeting.fish <-- Mensagem customizada de boas-vindas do Fish
    │           └── fisher.fish      <-- Código base do gerenciador de plugins Fisher
    │
    └── .local/
        └── share/
            ├── fonts/
            │   └── office_fonts/    <-- Pasta onde os arquivos .ttf/.otf foram extraídos
            │
            └── icons/
                └── Hatter/          <-- Pasta com o tema de ícones macOS clonado do Git
```


## Alias APT DNF e Distrobox

Para utilizar os comandos `apt` e `dnf` no terminal com Distrobox é necessário que os containers **Ubuntu** e **Fedora** tenham o mesmo nome:

- ubuntu
- fedora

## Ajustes Pós Script

Após concluir a execução do script, fazer os [meus ajustes](https://github.com/diogopessoa/silverblue-one/blob/main/files/meus-ajustes.md)  pessoais de programas. 
  
## Licença

- [MIT](https://github.com/diogopessoa/silverblue-one/blob/main/LICENSE)

## Créditos

* [Fedora Atomic Desktops](https://fedoraproject.org/atomic-desktops/)
* [Homebrew](https://brew.sh)
* [Distrobox](https://distrobox.it)
* [Fish Shell](https://fishshell.com)
* [Fisher](https://github.com/jorgebucaran/fisher)
* [Hatter Icons Theme](https://github.com/Mibea/Hatter)

