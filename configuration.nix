{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./modules/network.nix
    ./modules/bluetooth.nix
    ./modules/security.nix
  ];

  # ЗАГРУЗЧИК (без этого система не загрузится)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ПАРАМЕТРЫ ЯДРА для Honor
  boot.kernelParams = [
    "reboot=pci"
    "acpi=force"
    "nomodeset"
    "i8042.nopnp"  # для PS/2 клавиатуры/тачпада
    "i8042.dumbkbd"
  ];

  # МОДУЛИ для клавиатуры и тачпада
  boot.initrd.kernelModules = [ "i8042" ];
  boot.kernelModules = [ "uinput" "evdev" ];

  # СЕТЬ
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # ВРЕМЯ
  time.timeZone = "Europe/Moscow";

  # ЛОКАЛИЗАЦИЯ
  i18n.defaultLocale = "ru_RU.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # X11 для Hyprland (Hyprland работает поверх XWayland)
  services.xserver = {
    enable = true;
    layout = "us,ru";
    xkbOptions = "grp:alt_shift_toggle";
    
    # ДРАЙВЕРЫ ВВОДА - для клавиатуры и тачпада
    libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = true;
        tapping = true;
        disableWhileTyping = true;
      };
    };
    
    # Универсальный видео драйвер
    videoDrivers = [ "modesetting" ];
  };

  # HYPRLAND
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    nvidiaPatches = false;  # у тебя Intel/AMD
  };

  # Дисплей менеджер SDDM (для Hyprland)
  services.xserver.displayManager = {
    defaultSession = "hyprland";
    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  # ОТКЛЮЧАЕМ GNOME (если был)
  services.xserver.desktopManager.gnome.enable = false;
  services.xserver.displayManager.gdm.enable = false;

  # ПОЛЬЗОВАТЕЛЬ
  users.users.anton = {
    isNormalUser = true;
    extraGroups = [ 
      "wheel" 
      "networkmanager" 
      "video" 
      "audio" 
      "input"      # для клавиатуры/мыши
      "bluetooth" 
    ];
    initialPassword = "12345678";
  };

  # SUDO без пароля
  security.sudo.wheelNeedsPassword = false;

  # ОБЯЗАТЕЛЬНЫЕ ПАКЕТЫ
  environment.systemPackages = with pkgs; [
    # Системные
    git
    vim
    wget
    curl
    
    # Hyprland минимальный набор
    kitty     # терминал
    firefox   # браузер
    
    # Рабочий стол Hyprland
    rofi      # меню запуска
    waybar    # панель
    swaybg    # обои
    
    # Утилиты
    grim      # скриншоты
    slurp
    wl-clipboard
  ];

  # Разрешить несвободные пакеты (драйверы Wi-Fi)
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "23.11";
}