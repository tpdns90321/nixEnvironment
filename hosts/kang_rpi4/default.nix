{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  services.openssh.enable = true;
  programs.mosh.enable = true;
}
