{ config, pkgs, nixpkgs, lib, ... }:

let darwin = import ../darwin "kang" ["steam" "parallels"]; in {
  imports = [darwin];
}
