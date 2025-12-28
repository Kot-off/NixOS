{ config, pkgs, ... }:

{
  programs.firefox = {
    enable = true;  # Включаем Firefox
    
    profiles.anton = {  # Профиль для Anton
      isDefault = true;  # Это основной профиль
      
      settings = {
        # Настройки приватности
        "privacy.trackingprotection.enabled" = true;  # Блокируем слежку
        
        # Для вашего большого экрана (3120x2080)
        "layout.css.devPixelsPerPx" = "1.5";  # Увеличиваем текст и кнопки
      };
      
      # Расширения (дополнения для браузера)
      extensions = [
        "ublock-origin"     # Блокировщик рекламы (как AdBlock)
        "darkreader"        # Темный режим для глаз
      ];
      
      # Поисковые системы
      search = {
        default = "DuckDuckGo";  # По умолчанию DuckDuckGo
        engines = {
          "Google" = {
            urls = [{
              template = "https://google.com/search?q={searchTerms}";
            }];
          };
          "Яндекс" = {
            urls = [{
              template = "https://yandex.ru/search/?text={searchTerms}";
            }];
          };
        };
      };
    };
  };
}