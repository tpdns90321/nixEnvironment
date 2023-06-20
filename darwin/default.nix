{ config, pkgs, nixpkgs, user, additionalCasks, ... }:


let homeManagerConfig = (import ./home-manager.nix {config = config; pkgs = pkgs; nixpkgs = nixpkgs; user = user; additionalCasks = additionalCasks; }); in
with homeManagerConfig;
{
  imports = [
    ../common
    homeManagerConfig
  ];

  services.nix-daemon.enable = true;

  nix = {
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';

    settings.trusted-users = [ "@admin" "${user}" ];

    gc = {
      user = "root";
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };
  };

  environment.systemPackages = import ../common/packages.nix { pkgs = pkgs; };
}
