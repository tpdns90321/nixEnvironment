{ config, pkgs, nixpkgs, lib, ... }:

{
  imports = [
    (import ../darwin { user = "kang"; additionalCasks = ["steam" "parallels"]; })
  ];
}
