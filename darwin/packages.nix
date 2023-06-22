{ pkgs }:

with pkgs;
let common_pkgs = import ../common/packages.nix { pkgs = pkgs; }; in common_pkgs ++ [
  # react-native ios development
  ruby
  watchman
  cocoapods

  # podman machin in darwin
  qemu
]
