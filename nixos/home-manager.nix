{ config, pkgs, ... }:
let
  common-programs = import ../common/home-manager.nix { config = config; pkgs = pkgs; }; in
{
  imports = [
    <home-manager/nixos>
  ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kang = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    users.kang = {
      home.enableNixpkgsReleaseCheck = true;
      home.packages = pkgs.callPackage ./packages.nix { };
      programs = common-programs;

      home.stateVersion = "23.05";
    };
  };
}
