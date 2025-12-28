{ config, pkgs, ... }:

{
  # ===========================================================================
  # Главный файл Home Manager для пользователя Anton
  # ===========================================================================
  
  imports = [
    ./firefox.nix
    ./desktop.nix
    ./programs.nix
    ./vpn.nix           ← ДОБАВЛЕН ИМПОРТ VPN
  ];

  # Основные настройки
  home.username = "anton";
  home.homeDirectory = "/home/anton";
  home.stateVersion = "23.11";
  
  # Менеджер пакетов
  nixpkgs.config.allowUnfree = true;
  
  # Программа управления конфигурацией
  programs.home-manager.enable = true;
  
  # ===========================================================================
  # ДОПОЛНИТЕЛЬНЫЕ СЕРВИСЫ
  # ===========================================================================
  
  services = {
    # Уведомления
    dunst.enable = true;
    
    # Менеджер паролей (если используете)
    # gnome-keyring.enable = true;
    
    # Автоматический запуск программ
    # autorandr.enable = true;  # Автоопределение мониторов
  };
  
  # ===========================================================================
  # ПЕРЕМЕННЫЕ ОКРУЖЕНИЯ
  # ===========================================================================
  
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "firefox";
    TERMINAL = "kitty";
    
    # Для HiDPI экрана
    GDK_SCALE = "2";
    QT_SCALE_FACTOR = "2";
    
    # Пути
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
  };
  
  # ===========================================================================
  # ПРОГРАММЫ ПО УМОЛЧАНИЮ
  # ===========================================================================
  
  home.packages = with pkgs; [
    # Файловый менеджер
    dolphin
    ranger
    
    # Архиваторы
    zip
    unzip
    p7zip
    
    # Сетевое
    wget
    curl
    
    # Просмотрщики
    eza          # Улучшенный ls
    bat          # Улучшенный cat
    fd           # Улучшенный find
    
    # Системный мониторинг
    htop
    btop
    nvtop        # Мониторинг NVIDIA
  ];
}