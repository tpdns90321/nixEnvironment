{ config, pkgs, nixpkgs, lib, inputs, ... }:


{
  imports = [
    ../common
    ./home-manager.nix
  ];
}
