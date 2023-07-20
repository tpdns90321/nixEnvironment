{ pkgs, inputs, lib }:

(import ./packages.nix { pkgs = pkgs; inputs = inputs; lib = lib; }) ++ (with pkgs; [
  # GUI Application for work
  gimp
  postman
  vscodium
])

