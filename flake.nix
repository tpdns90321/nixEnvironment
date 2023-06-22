{
  description = "A nix environment for me";
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/23.05";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vim-astro = {
      url = "github:wuelnerdotexe/vim-astro";
      flake = false;
    };
  };

  outputs = { self, flake-utils, darwin, home-manager, nixpkgs, ... }@inputs: {
    darwinConfigurations = {
      "uniones-MacBook-Pro" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/uniones-MacBook-Pro.nix
        ];
        inputs = { inherit darwin home-manager nixpkgs; };
      };
      "gangse-un-ui-Macmini" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          ./hosts/gangse-un-ui-Macmini.nix
        ];
        inputs = { inherit darwin home-manager nixpkgs; };
      };
    };
  };
}
