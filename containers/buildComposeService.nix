{ pkgs, user }:

{ description, src, options ? "", filename ? "docker-compose.yml", after ? [], }:
let composeFile = "${src}/${filename}"; in
{
  Unit = {
    Description = description;
    After = [ "network.target" "podman.service" "docker.service" ] ++ after;
  };

  Install = {
    WantedBy = [ "default.target" ];
  };

  Service = {
    Type = "oneshot";
    ExecStart = "${pkgs.docker-compose}/bin/docker-compose -f ${composeFile} ${options} up -d";
    ExecStop = "${pkgs.docker-compose}/bin/docker-compose -f ${composeFile} ${options} down";
    RemainAfterExit = "yes";
  };
}
