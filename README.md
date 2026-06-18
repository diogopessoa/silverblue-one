# Silverblue One

<p align="center">
  <img src="https://raw.githubusercontent.com/diogopessoa/silverblue-one/main/files/top-readme.png" alt="Silverblue One Banner" width="100%" style="border-radius: 8px;">
</p>

Script de pós-instalação para Fedora Atomic.

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

## Distrobox Containers

Para utilizar os comandos `apt` e `dnf` no terminal, é necessário os containers **Ubuntu** e **Fedora** com o mesmo nome:

- ubuntu
- fedora

  
## Licença

MIT

## Referências

* [Fedora Atomic Desktops](https://fedoraproject.org/atomic-desktops?utm_source=chatgpt.com)
* [Homebrew](https://brew.sh?utm_source=chatgpt.com)
* [Distrobox](https://distrobox.it?utm_source=chatgpt.com)
* [Fish Shell](https://fishshell.com?utm_source=chatgpt.com)
* [Fisher](https://github.com/jorgebucaran/fisher?utm_source=chatgpt.com)

