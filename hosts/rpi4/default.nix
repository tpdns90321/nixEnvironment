{ config, pkgs, user, ... }: let buildService = import ../../containers/buildService.nix { pkgs = pkgs; user = user; }; in {
  sops = {
    age.keyFile = "/home/${user}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../stay_secrets.yaml;
    secrets.smb_config = {
      format = "yaml";
      mode = "0444";
      path = "/home/${user}/.config/smb_config.yaml";
    };
  };

  home.file.".config/Caddyfile".text = ''
192.168.*.* {
  reverse_proxy http://adguardhome
}

{
  respond "404" "Not Found"
}
  '';

  systemd.user.services."adguardhome" = (buildService {
    name = "adguardhome";
    description = "AdGuard Home";
    options = "--network podman -p 6053:53/tcp -p 6053:53/udp -p 9000:3000/tcp -p 6853:853/tcp -p 6784:784/udp -p 6853:853/udp -p 14853:8853/udp -p 11443:5443/tcp --volume /home/${user}/.config/adguardhome/work:/opt/adguardhome/work --volume /home/${user}/.config/adguardhome/conf:/opt/adguardhome/conf docker.io/adguard/adguardhome:latest";
  });

  systemd.user.services."caddy" = (buildService {
    name = "caddy";
    description = "Caddy";
    options = "--network podman -p 6080:80/tcp -p 6443:443/tcp -p 6443:443/udp -p 2019:8019/tcp --volume /home/${user}/.config/Caddyfile:/etc/caddy/Caddyfile docker.io/caddy/caddy:2.7";
  });

  systemd.user.services."samba" = (buildService {
    name = "samba";
    description = "Samba";
    after = [ "sops.service" ];
    options = "-p 6445:445/tcp --volume /home/${user}/.config/smb_config.yaml:/data/config.yml --volume /home/${user}/data:/samba ghcr.io/crazy-max/samba";
  });
}
