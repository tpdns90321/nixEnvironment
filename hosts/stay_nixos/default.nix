{ ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  sops.age.keyFile = "/home/kang/.config/sops/age/keys.txt";

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
