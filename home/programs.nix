{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Офис
    libreoffice
    okular          # Просмотр PDF
    
    # Мультимедиа
    vlc
    spotify
    
    # Интернет и общение
    telegram-desktop  # Telegram (уже был, оставляем)
    discord           # Discord (добавляем)
    
    # Стриминг и запись
    obs-studio        # OBS Studio для записи экрана и стриминга
    
    # Заметки и организация
    obsidian          # Obsidian для ведения заметок
    
    # Утилиты
    gparted         # Управление дисками
    gnome-calculator
    flameshot       # Создание скриншотов
    
    # Разработка
    vscode
    git
    
    # Дополнительные утилиты
    keepassxc       # Менеджер паролей (рекомендуется)
    bitwarden       # Альтернативный менеджер паролей
    veracrypt       # Шифрование файлов
    timeshift       # Резервное копирование системы
  ];
  
  # ===========================================================================
  # ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ ДЛЯ ПРОГРАММ
  # ===========================================================================
  
  # Obsidian - настройки по умолчанию
  home.file.".config/obsidian/obsidian.json".text = ''
    {
      "appearance": {
        "theme": "obsidian",
        "cssTheme": "Blue Topaz",
        "translucency": false,
        "nativeMenus": true
      },
      "editor": {
        "fontSize": 16,
        "lineHeight": 1.6,
        "readableLineLength": true,
        "tabSize": 2
      },
      "vaults": {
        "defaultVault": "/home/anton/Documents/Obsidian"
      }
    }
  '';
  
  # OBS Studio - настройки для записи экрана
  home.file.".config/obs-studio/global.ini".text = ''
    [General]
    Language=en
    [Basic]
    SceneCollectionName=Основная
    [Audio]
    MonitoringDeviceName=default
    [Output]
    Mode=Simple
    [SimpleOutput]
    VBitrate=5000
    ABitrate=160
    [AdvOut]
    [Video]
    BaseCX=3120
    BaseCY=2080
    OutputCX=1920
    OutputCY=1080
    FPSCommon=60
    [Hotkeys]
    [Advanced]
  '';
}