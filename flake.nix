{
  description = "A nix environment for me";
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/23.05";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vim-astro = {
      url = "github:wuelnerdotexe/vim-astro";
      flake = false;
    };
    copilot-vim = {
      url = "github:github/copilot.vim";
      flake = false;
    };
    llama_cpp = {
      url = "github:ggerganov/llama.cpp";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    guidance = {
      url = "github:microsoft/guidance";
      flake = false;
    };
    gptcache = {
      url = "github:zilliztech/GPTCache";
      flake = false;
    };
    selective_context = {
      url = "github:liyucheng09/Selective_Context";
      flake = false;
    };
    openai = {
      url = "github:openai/openai-python";
      flake = false;
    };
  };

  outputs = { self, flake-utils, darwin, home-manager, nixpkgs, ... }@inputs: {
    darwinConfigurations = {
      "uniones-MacBook-Pro" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          ./hosts/uniones-MacBook-Pro.nix
        ];
        inputs = { inherit darwin home-manager; };
        specialArgs = { inherit inputs; };
      };
      "kang-mac-mini" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          ./hosts/kang-mac-mini.nix
        ];
        inputs = { inherit darwin home-manager; };
        specialArgs = { inherit inputs; };
      };
    };

    homeConfigurations.kang = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {};

      modules = [ ./standalone ];
      extraSpecialArgs = { inputs = inputs; };
    };
  };
}
