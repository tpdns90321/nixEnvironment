{ config, pkgs, nixpkgs, lib, ... }:

{
  imports = [(import ../darwin { user = "unione"; additionalCasks = ["cyberduck"]; })];
}
