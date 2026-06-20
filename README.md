# Silverblue One 🧢

<p align="center">
  <img src="https://github.com/diogopessoa/silverblue-one/blob/main/files/fedora-one-banner.jpg" alt="Silverblue One Banner" width="90%" style="border-radius: 8px;">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Fedora-Atomic%20OS-blue?style=for-the-badge&logo=fedora&logoColor=white" alt="Fedora OS">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="MIT License">
</p>

Script de pós-instalação para [Fedora Atomic](https://fedoraproject.org/atomic-desktops/). Compatível com versões do Fedora Atomic 42, 43, 44+.

## O que o script faz

- Instala Fish Shell
- Instala Homebrew
- Instala Distrobox
- Instala Fisher
- Integra Fish Shell ao GNOME
- Integra Homebrew com Bash e Fish
- Adiciona notificações para comandos longos no terminal
- Cria alias para executar `apt` (Ubuntu) e `dnf` (Fedora) via Distrobox

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

