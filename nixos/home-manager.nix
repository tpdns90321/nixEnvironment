{ config, pkgs, inputs, home-manager, lib, ... }:

let common-programs = import ../common/home-manager.nix { config = config; pkgs = pkgs; inputs = inputs; }; in
{
  home-manager = {
    useGlobalPkgs = true;
    users.kang = {
      home.enableNixpkgsReleaseCheck = true;
      home.packages = (import ../common/packages_desktop.nix { pkgs = pkgs; inputs = inputs; lib = lib; });
      programs = common-programs // { waybar = {
          enable = true;
          settings = [
            {
              layer = "bottom";
              height = 30;
              modules-left = [
                "sway/workspaces"
                "sway/mode"
              ];
              modules-center = [
                "sway/window"
              ];
              modules-right = [
                "cpu"
                "memory"
                "clock"
                "pulseaudio"
                "tray"
              ];

              cpu = {
                format = "{usage}% CPU";
                interval = 5;
              };

              memory = {
                format = "{}% RAM";
                interval = 5;
              };

              tray = {
                icon-size = 20;
                spacing = 10;
              };
            }
          ];
        };
      };
      wayland.windowManager.sway = {
        enable = true;
        config = {
          modifier = "Mod4";
          terminal = "alacritty";
          startup = [
            { command = "mako"; }
            { command = "kime -D"; }
            { command = "waybar"; }
          ];
          input = {
            "*" = {
              xkb_options = "ctrl:swapcaps";
            };
            "2131:256:Topre_Corporation_HHKB_Professional" = {
              xkb_options = "terminate:ctrl_alt_bksp";
            };
            "1155:20786:CATEX_TECH._GK868B" = {
              xkb_options = "terminate:ctrl_alt_bksp";
            };
          };
          bars = [
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
