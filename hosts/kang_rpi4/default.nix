{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../k3sCluster
  ];

  services.openssh.enable = true;
  programs.mosh.enable = true;
}
