{ pkgs, user, ... }: {
  home.file."/home/${user}/.config/containers" = {
    source = ./containers;
  };

  systemd.user.services."adguardhome" = {
    Unit = {
      Description = "AdGuard Home";
      After = [ "network.target" ];
    };

    Install = {
      WantedBy = [ "default.target" ];
    };

    Service = {
      Type = "simple";
      ExecPreStart = ''
        ${pkgs.podman}/bin/podman rm adguardhome >> /dev/null 2>&1 || true
        mkdir -p /home/${user}/.config/adguardhome/{work,conf} >> /dev/null 2>&1 || true
      '';
      ExecStart = ''
        ${pkgs.podman}/bin/podman run \
          --name adguardhome \
          --port 6053:53/tcp --port 6053:53/udp \
          --port 6080:80/tcp --port 6443:443/tcp --port 6443:443/udp --port 9000:3000/tcp \
          --port 6853:853/tcp \
          --port 6784:784/udp --port 6853:853/udp --port 14853:8853/udp \
          --port 11443:5443/tcp \
          --volume /home/${user}/.config/adguardhome/work:/opt/adguardhome/work \
          --volume /home/${user}/.config/adguardhome/conf:/opt/adguardhome/conf \
          docker.io/adguard/adguardhome:latest
      '';
      ExecStop = ''
        ${pkgs.podman}/bin/podman stop adguardhome
      '';
      Restart = "always";
      RestartSec = "30";
    };
  };
}
