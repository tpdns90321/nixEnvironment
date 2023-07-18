{ config, pkgs, nixpkgs, lib, inputs, ... }:


{
  nix = {
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  imports = [
    ../common
    (import ./home-manager.nix inputs) 
  ];
}
