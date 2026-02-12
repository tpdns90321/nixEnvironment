{ config, pkgs, lib, inputs, user, isDesktop ? false, additionalPackages ? [], ... }:

let
  common-programs = import ../common/home-manager.nix { inherit config pkgs inputs; }; 
  linux-desktop = (import ../linux_desktop {inherit pkgs isDesktop;}); in
(lib.attrsets.recursiveUpdate {
  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.enableNixpkgsReleaseCheck = true;
  home.packages = (import ../common/packages_desktop.nix { inherit pkgs inputs lib isDesktop additionalPackages; }) ++ (with pkgs; [
    dbus
  ]);
  programs = common-programs // linux-desktop.programs;

  home.stateVersion = "25.05";
} (builtins.removeAttrs linux-desktop ["programs"]))
