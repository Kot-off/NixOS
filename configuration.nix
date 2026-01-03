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
    device = "/dev/disk/by-label/root";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
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
    "i915.force_probe=7d51"
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

  # ========== X11 ДЛЯ HYPRLAND ==========
  services.xserver = {
    enable = true;
    
    xkb = {
      layout = "us,ru";
      options = "grp:alt_shift_toggle";
    };
    
    videoDrivers = [ "intel" ];
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
    networkmanagerapplet
    pavucontrol
    brightnessctl
    neovim
    mpv
  ];

  # ========== РАЗРЕШИТЬ НЕСВОБОДНЫЕ ПАКЕТЫ ==========
  nixpkgs.config.allowUnfree = true;

  # ========== ВЕРСИЯ СИСТЕМЫ ==========
  system.stateVersion = "25.11";
}