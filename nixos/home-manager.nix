{ config, pkgs, inputs, home-manager, lib, ... }:

let common-programs = import ../common/home-manager.nix { config = config; pkgs = pkgs; inputs = inputs; }; in
{
  home-manager = {
    useGlobalPkgs = true;
    users.kang = {
      home.enableNixpkgsReleaseCheck = true;
      home.packages = (import ../common/packages_desktop.nix { pkgs = pkgs; inputs = inputs; lib = lib; });
      programs = common-programs // {};

      home.stateVersion = "23.05";
    };
  };
}
