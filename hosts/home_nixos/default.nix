{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  sops.age.keyFile = "/home/kang/.config/sops/age/keys.txt";

  sops.secrets.smb_credential = {
    sopsFile = ../../smb_credential.txt;
    format = "binary";
  };

  fileSystems."/mnt/share" = {
    device = "//192.168.219.200/pi";
    fsType = "cifs";
    options =
      let
        options = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
        uid = "1000";
        gid = "100";
        in ["${options},credentials=${config.sops.secrets.smb_credential.path},uid=${uid},gid=${gid}"];
  };

  services.zerotierone.enable = true;
}
