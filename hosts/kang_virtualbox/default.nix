{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  services.zerotierone.enable = true;
}
