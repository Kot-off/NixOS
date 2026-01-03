{ config, pkgs, ... }:

{
  # ===========================================================================
  # СЕТЕВЫЕ НАСТРОЙКИ (Wi-Fi + Ethernet + VPN)
  # ===========================================================================
  
  networking = {
    # Включаем NetworkManager (управляет Wi-Fi, Ethernet, VPN)
    networkmanager.enable = true;
    
    # Имя компьютера в сети
    hostName = "nixos";
    
    # Отключить IPv6 (для предотвращения утечек через VPN)
    enableIPv6 = false;
    
    # DNS серверы (когда VPN отключен)
    nameservers = [ 
      "1.1.1.1"  # Cloudflare (быстрый и приватный)
      "8.8.8.8"  # Google (резервный)
    ];
    
    # Настройки фаервола
    firewall = {
      enable = true;
      
      # Разрешить Wi-Fi и Bluetooth
      allowedUDPPorts = [ 
        67 68    # DHCP
        53       # DNS
        1900     # UPnP
        5353     # mDNS/Bonjour
      ];
      
      allowedTCPPorts = [ 
        53       # DNS
        22       # SSH (если нужно)
      ];
      
      # Разрешить ping (можно отключить для безопасности)
      allowPing = true;
    };
  };
  
  # ===========================================================================
  # NETWORKMANAGER - УПРАВЛЕНИЕ WI-FI
  # ===========================================================================
  
  networking.networkmanager = {
    # Плагины для разных типов подключений
    plugins = with pkgs; [
      networkmanager-openvpn      # Для OpenVPN
      networkmanager-l2tp         # Для L2TP VPN
      networkmanager-strongswan   # Для IPSec VPN
    ];
    
    # Дополнительные настройки Wi-Fi
    wifi = {
      # Защита приватности - случайный MAC-адрес для каждой сети
      scanRandMacAddress = true;   # Случайный MAC при сканировании
      macAddress = "random";       # Случайный MAC при подключении
      
      # Мощность сигнала (для ноутбука)
      powersave = false;           # Отключить энергосбережение (лучше сигнал)
    };
  };
  
  # ===========================================================================
  # ДОПОЛНИТЕЛЬНЫЕ СЕРВИСЫ ДЛЯ СЕТИ
  # ===========================================================================
  
  # DNS через TLS для шифрования DNS запросов
  services.resolved = {
    enable = true;
    dnssec = "true";              # Проверка DNSSEC
    domains = [ "~." ];           # Для всех доменов
    fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
    extraConfig = ''
      DNSOverTLS=yes              # Шифрование DNS
      Cache=yes                   # Кэширование DNS
    '';
  };
  
  # ===========================================================================
  # УТИЛИТЫ ДЛЯ ДИАГНОСТИКИ СЕТИ
  # ===========================================================================
  
  environment.systemPackages = with pkgs; [
    # Wi-Fi утилиты
    iw                            # Управление Wi-Fi интерфейсами
    iwgtk                         # Графический интерфейс для iw
    wpa_supplicant_gui           # Графический интерфейс WPA
    
    # Диагностика сети
    bind.dnsutils                # dig, nslookup
    mtr                          # Трассировка маршрута
    netcat-openbsd               # Проверка портов
    tcpdump                      # Анализ трафика
    nmap                         # Сканирование сети
    wireshark                    # Глубокий анализ (GUI)
    
    # Speedtest
    speedtest-cli                # Проверка скорости интернета
  ];
}