{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./modules/network.nix      # Wi-Fi настройки
    ./modules/bluetooth.nix    # Bluetooth настройки
    ./modules/security.nix
    ./home/home.nix
  ];

  system.stateVersion = "23.11";
  
  # Разрешить несвободные программы (драйверы Wi-Fi/Bluetooth)
  nixpkgs.config.allowUnfree = true;
  
  # Ваш пользователь
  users.users.anton = {
    isNormalUser = true;
    extraGroups = [ 
      "wheel" 
      "networkmanager" 
      "video" 
      "audio" 
      "bluetooth"    
      "docker" 
    ];
  };
}