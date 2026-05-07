{ config, pkgs, inputs, home-manager, lib, isDesktop, ... }:

let common-programs = import ../common/home-manager.nix { inherit config pkgs lib inputs isDesktop; };
  linux-desktop = import ../linux_desktop { inherit config pkgs lib inputs isDesktop; }; in
{
  home-manager = {
    useGlobalPkgs = true;
    users.kang = {
      home.enableNixpkgsReleaseCheck = true;
      home.file = (
        if isDesktop then
          {
            ".pi/agent/AGENTS.md" = {
              source = ../common/AGENTS.txt;
            };
          } else {});
      # home.packages = (import ../common/packages_desktop.nix { inherit pkgs inputs lib isDesktop; });
      programs = common-programs // linux-desktop.programs;
    } // (builtins.removeAttrs linux-desktop [ "programs" ]);
  };
}
