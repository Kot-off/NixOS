{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./modules/network.nix
    ./modules/bluetooth.nix
    ./modules/security.nix
  ];

  # ========== ФАЙЛОВЫЕ СИСТЕМЫ ==========
  fileSystems."/" = {
    device = "/dev/disk/by-label/root";  # Используем метку!
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";   # Используем метку!
    fsType = "vfat";
  };

  # ========== ЗАГРУЗЧИК ==========
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ========== ПАРАМЕТРЫ ЯДРА ==========
  boot.kernelParams = [
    "i8042.nopnp"
    "i8042.dumbkbd"
    "iTCO_wdt.heartbeat=0"  
  ];

  # ========== МОДУЛИ ЯДРА ==========
  boot.initrd.kernelModules = [ "i8042" ];
  boot.kernelModules = [ "uinput" "evdev" ];

  # ========== СЕТЬ ==========
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # ========== ВРЕМЯ ==========
  time.timeZone = "Europe/Moscow";

  # ========== ЛОКАЛИЗАЦИЯ ==========
  i18n.defaultLocale = "ru_RU.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

 # ========== OPENGL ДЛЯ INTEL ARC ==========
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver    # для аппаратного декодирования видео
      vaapiIntel            # VA-API интерфейс
      libvdpau-va-gl        # VDPAU через VA-API
    ];
  };
  
  # ========== X11 ДЛЯ HYPRLAND ==========
  services.xserver = {
    enable = true;
    
    xkb = {
      layout = "us,ru";
      options = "grp:alt_shift_toggle";
    };
    
    videoDrivers = [ "modesetting" ];
  };

  # ========== LIBINPUT (тачпад) ==========
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      disableWhileTyping = true;
    };
  };

  # ========== HYPRLAND ==========
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # ========== ДИСПЛЕЙ МЕНЕДЖЕР ==========
  services.displayManager = {
    defaultSession = "hyprland";
    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  # ========== ПОЛЬЗОВАТЕЛЬ ==========
  users.users.anton = {
    isNormalUser = true;
    extraGroups = [ 
      "wheel" 
      "networkmanager" 
      "video" 
      "audio" 
      "input"
      "bluetooth" 
    ];
    initialPassword = "12345";
  };

  # Пароль для root
  users.users.root.initialPassword = "12345";

  # ========== SUDO БЕЗ ПАРОЛЯ ==========
  security.sudo.wheelNeedsPassword = false;

  # ========== СИСТЕМНЫЕ ПАКЕТЫ ==========
  environment.systemPackages = with pkgs; [
    git vim wget curl
    kitty firefox
    rofi waybar swaybg
    grim slurp wl-clipboard
    
    # Дополнительные утилиты для удобства
    networkmanagerapplet  # Индикатор сети
    pavucontrol           # Управление звуком
    brightnessctl         # Яркость экрана
    neovim                # Редактор
    mpv                   # Видеоплеер
  ];

  # ========== РАЗРЕШИТЬ НЕСВОБОДНЫЕ ПАКЕТЫ ==========
  nixpkgs.config.allowUnfree = true;

  # ========== ВЕРСИЯ СИСТЕМЫ ==========
  system.stateVersion = "25.11";
}