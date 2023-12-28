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
  services.openssh.extraConfig = ''
    usePAM yes
  '';
  programs.mosh.enable = true;
}
