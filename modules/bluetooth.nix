{ config, pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
    
    settings = {
      General = {
        ControllerMode = "bredr";
        Enable = "Source,Sink,Media,Socket";
        AutoEnable = true;
      };
    };
  };
  
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
  };
  
  environment.systemPackages = with pkgs; [
    bluez
    bluez-tools
    blueman
  ];
  
  services.blueman.enable = true;
}