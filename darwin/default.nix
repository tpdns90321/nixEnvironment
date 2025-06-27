{ config, pkgs, inputs, lib, user, additionalPackages ? [], additionalCasks ? [], ... }:


{
  imports = [
    ../common
    # alfred or spotlight support. import from https://github.com/landakram/nix-config/ , thanks @landakram
    ./link-apps
    ./home-manager.nix
  ];

  nix = {
    package = pkgs.lix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings.trusted-users = [ "@admin" "${user}" ];

    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };
  };

  environment.systemPackages = pkgs.callPackage (import ./packages.nix { inherit inputs additionalPackages; }) { };
  system.build.application = pkgs.lib.mkForce (pkgs.buildEnv {
    name = "applications";
    paths = config.environment.systemPackages ++ config.home-manager.users.${user}.home.packages;
    pathsToLink = "/Applications/";
  });

  services.link-apps = {
    enable = true;
    userName = "${user}";
    userHome = "/Users/${user}";
  };

  system = {
    primaryUser = user;
    stateVersion = 4;

    defaults = {
      dock = {
        autohide = true;
        show-recents = false;
        launchanim = true;
        orientation = "bottom";
        tilesize = 48;
      };
    };
  };

  launchd.daemons."sysctl-vram-limit" = {
    command = "/usr/sbin/sysctl iogpu.wired_limit_mb=19660";
    serviceConfig.RunAtLoad = true;
  };
}
