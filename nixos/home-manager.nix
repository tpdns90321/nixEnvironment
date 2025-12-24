{ config, pkgs, inputs, home-manager, lib, isDesktop, ... }:

let common-programs = import ../common/home-manager.nix { inherit config pkgs lib inputs isDesktop; }; in
{
  home-manager = {
    useGlobalPkgs = true;
    users.kang = {
      home.enableNixpkgsReleaseCheck = true;
      # home.packages = (import ../common/packages_desktop.nix { inherit pkgs inputs lib isDesktop; });
      programs = common-programs // {
        waybar = {
          enable = isDesktop;
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

              pulseaudio = {
                on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
              };
            }
          ];
        };
        swaylock = {
          enable = true;
          settings = {
            color = "00000000";
          };
        };
        chromium = {
          enable = isDesktop;
          commandLineArgs = [
            "--enable-features=UseOzonePlatform"
            "--ozone-platform=wayland"
            "--gtk-version=4"
          ];
        };
        firefox = {
          enable = isDesktop;
        };
      };
      wayland.windowManager.sway = let modifier = "Mod1"; in {
        enable = isDesktop;
        config = {
          defaultWorkspace = "workspace number 1";
          modifier = modifier;
          terminal = "${pkgs.alacritty}/bin/alacritty";
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
          keybindings = lib.mkOptionDefault {
            "${modifier}+d" = "exec bemenu-run";
          };
          window.commands = [
            {
              command = "border pixel 3";
              criteria = {
                app_id = "zen";
              };
            }
            {
              command = "floating enable";
              criteria = {
                app_id = "pavucontrol";
              };
            }
          ];
        };
      };

      home.stateVersion = "25.05";
    };
  };
}
