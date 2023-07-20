{ config, pkgs, inputs, user, isDesktop ? false, ... }:

let
  common-programs = import ../common/home-manager.nix { config = config; pkgs = pkgs; inputs = inputs; }; in
{
  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.enableNixpkgsReleaseCheck = true;
  home.packages = (pkgs.callPackage (import ./packages.nix inputs isDesktop) {});
  programs = common-programs // {};

  home.stateVersion = "23.05";

}
