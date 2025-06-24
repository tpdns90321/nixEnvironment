{ inputs, additionalPackages ? [] }: { pkgs, lib, ... }:

with pkgs;
let common_pkgs = import ../common/packages_desktop.nix { inherit pkgs inputs lib additionalPackages; }; in common_pkgs ++ [
  # react-native ios development
  ruby
  watchman

  # podman machin in darwin
  qemu

  # utm virtual machine
  utm
]
