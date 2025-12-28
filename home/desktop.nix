{ config, pkgs, ... }:

{
  # ===========================================================================
  # НАСТРОЙКИ РАБОЧЕГО СТОЛА HYPRLAND
  # ===========================================================================
  
  wayland.windowManager.hyprland = {
    enable = true;
    
    settings = {
      # НАСТРОЙКИ ДЛЯ HONOR MAGICBOOK 14 PRO
      monitor = ",3120x2080@120,auto,1.5";  # Разрешение экрана
      
      # АВТОЗАПУСК ПРИ ВХОДЕ
      exec-once = [
        # Основные программы
        "firefox"           # Браузер
        "kitty"             # Терминал
        "waybar"            # Панель вверху экрана
        
        # ОБОИ - автоматическая установка при запуске
        # Выберите ОДИН вариант (раскомментируйте нужный):
        
        # Вариант 1: Статические обои (по умолчанию)
        "swaybg -i /etc/nixos/assets/images/wallpaper-1.jpg -m fill"
        
        # Вариант 2: Видео-обои (НОВОЕ!)
        # "video-wallpaper random"
        
        # Вариант 3: Случайные обои каждые 30 минут
        # "bash -c 'while true; do /etc/nixos/assets/wallpaper-manager.sh random; sleep 1800; done'"
        
        # Вариант 4: Hyprpaper
        # "hyprpaper"
        
        # Вариант 5: Чередование статических и видео обоев (НОВОЕ!)
        # "bash -c 'if [ \$((RANDOM % 2)) -eq 0 ]; then video-wallpaper random; else /etc/nixos/assets/wallpaper-manager.sh random; fi'"
      ];
      
      # ГОРЯЧИЕ КЛАВИШИ
      bind = [
        "SUPER, Q, exec, kitty"           # Win+Q = открыть терминал
        "SUPER, C, killactive"            # Win+C = закрыть окно
        "SUPER, D, exec, rofi -show drun" # Win+D = меню программ
        "SUPER, 1, workspace, 1"          # Win+1 = перейти на рабочий стол 1
        "SUPER, 2, workspace, 2"          # Win+2 = перейти на рабочий стол 2
        "SUPER, 3, workspace, 3"          # Win+3 = перейти на рабочий стол 3
        "SUPER, W, exec, firefox"         # Win+W = открыть Firefox
        
        # Горячие клавиши для управления обоями
        "SUPER SHIFT, W, exec, /etc/nixos/assets/wallpaper-manager.sh random"  # Случайные обои
        "SUPER ALT, W, exec, /etc/nixos/assets/wallpaper-manager.sh"           # Меню обоев
        
        # НОВЫЕ: Горячие клавиши для видео-обоев
        "SUPER CTRL, V, exec, video-wallpaper random"     # Случайные видео-обои
        "SUPER CTRL SHIFT, V, exec, video-wallpaper stop" # Остановить видео-обои
        "SUPER CTRL ALT, V, exec, video-wallpaper"        # Меню видео-обоев

        # Горячие клавиши для управления обоями
        "SUPER SHIFT, W, exec, /etc/nixos/assets/wallpaper-manager.sh random"  # Случайные обои
        "SUPER ALT, W, exec, /etc/nixos/assets/wallpaper-manager.sh"           # Меню обоев
  
        # Горячие клавиши для видео-обоев
        "SUPER CTRL, V, exec, video-wallpaper random"     # Случайные видео-обои
        "SUPER CTRL SHIFT, V, exec, video-wallpaper stop" # Остановить видео-обои
        "SUPER CTRL ALT, V, exec, video-wallpaper"        # Меню видео-обоев
  
        # НОВЫЕ: Горячие клавиши для OBS Studio
        "SUPER SHIFT, O, exec, obs"                       # Открыть OBS Studio
        "SUPER CTRL SHIFT, S, exec, obs --startrecording" # Начать запись
        "SUPER CTRL SHIFT, X, exec, obs --stoprecording"  # Остановить запись
  
        # НОВЫЕ: Горячие клавиши для Obsidian
        "SUPER SHIFT, N, exec, obsidian"                  # Открыть Obsidian
  
        # НОВЫЕ: Горячие клавиши для приложений
        "SUPER SHIFT, T, exec, telegram-desktop"          # Открыть Telegram
        "SUPER SHIFT, D, exec, discord"                   # Открыть Discord 

        # Wi-Fi управление
        "SUPER SHIFT, N, exec, nm-connection-editor"  # Открыть настройки сети
  
        # Bluetooth управление
        "SUPER SHIFT, B, exec, blueman-manager"       # Открыть Bluetooth менеджер
        "SUPER CTRL, B, exec, bluetoothctl power on"  # Включить Bluetooth
        "SUPER CTRL SHIFT, B, exec, bluetoothctl power off" # Выключить Bluetooth     
      ];
    };
    
    # ДОПОЛНИТЕЛЬНЫЕ КОНФИГУРАЦИИ
    extraConfig = ''
      # ПРАВИЛА ДЛЯ ОКОН
      # Окна по центру при открытии
      general {
        cursor_inactive_timeout = 5
        no_cursor_warps = false
      }
      
      # Анимации
      animations {
        enabled = yes
        bezier = myBezier, 0.05, 0.9, 0.1, 1.05
        animation = windows, 1, 7, myBezier
        animation = windowsOut, 1, 7, default, popin 80%
        animation = border, 1, 10, default
        animation = borderangle, 1, 8, default
        animation = fade, 1, 7, default
        animation = workspaces, 1, 6, default
      }
      
      # Кастомизация
      decoration {
        rounding = 10
        blur = yes
        blur_size = 3
        blur_passes = 1
        blur_new_optimizations = on
        drop_shadow = yes
        shadow_range = 4
        shadow_render_power = 3
        col.shadow = rgba(1a1a1aee)
      }
    '';
  };
  
  # ===========================================================================
  # ШРИФТЫ
  # ===========================================================================
  
  home.file = {
    # Копируем шрифты из assets/fonts в домашнюю папку
    ".local/share/fonts/JetBrainsMono.ttf".source = 
      config.lib.file.mkOutOfStoreSymlink "/etc/nixos/assets/fonts/JetBrainsMono.ttf";
    
    ".local/share/fonts/FiraCode.ttf".source = 
      config.lib.file.mkOutOfStoreSymlink "/etc/nixos/assets/fonts/FiraCode.ttf";
    
    # Создаем симлинк на текущие обои
    ".config/current-wallpaper.jpg".source = 
      config.lib.file.mkOutOfStoreSymlink "/etc/nixos/assets/images/wallpaper-1.jpg";
    
    # НОВОЕ: Создаем скрипт для видео-обоев
    ".local/bin/video-wallpaper".source = 
      config.lib.file.mkOutOfStoreSymlink "/etc/nixos/assets/video-wallpaper.sh";
  };
  
  # ===========================================================================
  # ПАКЕТЫ ДЛЯ РАБОЧЕГО СТОЛА
  # ===========================================================================
  
  home.packages = with pkgs; [
    # Управление обоями
    mpv             # Видеоплеер (ДЛЯ ВИДЕО-ОБОЕВ)
    swaybg          # Простой менеджер обоев
    hyprpaper       # Обои для Hyprland
    feh             # Легковесный просмотрщик
    swww            # Анимированные обои

    # Утилиты для работы с видео
    ffmpeg                  # Конвертация видео (ДЛЯ ОПТИМИЗАЦИИ)
    ffmpegthumbnailer       # Миниатюры видео
    vlc                     # Альтернативный видеоплеер
    
    # Для экономии ресурсов видео-обоев
    cpulimit                # Ограничение CPU (важно для ноутбука)
    
    # Скриншоты
    grim
    slurp
    wl-clipboard
    
    # Шрифты
    font-awesome
    material-design-icons
    noto-fonts
    noto-fonts-emoji
    jetbrains-mono
    fira-code
  ];
  
  # ===========================================================================
  # АВТОМАТИЧЕСКАЯ СМЕНА ОБОЕВ КАЖДЫЕ 30 МИНУТ
  # ===========================================================================
  
  # Создаем systemd сервис для автоматической смены обоев
  systemd.user.services.auto-wallpaper = {
    Unit = {
      Description = "Automatic wallpaper changer every 30 minutes";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash -c 'while true; do /etc/nixos/assets/wallpaper-manager.sh random; sleep 1800; done'";
      Restart = "always";
      RestartSec = 5;
    };
    
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
  
  # Альтернатива: через systemd timer (более правильный способ)
  systemd.user.timers.auto-wallpaper-timer = {
    Unit = {
      Description = "Timer for automatic wallpaper change";
    };
    
    Timer = {
      OnBootSec = "1min";      # Запустить через 1 минуту после загрузки
      OnUnitActiveSec = "30min"; # Повторять каждые 30 минут
      Persistent = true;
    };
    
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
  
  systemd.user.services.auto-wallpaper-timer-service = {
    Unit = {
      Description = "Change wallpaper on timer";
    };
    
    Service = {
      Type = "oneshot";
      ExecStart = "/etc/nixos/assets/wallpaper-manager.sh random";
    };
  };
  
  # НОВОЕ: Systemd сервис для автоматической смены видео-обоев
  systemd.user.services.auto-video-wallpaper = {
    Unit = {
      Description = "Automatic video wallpaper changer";
      After = [ "graphical-session.target" ];
    };
    
    Service = {
      Type = "oneshot";
      ExecStart = "/etc/nixos/assets/video-wallpaper.sh random";
    };
  };
  
  systemd.user.timers.auto-video-wallpaper = {
    Unit = {
      Description = "Timer for video wallpaper change";
    };
    
    Timer = {
      OnBootSec = "2min";       # Запустить через 2 минуты после загрузки
      OnUnitActiveSec = "1h";   # Менять видео каждые 1 час
      Persistent = true;
    };
    
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
  
  # ===========================================================================
  # НАСТРОЙКА ШРИФТОВ В СИСТЕМЕ
  # ===========================================================================
  
  fonts.fontconfig.enable = true;
  
  # Дополнительные настройки шрифтов
  home.file.".config/fontconfig/fonts.conf".text = ''
    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
      <!-- Включить сглаживание -->
      <match target="font">
        <edit name="antialias" mode="assign">
          <bool>true</bool>
        </edit>
        <edit name="hinting" mode="assign">
          <bool>true</bool>
        </edit>
        <edit name="hintstyle" mode="assign">
          <const>hintslight</const>
        </edit>
        <edit name="rgba" mode="assign">
          <const>rgb</const>
        </edit>
      </match>
      
      <!-- Для HiDPI экрана -->
      <match target="font">
        <edit name="dpi" mode="assign">
          <double>192</double>
        </edit>
      </match>
      
      <!-- Предпочтительные шрифты -->
      <alias>
        <family>sans-serif</family>
        <prefer>
          <family>Noto Sans</family>
          <family>DejaVu Sans</family>
        </prefer>
      </alias>
      
      <alias>
        <family>monospace</family>
        <prefer>
          <family>JetBrains Mono</family>
          <family>Fira Code</family>
          <family>DejaVu Sans Mono</family>
        </prefer>
      </alias>
    </fontconfig>
  '';
  
  # НОВОЕ: Создаем папку для видео если не существует
  systemd.user.services.create-video-dir = {
    Unit = {
      Description = "Create video directory for wallpapers";
      Before = [ "graphical-session.target" ];
    };
    
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.coreutils}/bin/mkdir -p /etc/nixos/assets/videos";
      RemainAfterExit = true;
    };
    
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}