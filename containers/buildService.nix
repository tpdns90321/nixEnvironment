{ pkgs, user }:

{ name, options, description ? "", after ? [], }:
{
  Unit = {
    Description = description;
    After = [ "network.target" ] ++ after;
  };

  Install = {
    WantedBy = [ "default.target" ];
  };

  Service = {
    Type = "simple";
    ExecStartPre = "${pkgs.podman}/bin/podman rm -f ${name}";
    ExecStart = "${pkgs.podman}/bin/podman run --name ${name} ${options}";
    ExecStop = "${pkgs.podman}/bin/podman rm -f ${name}";
  };
}
