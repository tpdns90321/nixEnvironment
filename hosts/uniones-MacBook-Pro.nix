{ config, pkgs, nixpkgs, lib, ... }:

let darwin = import ../darwin  "unione" ["cyberduck"]; in {
  imports = [darwin];
}
