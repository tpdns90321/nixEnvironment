{ config, pkgs, user, ... }:
  let
    buildService = import ../../containers/buildService.nix { pkgs = pkgs; user = user; };
    buildComposeService = import ../../containers/buildComposeService.nix { pkgs = pkgs; user = user; };
  in {
  sops = {
    age.keyFile = "/home/${user}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../stay_secrets.yaml;
    secrets.smb_config = {
      format = "yaml";
      mode = "0444";
      path = "/home/${user}/.config/smb_config.yaml";
    };
    secrets.renew_duckdns = {
      sopsFile = ./renew_duckdns.sh;
      format = "binary";
      mode = "0555";
      path = "/home/${user}/.config/renew_duckdns.sh";
    };
    secrets.Caddyfile = {
      sopsFile = ./Caddyfile;
      format = "binary";
      mode = "0400";
      path = "/home/${user}/.config/Caddyfile";
    };
    secrets.vaultwarden_env = {
      sopsFile = ./vaultwarden_env;
      format = "binary";
      mode = "0400";
      path = "/home/${user}/.config/vaultwarden_env";
    };
    secrets.transmission_env = {
      sopsFile = ./transmission_env;
      format = "binary";
      mode = "0400";
      path = "/home/${user}/.config/transmission_env";
    };
    secrets.supabase_env = {
      sopsFile = ./supabase_env;
      format = "binary";
      mode = "0400";
      path = "/home/${user}/.config/supabase_env";
    };
    secrets.librechat_env = {
      sopsFile = ./librechat_env;
      format = "binary";
      mode = "0400";
      path = "/home/${user}/nixEnvironment/hosts/rpi4/LibreChat/.env";
    };
  };

  home.file."/home/${user}/nixEnvironment/hosts/rpi4/LibreChat/docker-compose.override.yml".source = ./librechat-docker-compose.override.yml;

  systemd.user.services."adguardhome" = (buildService {
    name = "adguardhome";
    description = "AdGuard Home";
    after = [ "sops-nix.service" ];
    options = "-p 7080:80/tcp -p 6053:53/tcp -p 6053:53/udp -p 9000:3000/tcp -p 6853:853/tcp -p 6784:784/udp -p 6853:853/udp -p 14853:8853/udp -p 11443:5443/tcp --volume /home/${user}/.config/adguardhome/work:/opt/adguardhome/work --volume /home/${user}/.config/adguardhome/conf:/opt/adguardhome/conf docker.io/adguard/adguardhome:latest";
  });

  systemd.user.services."caddy" = {
    Unit = {
      Description = "Caddy Web Server";
      After = [ "network.target" "sops-nix.service" ];
    };

    Install = {
      WantedBy = [ "default.target" ];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.caddy}/bin/caddy run --config /home/${user}/.config/Caddyfile --adapter caddyfile";
      Restart = "on-failure";
      RestartSec = 2;
      Environment = ''
      XDG_CONFIG_HOME=/home/${user}/.config
      XDG_DATA_HOME=/home/${user}/.local/share
      '';
    };
  };

  systemd.user.services."samba" = (buildService {
    name = "samba";
    description = "Samba";
    after = [ "sops-nix.service" ];
    options = "-p 6445:445/tcp --volume /home/${user}/.config/smb_config.yaml:/data/config.yml --volume /home/${user}/data:/samba ghcr.io/crazy-max/samba";
  });

  systemd.user.services."duckdns" = (buildService {
    name = "duckdns";
    description = "Crontab";
    after = [ "sops-nix.service" ];
    options = "--volume /home/${user}/.config/renew_duckdns.sh:/renew_duckdns.sh docker.io/curlimages/curl /renew_duckdns.sh";
  });

  systemd.user.services."vaultwarden" = (buildService {
    name = "vaultwarden";
    description = "Vaultwarden";
    after = [ "sops-nix.service" ];
    options = "-p 9080:80/tcp --env-file=/home/${user}/.config/vaultwarden_env --volume /home/${user}/.config/vaultwarden/data:/data docker.io/vaultwarden/server:latest";
  });

  systemd.user.services."transmission" = (buildService {
    name = "transmission";
    description = "Transmission";
    after = [ "sops-nix.service" ];
    options = "-p 9091:9091/tcp -p 51413:51413/tcp -p 51413:51413/udp --env-file=/home/${user}/.config/transmission_env --volume /home/${user}/.config/transmission:/config --volume /home/${user}/data/shared:/downloads --volume /home/${user}/data/shared:/watch docker.io/linuxserver/transmission:latest";
  });

  systemd.user.services."supabase" = (buildComposeService {
    description = "Supabase";
    src = "/home/${user}/nixEnvironment/hosts/rpi4/supabase/docker";
    options = "--env-file=/home/${user}/.config/supabase_env";
    after = [ "sops-nix.service" ];
    docker_host = "unix://%t/podman.sock";
  });

  systemd.user.services."librechat" = (buildComposeService {
    description = "LibreChat";
    src = "/home/${user}/nixEnvironment/hosts/rpi4/LibreChat";
    options = "-f /home/${user}/nixEnvironment/hosts/rpi4/LibreChat/docker-compose.override.yml --env-file=${config.sops.secrets.librechat_env.path}";
    after = [ "sops-nix.service" ];
    docker_host = "unix://%t/podman.sock";
  });
}
