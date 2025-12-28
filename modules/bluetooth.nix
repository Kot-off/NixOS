{ config, pkgs, ... }:

{
  # ===========================================================================
  # BLUETOOTH НАСТРОЙКИ
  # ===========================================================================
  
  hardware.bluetooth = {
    enable = true;
    
    # Современный Bluetooth стек (рекомендуется)
    package = pkgs.bluezFull;
    
    # Включить дополнительные профили
    extraConfig = ''
      [General]
      Enable=Source,Sink,Media,Socket
      
      # Улучшенное качество звука (A2DP Sink)
      [A2DP]
      SBCSources=1
      MPEG24Sources=0
      
      # Автоподключение к доверенным устройствам
      [Policy]
      AutoEnable=true
    '';
    
    # Включить поддержку Bluetooth LE (Low Energy)
    settings = {
      General = {
        ControllerMode = "bredr";
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  
  # ===========================================================================
  # BLUETOOTH АУДИО (A2DP, HSP, HFP)
  # ===========================================================================
  
  # PipeWire для современного Bluetooth аудио
  services.pipewire = {
    enable = true;
    
    # Включить Bluetooth поддержку в PipeWire
    media-session.config.bluez-monitor.rules = [
      {
        # Автоматически переключать профиль
        matches = [ { "device.name" = "~bluez_card.*"; } ];
        actions = {
          update-props = {
            "bluez5.auto-connect" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
            "bluez5.hfphsp-backend" = "none";
            "bluez5.msbc-support" = true;
            "bluez5.sbc-xq-support" = true;
          };
        };
      }
    ];
  };
  
  # Альтернатива: PulseAudio с Bluetooth поддержкой
  hardware.pulseaudio = {
    enable = false;  # Отключено, так как используем PipeWire
    package = pkgs.pulseaudioFull;
    extraConfig = ''
      load-module module-bluetooth-discover
      load-module module-bluetooth-policy
      load-module module-switch-on-connect
    '';
  };
  
  # ===========================================================================
  # BLUETOOTH УТИЛИТЫ И ГРАФИЧЕСКИЕ ИНТЕРФЕЙСЫ
  # ===========================================================================
  
  environment.systemPackages = with pkgs; [
    # Командные утилиты
    bluez                     # Основные утилиты Bluetooth
    bluez-tools               # Дополнительные утилиты
    
    # Графические интерфейсы
    blueman                   # Менеджер Bluetooth (рекомендуется)
    gnome-bluetooth           # Для GNOME
    blueberry                 # Простой менеджер
    
    # Диагностика
    bt-dualmode               # Тестирование двойного режима
    bluetoothctl              # Консольное управление
    
    # Для разработчиков
    bluez-alsa                # ALSA бэкенд для Bluetooth
  ];
  
  # ===========================================================================
  # ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ ДЛЯ НОУТБУКОВ
  # ===========================================================================
  
  # Автоматическое включение Bluetooth при загрузке
  systemd.services.bluetooth = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "dbus";
      BusName = "org.bluez";
      ExecStart = "${pkgs.bluez}/libexec/bluetooth/bluetoothd --experimental";
      NotifyAccess = "main";
      LimitNPROC = 1;
      ProtectHome = true;
      ProtectSystem = "full";
    };
  };
  
  # Сервис для графического интерфейса Bluetooth
  services.blueman.enable = true;
  
  # ===========================================================================
  # НАСТРОЙКИ БЕЗОПАСНОСТИ BLUETOOTH
  # ===========================================================================
  
  # Ограничение видимости и доступа
  networking.firewall = {
    # Разрешить Bluetooth сервисы
    allowedTCPPorts = [ 
      4711    # PulseAudio
      4712    # PulseAudio
      4713    # PulseAudio
    ];
    
    allowedUDPPorts = [
      5353    # mDNS
      137     # NetBIOS
      138     # NetBIOS
    ];
  };
}