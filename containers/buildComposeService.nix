{ pkgs, user }:

{ name, description, src, options ? "", after ? [], }:
let composeFile = "${src}/docker-compose.yml"; in
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
    ExecStartPre = "${pkgs.podman-compose}/bin/podman-compose -f ${composeFile} pull";
    ExecStart = "${pkgs.podman-compose}/bin/podman-compose -f ${composeFile} up ${options}";
    ExecStop = "${pkgs.podman-compose}/bin/podman-compose -f ${composeFile} down";
  };
}
