{ config, pkgs, ... }:

{
  # HiDPI настройки (новый способ)
  services.xserver.dpi = 192;
  
  # Тачпад (новый способ)
  services.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;
      tapping = true;
      disableWhileTyping = true;
    };
  };
  
  # Звук
  services.pulseaudio.enable = false;
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