{ config, pkgs, ... }:

{
  # ===========================================================================
  # НАСТРОЙКИ ЖЕЛЕЗА ДЛЯ HONOR MAGICBOOK 14 PRO
  # ===========================================================================
  
  # HiDPI настройки для экрана 3120x2080
  fonts.fontconfig.dpi = 192;
  
  # Управление питанием для ноутбука
  services.tlp = {
    enable = true;
    settings = {
      # Wi-Fi энергосбережение
      WIFI_PWR_ON_BAT = "off";      # Отключить на батарее
      
      # Bluetooth энергосбережение
      BLUETOOTH_ON_BAT = "on";      # Включить на батарее
      
      # Управление CPU
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      
      # Яркость экрана
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };
  
  # Тачпад
  services.xserver.libinput = {
    enable = true;
    touchpad = {
      naturalScrolling = true;  # Естественная прокрутка
      tapping = true;           # Тап вместо клика
      disableWhileTyping = true;
      accelSpeed = "0.5";       # Скорость курсора
    };
  };
  
  # Яркость экрана
  programs.light.enable = true;
  
  # Звук (современный стек)
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
    
    # Bluetooth кодекы
    media-session.config.bluez-monitor.rules = [
      {
        matches = [ { "device.name" = "~bluez_card.*"; } ];
        actions = {
          update-props = {
            "bluez5.autoswitch-profile" = false;
            "bluez5.auto-connect" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
          };
        };
      }
    ];
  };
  
  # Для Intel Wi-Fi/Bluetooth (часто в Honor)
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [
    firmwareLinuxNonfree  # Для Wi-Fi карт
    sof-firmware         # Для звука
  ];
  
  # Драйверы для Wi-Fi Intel (AX201/AX211 обычно в Honor)
  boot.kernelModules = [ "iwlwifi" ];
  hardware.wirelessRegulatoryDatabase = true;
  
  # Управление вентиляторами (если поддерживается)
  services.thermald.enable = true;
}