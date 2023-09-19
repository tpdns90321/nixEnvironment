inputs: { pkgs, lib, ... }:

with pkgs;
let common_pkgs = import ../common/packages_desktop.nix { pkgs = pkgs; inputs = inputs; lib = lib; }; in common_pkgs ++ [
  # react-native ios development
  ruby
  watchman
  rubyPackages.cocoapods

  # podman machin in darwin
  qemu
]
