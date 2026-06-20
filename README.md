# Silverblue One 🧢

<p align="center">
  <img src="https://github.com/diogopessoa/silverblue-one/blob/main/files/fedora-one-banner.jpg" alt="Silverblue One Banner" width="90%" style="border-radius: 8px;">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Fedora-Atomic%20OS-blue?style=for-the-badge&logo=fedora&logoColor=white" alt="Fedora OS">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="MIT License">
</p>

Script de pós-instalação para [Fedora Atomic](https://fedoraproject.org/atomic-desktops/) versões 42, 43, 44+.

## O que o script entrega

- **Fish Shell** (inclui boas-vindas): recursos inteligentes e fácil de usar no terminal 
- **Fisher**: gerenciador de plugins do Fish
- **Homebrew**: integrado e configurado para **Bash** e **Fish**
- **RPM-OSTree Manager**: CLI simples e intuitiva de gestão de camadas, rollback, instalar/remover pacotes RPM
- **Distrobox**: containers Linux integrados com a pasta do usuário
- Cria **alias** para executar **`apt`** (Ubuntu) e **`dnf`** (Fedora) via Distrobox
- **Fontes Office**: compátivel com OnlyOffice, LibreOffice e etc.
- **Ícones Hatter**: para um visual moderno e consistente
- Desativa **NetworkManager-wait-online.service** para acelerar a inicialização do sistema
- **Flatpk Flathub**: Migra Flatpak Fedora para **Flathub** (minha lista pessoal de programas)

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

## Alias APT DNF e Distrobox

Para utilizar os comandos `apt` e `dnf` no terminal com Distrobox, é necessário os containers **Ubuntu** e **Fedora** com o mesmo nome:

- ubuntu
- fedora

  
## Licença

- [MIT](https://github.com/diogopessoa/silverblue-one/blob/main/LICENSE)

## Referências

* [Fedora Atomic Desktops](https://fedoraproject.org/atomic-desktops/)
* [Homebrew](https://brew.sh)
* [Distrobox](https://distrobox.it)
* [Fish Shell](https://fishshell.com)
* [Fisher](https://github.com/jorgebucaran/fisher)

