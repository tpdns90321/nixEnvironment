{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.firewall = {
    enable = true;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.mosh.enable = true;
}
