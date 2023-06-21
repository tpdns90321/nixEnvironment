{ config, pkgs, nixpkgs, lib, ... }:

import ../darwin { config = config; pkgs = pkgs ; nixpkgs = nixpkgs; user = "unione"; additionalCasks = ["cyberduck" "visual-studio-code"]; }
