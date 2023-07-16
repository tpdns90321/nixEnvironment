inputs: { config, pkgs, nixpkgs, lib, ... }:


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
