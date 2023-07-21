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
      ExecStart = "${pkgs.podman}/bin/podman run --rm --name adguardhome -p 6053:53/tcp -p 6053:53/udp -p 6080:80/tcp -p 6443:443/tcp -p 6443:443/udp -p 9000:3000/tcp -p 6853:853/tcp -p 6784:784/udp -p 6853:853/udp -p 14853:8853/udp -p 11443:5443/tcp --volume /home/${user}/.config/adguardhome/work:/opt/adguardhome/work --volume /home/${user}/.config/adguardhome/conf:/opt/adguardhome/conf docker.io/adguard/adguardhome:latest";
      ExecStop = "${pkgs.podman}/bin/podman stop adguardhome";
    };
  };
}
