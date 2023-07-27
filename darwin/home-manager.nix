{ config, pkgs, inputs, home-manager, lib, sops-nix, user, additionalCasks, additionalAppStore ? {}, ... }:

let
  common-programs = import ../common/home-manager.nix { config = config; pkgs = pkgs; inputs = inputs; }; in
{
  imports = [
    # import from https://github.com/dustinlyons/nixos-config/ . thanks @dustinlyons
    ./dock
  ];

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  local.dock.enable = true;
  local.dock.entries = [
    { path = "/System/Applications/Launchpad.app/"; }
    { path = "/System/Cryptexes/App/System/Applications/Safari.app/"; }
    { path = "/Applications/iTerm.app/"; }
    { path = "/System/Applications/Mail.app/"; }
    { path = "/System/Applications/Calendar.app/"; }
    { path = "/System/Applications/Notes.app/"; }
    { path = "/System/Applications/Freeform.app/"; }
    { path = "/Applications/Keka.app/"; }
    {
      path = "${config.users.users.${user}.home}/Downloads";
      section = "others";
      options = "--sort dateadded --view fan --display stack";
    }
  ];

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
    "firefox"
    "notion"
    "iterm2"
    "tunnelblick"
    "wireshark"

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
  } // additionalAppStore;


  home-manager = {
    sharedModules = [ sops-nix ];
    useGlobalPkgs = true;
    users.${user} = {
      sops = {
        age.keyFile = "/Users/${user}/Library/Application Support/sops/age/keys.txt";
        secrets.openvpn = {
          sopsFile = ../client.ovpn;
          format = "binary";
          path = "${config.users.users.${user}.home}/Library/Application Support/TunnelBlick/Configurations/home.ovpn";
        };
      };
      home.enableNixpkgsReleaseCheck = true;
      home.packages = pkgs.callPackage (import ./packages.nix inputs) { };
      programs = common-programs // {};

      home.stateVersion = "23.05";

      manual.manpages.enable = false;
    };
  };
}
