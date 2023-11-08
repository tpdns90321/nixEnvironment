inputs: isDesktop: additionalPackages: { pkgs, lib, ... }:

with pkgs;
let
  packages = if isDesktop
    then ../common/packages_desktop.nix
    else ../common/packages.nix;
  common_pkgs = import packages { pkgs = pkgs; inputs = inputs; lib = lib; };
  in common_pkgs ++ [
    fuse-overlayfs
  ] ++ additionalPackages
