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
      '';
      ExecStart = ''
        ${pkgs.podman}/bin/podman run \
          --name adguardhome \
          --port 5053:53/tcp --port 5053:53/udp \
          --port 5080:80/tcp --port 5443:443/tcp --port 5443:443/udp --port 8000:3000/tcp \
          --port 5853:853/tcp \
          --port 5784:784/udp --port 5853:853/udp --port 13853:8853/udp \
          --port 5443:10443/tcp \
          --volume /home/${user}/.config/containers/adguardhome/work:/opt/adguardhome/work \
          --volume /home/${user}/.config/containers/adguardhome/conf:/opt/adguardhome/conf \
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
