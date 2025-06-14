{ config, pkgs, inputs, home-manager, lib, sops-nix, user, additionalCasks, additionalAppStore ? {}, additionalPackages ? [], ... }:

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
    { path = "/Applications/Arc.app/"; }
    { path = "${pkgs.alacritty}/Applications/Alacritty.app"; }
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
      name = "bell-sw/liberica";
    }
  ];
  homebrew.casks = [
    "alfred"
    "adguard"
    "arc"
    "coconutbattery"
    "firefox"
    "google-chrome"
    "karabiner-elements"
    "obsidian"
    "wireshark"
    "zerotier-one"

    # LLM
    "lm-studio"

    # react-native android development in macos
    "android-studio"
    "liberica-jdk17"
  ] ++ additionalCasks;
  homebrew.masApps = {
    "Xcode" = 497799835;
    "PiPifier" = 1160374471;
    "Vimari" = 1480933944;
    # "TestFlight" = 899247664; # currently TestFlight is well done in first run, when redo this package is trying redownload and fail.
    "Keka" = 470158793;
    "BetterSnapTool" = 417375580;
    "Bitwarden" = 1352778147;
    "Amphetamine" = 937984704;
  } // additionalAppStore;


  home-manager = {
    sharedModules = [ sops-nix ];
    useGlobalPkgs = true;
    users.${user} = {
      home.enableNixpkgsReleaseCheck = true;
      home.packages = pkgs.callPackage (import ./packages.nix { inherit inputs additionalPackages; }) { };
      programs = common-programs // {};

      home.stateVersion = "23.05";

      manual.manpages.enable = false;
    };
  };
}
