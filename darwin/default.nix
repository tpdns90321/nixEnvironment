{ config, pkgs, inputs, lib, user, additionalCasks ? [], ... }:


{
  imports = [
    ../common
    # alfred or spotlight support. import from https://github.com/landakram/nix-config/ , thanks @landakram
    ./link-apps
    (import ./home-manager.nix user additionalCasks)
  ];

  services.nix-daemon.enable = true;

  nix = {
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings.trusted-users = [ "@admin" "${user}" ];

    gc = {
      user = "root";
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };
  };

  environment.systemPackages = import ../common/packages_desktop.nix { pkgs = pkgs; inputs = inputs; lib = lib; };
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
