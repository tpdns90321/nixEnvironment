{ config, pkgs, inputs, home-manager, lib, ... }:

let common-programs = import ../common/home-manager.nix { config = config; pkgs = pkgs; inputs = inputs; }; in
{
  home-manager = {
    useGlobalPkgs = true;
    users.kang = {
      home.enableNixpkgsReleaseCheck = true;
      home.packages = (import ../common/packages_desktop.nix { pkgs = pkgs; inputs = inputs; lib = lib; });
      programs = common-programs // {};
      wayland.windowManager.sway = {
        enable = true;
        config = {
          modifier = "Mod4";
          terminal = "alacritty";
          startup = [
            { command = "mako"; }
            { command = "kime -D"; }
          ];
          input = {
            "*" = {
              xkb_options = "ctrl:swapcaps";
            };
          };
          bars = [
            {
              statusCommand = "${pkgs.i3status}/bin/i3status";
              position = "top";
              fonts = {
                names = [ "NanumGhothic" ];
                style = "Bold";
                size = 11.0;
              };
            }
          ];
          fonts = {
            names = [ "NanumGhothic" ];
            style = "Bold Semi-Condensed";
            size = 9.0;
          };
        };
      };

      home.stateVersion = "23.05";
    };
  };
}
