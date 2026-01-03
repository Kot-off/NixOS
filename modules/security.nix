{ config, pkgs, ... }:

{
  # Базовые настройки безопасности
  security = {
    sudo.wheelNeedsPassword = false;
    polkit.enable = true;
  };
}