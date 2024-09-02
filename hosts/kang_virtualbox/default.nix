{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  programs.xwayland.enable = false;
  programs.sway.xwayland.enable = false;
  services.zerotierone.enable = true;
}
