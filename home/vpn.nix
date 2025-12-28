{ config, pkgs, ... }:

{
  # ===========================================================================
  # AmneziaVPN - российский VPN сервис
  # Официальный сайт: https://amnezia.org
  # Особенности:
  #   - Серверы в России и других странах
  #   - Поддержка OpenVPN, WireGuard, ShadowSocks
  #   - Обход блокировок РКН
  #   - Можно развернуть свой сервер
  # ===========================================================================
  
  home.packages = with pkgs; [
    # Основные утилиты для VPN (если не используете Amnezia GUI)
    wireguard-tools     # Для WireGuard конфигураций
    openvpn             # Для OpenVPN конфигураций
    networkmanager-openvpn
    networkmanager-l2tp
    
    # Утилиты для проверки VPN
    bind.dnsutils       # dig, nslookup
    mtr                 # Трассировка маршрута
  ];
  
  # ===========================================================================
  # УСТАНОВКА AMNEZIAVPN
  # Способ 1: AppImage (рекомендуется)
  # ===========================================================================
  
  # Создаем скрипт для запуска AmneziaVPN
  home.file.".local/bin/amnezia-vpn" = {
    text = ''
      #!/bin/sh
      # Путь к скачанному AppImage
      AMNEZIA_APPIMAGE="/home/${config.home.username}/Downloads/AmneziaVPN.AppImage"
      
      if [ -f "$AMNEZIA_APPIMAGE" ]; then
        # Даем права на выполнение
        chmod +x "$AMNEZIA_APPIMAGE"
        # Запускаем AmneziaVPN
        exec "$AMNEZIA_APPIMAGE"
      else
        echo "AmneziaVPN AppImage не найден!"
        echo "Скачайте с: https://amnezia.org/download"
        echo "И поместите в: $AMNEZIA_APPIMAGE"
        exit 1
      fi
    '';
    executable = true;
  };
  
  # ===========================================================================
  # СПОСОБ 2: Через Flatpak (если включен)
  # ===========================================================================
  
  # Если используете Flatpak, раскомментируйте:
  # services.flatpak.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  
  # home.packages = with pkgs; [
  #   flatpak
  # ];
  
  # После установки Flatpak:
  # flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  # flatpak install org.amneziavpn.AmneziaVPN
  
  # ===========================================================================
  # РУЧНАЯ НАСТРОЙКА WIREGUARD (если используете Amnezia с WireGuard)
  # ===========================================================================
  
  # Пример конфигурации WireGuard
  home.file.".config/wireguard/amnezia.conf" = {
    text = ''
      # Конфигурация WireGuard для AmneziaVPN
      # Замените на свои ключи и адреса!
      
      [Interface]
      PrivateKey = YOUR_PRIVATE_KEY_HERE
      Address = 10.0.0.2/24
      DNS = 1.1.1.1, 8.8.8.8
      
      [Peer]
      PublicKey = SERVER_PUBLIC_KEY_HERE
      AllowedIPs = 0.0.0.0/0, ::/0
      Endpoint = amnezia-server.com:51820
      PersistentKeepalive = 25
    '';
  };
  
  # ===========================================================================
  # НАСТРОЙКИ СЕТИ ДЛЯ VPN
  # ===========================================================================
  
  # Автоматическое подключение к Wi-Fi сетям
  systemd.user.services.network-autoconnect = {
    Unit.Description = "Auto-connect to known WiFi networks";
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.networkmanager}/bin/nmcli connection up --ask";
    };
    Install.WantedBy = [ "default.target" ];
  };
  
  # ===========================================================================
  # СКРИПТ ДЛЯ ПРОВЕРКИ VPN
  # ===========================================================================
  
  home.file.".local/bin/check-vpn" = {
    text = ''
      #!/bin/bash
      echo "=== ПРОВЕРКА VPN ==="
      echo ""
      
      echo "1. Внешний IP адрес:"
      curl -s ifconfig.me
      echo ""
      echo ""
      
      echo "2. Локация по IP:"
      curl -s ipinfo.io | grep -E '"city|"region|"country"'
      echo ""
      
      echo "3. Проверка утечек DNS:"
      dig +short myip.opendns.com @resolver1.opendns.com
      echo ""
      
      echo "4. Активные соединения VPN:"
      ip link show | grep -E "(tun|wg|ppp)"
      echo ""
      
      echo "5. Маршрут до 8.8.8.8:"
      mtr -r -c 1 8.8.8.8 | head -5
    '';
    executable = true;
  };
  
  # ===========================================================================
  # ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ БРАУЗЕРА ДЛЯ VPN
  # ===========================================================================
  
  programs.firefox.profiles.default.settings = {
    # WebRTC leak protection
    "media.peerconnection.enabled" = false;
    "media.navigator.enabled" = false;
    
    # Geolocation
    "geo.enabled" = false;
    
    # DNS over HTTPS
    "network.trr.mode" = 2;
    "network.trr.uri" = "https://mozilla.cloudflare-dns.com/dns-query";
  };
}