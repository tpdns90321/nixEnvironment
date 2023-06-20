{ config, pkgs, nixpkgs, lib, ... }:

import ../darwin { config = config; pkgs = pkgs ; nixpkgs = nixpkgs; user = "kang"; additionalCasks = ["steam" "parallels"]; }
