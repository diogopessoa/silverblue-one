# MEUS AJUSTES

## SyncThing Desktop

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

**Desktop** abre a GUI local do Syncthing no navegavor de internet, e vai em => Pastas => Filtros

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
(?d)**/.~lock.*#
(?d)**/~$*
(?d)**/.*.tmp
(?d)**/*.tmp
(?d)**/*.TMP
(?d)**/cache/
(?d)**/Cache/
(?d)**/temp/
(?d)**/Temp/
(?i)**/.obsidian/plugins/*/data.*
(?i)**/.obsidian/*.json
(?i)**/.obsidian/workspace
(?i)**/.obsidian/core-plugins.json
```

**Redmi 12S Camera** 
- ID da pasta:	aoj9k-47hzk
- Pasta: /var/home/diogo/Imagens/Redmi 12S Camera
- Filtros (nada)

---

## SyncThing Android

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
(?d)**/.~lock.*#
(?d)**/~$*
(?d)**/.*.tmp
(?d)**/*.tmp
(?d)**/*.TMP
(?d)**/cache/
(?d)**/Cache/
(?d)**/temp/
(?d)**/Temp/
(?i)**/.obsidian/plugins/*/data.*
(?i)**/.obsidian/*.json
(?i)**/.obsidian/workspace
(?i)**/.obsidian/core-plugins.json
```

**Redmi 12S Camera** 
- ID da pasta:	aoj9k-47hzk
- Pasta: /DCIM
- Filtros (nada)
  
## GNOME Shell Extensions
- Caffeine
- Clipboard indicator @tudomatu.com
- Compact top bar @metehan
- Dash to panel @micxgx
  - configurações salvas do dock ou painel: https://github.com/diogopessoa/my-package-lists/tree/main/share
- Lock Keys @lockkeys
- Notification Timeout @chlumskyaclav
- ScreenToSpace @dilzhan 
- Vitals @corecoding
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

#### Atalhos Som e Mídia
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


