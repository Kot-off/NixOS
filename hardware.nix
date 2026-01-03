{ config, pkgs, ... }:

{
  # HiDPI настройки
  services.xserver.dpi = 192;
  
  # Тачпад
  services.xserver.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      disableWhileTyping = true;
    };
  };
  
  # Звук
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  
  # Wi-Fi/Bluetooth
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
}