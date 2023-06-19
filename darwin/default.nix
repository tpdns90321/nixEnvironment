{ config, pkgs, nixpkgs, ... }:

let user = "kang"; in
{
  imports = [
    ./home-manager.nix
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

  environment.systemPackages = with pkgs; let sharedPkgs = import ../common/packages.nix { pkgs = pkgs; }; in sharedPkgs;
}
