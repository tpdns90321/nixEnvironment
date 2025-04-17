{ home-manager, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  services.zerotierone.enable = true;

  console.useXkbConfig = true;
  home-manager.users.kang.home.file.".env" = {
    enable = true;
    source = ./env;
  };
}
