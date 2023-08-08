{ config, pkgs, inputs, user, isDesktop ? false, additionalPackages ? [], ... }:

let
  common-programs = import ../common/home-manager.nix { config = config; pkgs = pkgs; inputs = inputs; }; in
{
  home.username = user;
  home.homeDirectory = "/home/${user}";
  home.enableNixpkgsReleaseCheck = true;
  home.packages = (pkgs.callPackage (import ./packages.nix inputs isDesktop additionalPackages) {});
  programs = common-programs // {};

  home.stateVersion = "23.05";

  home.file."/home/${user}/.config/containers" = {
    source = ../containers/containers;
  };

  home.file."/home/${user}/.local/share/containers/storage/networks/podman.json" = {
    source = ../containers/podman.json;
  };

  services.lorri.enable = true;
}
