inputs: { config, pkgs, nixpkgs, lib, ... }:


{
  nix = {
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  nixpkgs.config.allowUnfree = true;

  users.users.kang = {
    shell = "zsh";
  };

  imports = [
    ../common
    (import ./home-manager.nix inputs) 
  ];
}
