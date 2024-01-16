{ pkgs, user }:

{ description, src, options ? "", filename ? "docker-compose.yml", after ? [], docker_host ? "" }:
let composeFile = "${src}/${filename}"; in
{
  Unit = {
    Description = description;
    After = [ "network.target" "podman.service" "docker.service" ] ++ after;
  };

  Install = {
    WantedBy = [ "default.target" ];
  };

  Service = let docker_host_flags = if docker_host != "" then "-H ${docker_host} " else ""; in
  {
    Type = "oneshot";
    ExecStart = "${pkgs.docker-compose}/bin/docker-compose ${docker_host_flags}-f ${composeFile} ${options} up -d";
    ExecStop = "${pkgs.docker-compose}/bin/docker-compose ${docker_host_flags}-f ${composeFile} ${options} stop";
    RemainAfterExit = "yes";
  };
}
