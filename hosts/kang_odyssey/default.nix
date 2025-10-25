{ config, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  sops.age.keyFile = "/etc/sops/age/keys.txt";

  sops.secrets.wpa_supplicant_secrets = {
    sopsFile = ./wpa_supplicant_secrets;
    format = "binary";
  };

  security.pam.enableFscrypt = true;
  services.openssh.enable = true;
  services.openssh.settings.KbdInteractiveAuthentication = false;

  programs.mosh.enable = true;

  networking.wireless.secretsFile = config.sops.secrets.wpa_supplicant_secrets.path;
  networking.wireless.networks = {
    kang_5G.pskRaw = "ext:psk_kang";
  };
}
