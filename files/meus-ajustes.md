# MEUS AJUSTES NO FEDORA

## SyncThing Desktop Linux

Após instalar o [SyncThingy](https://flathub.org/pt-BR/apps/com.github.zocker_160.SyncThingy) Flatpak no Desktop, instalar a extensão `AppIndicator and KStatusNotifierItem`.

Configuração:

``` 
 - Clique com o botão direito do mouse no ícone do SyncThiny na bandeja do sistema
 - Selecione Configurações
 - Pressione o botão "Instalar como serviço do sistema"
 - Pressione "Copiar para a área de transferência"
 - Abra o terminal
 - Cole o comando e pressione Enter e reinicie o sistema.
``` 
   
### Atalho Syncthing WebUI
 - no navegador de internet, crie um atalho para o menu de aplicativos (web app hub).
 - agora pode desativar a extensão 'AppIndicator'

### Filtro do SyncThing 

Ainda no navegavor de internet, abra a GUI local do Syncthing, e vá em: `Pastas => Filtros` 

**Pastas:**

**Obsidian**
- ID da pasta: gfaaq-gyot4
- Pasta: /var/home/diogo/Documentos/Obsidian
- Filtros:

``` 
(?d).DS_Store
(?d).thumbnails
(?d).trashed-*
(?d).stversions
(?d).stfolder
(?d)/.~lock.*#
(?d)/~$*
(?i)(?d)/*.tmp
(?i)(?d)/cache/
(?i)(?d)/temp/
(?i)/.obsidian/plugins/*/data.*
(?i)/.obsidian/*.json
(?i)/.obsidian/workspace
(?i)**/.obsidian/core-plugins.json
```

**Redmi 12S Camera** 
- ID da pasta:	aoj9k-47hzk
- Pasta: /var/home/diogo/Imagens/Redmi 12S Camera
- Filtros (nada)

---

## SyncThing no Android

Após instalar [Syncthing-Fork](https://play.google.com/store/apps/details?id=com.github.catfriend1.syncthingandroid&hl=pt_BR), vai em Pastas => Filtros

**Pastas:**

**Obsidian**
- ID da pasta: gfaaq-gyot4
- Pasta: /Documents/Obsidian
- Filtros:

``` 
(?d).DS_Store
(?d).thumbnails
(?d).trashed-*
(?d).stversions
(?d).stfolder
(?d)/.~lock.*#
(?d)/~$*
(?i)(?d)/*.tmp
(?i)(?d)/cache/
(?i)(?d)/temp/
(?i)/.obsidian/plugins/*/data.*
(?i)/.obsidian/*.json
(?i)/.obsidian/workspace
(?i)**/.obsidian/core-plugins.json
```

**Redmi 12S Camera** 
- ID da pasta:	aoj9k-47hzk
- Pasta: /DCIM
- Filtros (nada)

## VaultSync no iOS

### Etapa 1 - Instale

**[VaultSync na App Store](https://apps.apple.com/br/app/vaultsync-for-obsidian/id6761845197)**

Não abra o Obsidian primeiro.

Abra primeiro o VaultSync.

### Etapa 2 – Adicionar o iPhone como dispositivo Syncthing

No VaultSync escolha:

```
Add Device
```

Ele oferecerá duas opções:

* Scan QR Code (recomendado)
* Paste Device ID

Escolha **Scan QR Code**.

### Etapa 3 – Mostrar o QR Code no Linux

Na interface Web do Syncthing:

```
Ações
→ Mostrar ID
```

Será exibido um QR Code.

Aponte a câmera do iPhone para esse QR Code.

O VaultSync adicionará automaticamente o computador Linux como peer.

### Etapa 4 – Compartilhar o cofre

Ainda no Linux:

Abra a pasta compartilhada do Obsidian e marque o iphone.

Somente depois que a sincronização inicial terminar, abra o Obsidian.

### Etapa 5 – Primeira sincronização

Na primeira vez:

* deixe o iPhone desbloqueado;
* mantenha o VaultSync aberto;
* aguarde até que todos os arquivos sejam sincronizados.

### Etapa 6 - Automação de uploud VaultSync + Obsidian

A [documentação do VaultSync](https://github.com/psimaker/vaultsync/blob/main/docs/instant-upload.md) ensina a usar o app **Shortcuts** (Atalhos) do iPhone para fazer uplouds automáticos das notas ao fechar o Obsidian. 

## GNOME Shell Extensions
- Caffeine
- Clipboard indicator @tudomatu.com
- Compact top bar @metehan
- Dash to panel @micxgx
  - configurações salvas do dock ou painel: https://github.com/diogopessoa/my-package-lists/tree/main/share
- Foresight (open overview/activities when workspace is empty) @pesarder.dev
- Lock Keys @lockkeys
- Notification Timeout @chlumskyaclav
- ScreenToSpace @dilzhan 
- Vitals @corecoding
- WinTile @nowsci
- Workspace Bar @jguece

## Extensões de Navegador
- Dark Reader
- RainDrop.io
- Mate Translate
- Adguard (o Brave não precisa)
- Seek Subtitles for YouTube

## Brave Ajustes 

Menu, Configurações...

**=> Desative:**
- Brave Rewards/recompensas;
- ​Brave News/notícias;
- Brave Wallet/caritera;
- Notificações;
- Mostrar número ícone do escudo;

**=> Filtros de conteúdo:**
- Fanboys Annoyances + uBO
- Bypass Paywalls Clean 

**=> Ative:**
- Widevine
- Indexar outros mecanismos de pesquisa
- Economia de memória

## Anki addons
- Deck progress bar
- Passfail 2 remove the easy and hard buttons
- Review heatmap
- Smart keyboard

## Atalhos de Teclado Personalizados

#### Atalhos de programas
- Terminal Ptyxis: comando `ptyxis`, atalho `Super+T`
- Smile emojis: comando `/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=smile it.mijorus.smile`, atalho `Super+;` 
- Collector: comando `/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=collector it.mijorus.collector`, atalho `Super+C`

#### Atalhos de Som e Mídia
- Aumentar volume: `Alt+Seta_Acima`
- Diminuir volume: `Alt+Seta_Abaixo`
- Faixa anterior: `Alt+<`
- Próxima faixa: `Alt+>`
- Reproduzir ou Pausar: `Alt+P`

#### Janelas
- Fechar a janela: `Alt+X`

#### Navegação
- Mover a janela do espaço de trabalho à direita: `Alt+Super+Page Down`
- Mover a janela do espaço de trabalho à esquerda: `Alt+Super+Page Up`

## Obsidian plugins

- **Commander**
Por jsmorabito & phibrO
- **Dynamic Outline**
Por theopavlove
- **Hide Sidebars**
Por hasanyilmaz
-**Iconize**
Por Florian Woelki
- **Similar Notes**
Por Young Lee


## Ajustes Opcionais

### dns.forge.de 

- internet mais rápida e bloqueio de anúncios

```
# IPV4
49.12.67.122, 91.99.154.175, 176.9.93.198, 176.9.1.117

# IPV6
2a01:4f8:c013:29d::122, 2a01:4f8:c010:8c35::175
```

### NextDNS do meu Fedora 
[Minha configuração NextDNS](https://my.nextdns.io/74e421/setup)

``` 
IPV4:
45.90.28.136, 45.90.30.136

IPV6:
2a07:a8c0::74:e421, 2a07:a8c1::74:e421
```

#### Aplicar o NextDNS no Fedora manualmente

1. Abra **Configurações**.
2. Entre em **Rede** ou **Wi‑Fi**, dependendo da conexão usada.
3. Clique na **engrenagem** da conexão ativa.
4. Abra a aba **IPv4** e, se necessário, também **IPv6**.
5. Desative o DNS automático.
6. Adicione os servidores do `dnsforge` como endereços IP do provedor.
7. Clique em **Aplicar** e reconecte a rede, se preciso.

Usar NextDNS no Android e iOS também.

## Ações Rápidas no Nautilus

Script de **ações rápidas** com clique direito dentro do Nautilus:
- [GitHub nautilus-actions](https://github.com/diogopessoa/nautilus-actions)
