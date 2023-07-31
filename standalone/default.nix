{ config, pkgs, nixpkgs, lib, inputs, ... }:


{
  nixpkgs.overlays = [
    (import ../overlays/caddy.nix { inherit lib; plugins = [ "github.com/caddy-dns/duckdns" ]; })
  ];

  imports = [
    ../common
    ./home-manager.nix
  ];
}
