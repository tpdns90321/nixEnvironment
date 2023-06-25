user: additionalCasks: { config, pkgs, nixpkgs, ... }:


{
  imports = [
    ../common
    # alfred or spotlight support. import from https://github.com/landakram/nix-config/ , thanks @landakram
    ./link-apps
    (import ./home-manager.nix user additionalCasks)
  ];

  services.nix-daemon.enable = true;

  environment.systemPackages = import ../common/packages.nix { pkgs = pkgs; };
  system.build.application = pkgs.lib.mkForce (pkgs.buildEnv {
    name = "applications";
    paths = config.environment.systemPackages ++ config.home-manager.users.${user}.home.packages;
    pathsToLink = "/Applications/";
  });

  nix.settings.trusted-users = [ "@admin" "${user}" ];
  nix.gc = {
    user = "root";
    automatic = true;
    interval = { Weekday = 0; Hour = 2; Minute = 0; };
    options = "--delete-older-than 30d";
  };

  services.link-apps = {
    enable = true;
    userName = "${user}";
    userHome = "/Users/${user}";
  };

  system = {
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
}
