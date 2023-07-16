inputs: { config, pkgs, ... }:

let
  common-programs = import ../common/home-manager.nix { config = config; pkgs = pkgs; inputs = inputs; }; in
{
  home.username = "kang";
  home.homeDirectory = "/home/kang";
  home.enableNixpkgsReleaseCheck = true;
  home.packages = (pkgs.callPackage (import ./packages.nix inputs) {});
  programs = common-programs // {};

  home.stateVersion = "23.05";

}
