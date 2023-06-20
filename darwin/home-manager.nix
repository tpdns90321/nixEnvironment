{ config, pkgs, user, additionalCasks, ... }:

let
  common-programs = import ../common/home-manager.nix { config = config; pkgs = pkgs; }; in
{
  imports = [
    <home-manager/nix-darwin>
  ];

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew.enable = true;
  homebrew.onActivation = {
    autoUpdate = true;
    cleanup = "zap";
    upgrade = true;
  };
  homebrew.brewPrefix = "/opt/homebrew/bin";
  homebrew.taps = [
    {
      name = "mdogan/zulu";
    }
  ];
  homebrew.casks = [
    "alfred"
    "adguard"
    "google-chrome"
    "notion"
    "iterm2"

    # react-native android development in macos
    "android-studio"
    "zulu-jdk11"
  ] ++ additionalCasks;
  homebrew.masApps = {
    "Xcode" = 497799835;
    "PiPifier" = 1160374471;
    "Vimari" = 1480933944;
    # "TestFlight" = 899247664; # currently TestFlight is well done in first run, when redo this package is trying redownload and fail.
    "Polaris Office" = 1098211970;
    "Keka" = 470158793;
    "BetterSnapTool" = 417375580;
  };

  home-manager = {
    useGlobalPkgs = true;
    users.${user} = {
      home.enableNixpkgsReleaseCheck = true;
      home.packages = pkgs.callPackage ./packages.nix { };
      programs = common-programs // {};

      home.stateVersion = "23.05";

      manual.manpages.enable = false;
    };
  };
}
