{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./modules/network.nix
    ./modules/bluetooth.nix
    ./modules/security.nix
  ];

  # ФАЙЛОВЫЕ СИСТЕМЫ (ДОБАВИТЬ!)
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # ЗАГРУЗЧИК
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ПАРАМЕТРЫ ЯДРА
  boot.kernelParams = [
    "reboot=pci"
    "acpi=force"
    "nomodeset"
    "i8042.nopnp"
    "i8042.dumbkbd"
  ];

  # МОДУЛИ
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

  # X11 для Hyprland
  services.xserver = {
    enable = true;
    layout = "us,ru";
    xkbOptions = "grp:alt_shift_toggle";
    
    libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = true;
        tapping = true;
        disableWhileTyping = true;
      };
    };
    
    videoDrivers = [ "modesetting" ];
  };

  # HYPRLAND (УДАЛИТЬ nvidiaPatches!)
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    # УДАЛИТЬ: nvidiaPatches = false;
  };

  # Дисплей менеджер
  services.xserver.displayManager = {
    defaultSession = "hyprland";
    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  # ПОЛЬЗОВАТЕЛЬ
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
    initialPassword = "12345678";
  };

  # SUDO без пароля
  security.sudo.wheelNeedsPassword = false;

  # ПАКЕТЫ
  environment.systemPackages = with pkgs; [
    git vim wget curl
    kitty firefox
    rofi waybar swaybg
    grim slurp wl-clipboard
  ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "23.11";
}