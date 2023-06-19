{ pkgs }:

with pkgs;
let common_pkgs = import ../common/packages.nix { pkgs = pkgs; }; in common_pkgs
