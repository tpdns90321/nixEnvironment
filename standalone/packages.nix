inputs: { pkgs, lib, ... }:

with pkgs;
let common_pkgs = import ../common/packages.nix { pkgs = pkgs; inputs = inputs; lib = lib; }; in common_pkgs ++ [
]
