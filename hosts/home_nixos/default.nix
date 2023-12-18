{ config, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  sops.age.keyFile = "/home/kang/.config/sops/age/keys.txt";

  sops.secrets.stay_router_ovpn = {
    format = "binary";
    sopsFile = ../../client.ovpn;
  };

  sops.secrets.stay_router_user_pass = {
    format = "binary";
    sopsFile = ../../stay_router_user_pass.txt;
  };

  services.openvpn.servers = {
    stay_router = {
      config = ''
      config ${config.sops.secrets.stay_router_ovpn.path}
      auth-user-pass ${config.sops.secrets.stay_router_user_pass.path}
      '';
      updateResolvConf = true;
    };
  };
}
