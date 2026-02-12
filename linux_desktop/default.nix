{ pkgs, isDesktop, ... }: {
  programs = {
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
      terminal = "${pkgs.foot}/bin/foot";
      startup = [
        { command = "${pkgs.mako}/bin/mako"; }
        { command = "${pkgs.kime}/bin/kime -D"; }
        { command = "${pkgs.waybar}/bin/waybar"; }
        { command = "${pkgs.zsh}/bin/zsh -c '${pkgs.tmux}/bin/tmux -2 -u new-session -d -s default'"; }
        { command = "${pkgs.screen}/bin/screen -U -dmS default"; }
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
      keybindings = pkgs.lib.mkOptionDefault {
        "${modifier}+d" = "exec ${pkgs.bemenu}/bin/bemenu-run";
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
  home.file."swayvnc.sh" = {
    source = ./swayvnc.sh;
  };
}
