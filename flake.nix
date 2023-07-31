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
    llama_cpp = {
      url = "github:ggerganov/llama.cpp";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    vim-astro = {
      url = "github:wuelnerdotexe/vim-astro";
      flake = false;
    };
    copilot-vim = {
      url = "github:github/copilot.vim";
      flake = false;
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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs";
    };
  };

  outputs = { self, flake-utils, darwin, home-manager, nixpkgs, sops-nix, ... }@inputs: {
    darwinConfigurations = {
      "uniones-MacBook-Pro" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          ./darwin
        ];
        inputs = { inherit darwin; };
        specialArgs = {
          inherit inputs;
          user = "unione";
          additionalCasks = ["cyberduck"];
          additionalAppStore = {};
          sops-nix = sops-nix.homeManagerModules.sops;
        };
      };
      "kang-mac-mini" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          ./darwin
        ];
        inputs = { inherit darwin; };
        specialArgs = {
          inherit inputs;
          user = "kang";
          additionalCasks = ["steam" "parallels"];
          additionalAppStore = {
            "KakaoTalk" = 869223134;
          };
          sops-nix = sops-nix.homeManagerModules.sops;
        };
      };
    };

    # use in wsl
    homeConfigurations.kang = let pkgs = import nixpkgs { system = "x86_64-linux"; }; in home-manager.lib.homeManagerConfiguration {
      pkgs = pkgs;

      modules = [ ./standalone ];
      extraSpecialArgs = { inputs = inputs; user = "kang"; isDesktop = true; additionalPackages = []; };
    };

    # use in raspberry pi 4
    homeConfigurations.pi = let pkgs = import nixpkgs { system = "aarch64-linux"; }; in home-manager.lib.homeManagerConfiguration {
      pkgs = pkgs;

      modules = [
        sops-nix.homeManagerModules.sops
        ./standalone
        ./hosts/rpi4
      ];
      extraSpecialArgs = { inputs = inputs; user = "pi"; isDesktop = true; additionalPackages = with pkgs; [ caddy ];};
    };
  };
}
