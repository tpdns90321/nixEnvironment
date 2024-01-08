{
  description = "A nix environment for me";
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/23.11";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llama_cpp = {
      url = "github:ggerganov/llama.cpp";
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
          ./hosts/unione_macbook
          ./darwin
        ];
        inputs = { inherit darwin; };
        specialArgs = {
          inherit inputs;
          user = "unione";
          additionalCasks = ["cyberduck"];
          additionalAppStore = {
            "Polaris Office" = 1098211970;
          };
          sops-nix = sops-nix.homeManagerModules.sops;
        };
      };
      "kang-macbook-air" = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          home-manager.darwinModules.home-manager
          ./hosts/kang_macbook_air
          ./darwin
        ];
        inputs = { inherit darwin; };
        specialArgs = {
          inherit inputs;
          user = "kang";
          additionalCasks = [ "discord" "parallels" "raspberry-pi-imager" "steam" ];
          additionalAppStore = {
            "KakaoTalk" = 869223134;
            "Blackmagic Disk Speed Test" = 425264550;
          };
          sops-nix = sops-nix.homeManagerModules.sops;
        };
      };
    };

    # use in wsl
    homeConfigurations.kang = let pkgs = import nixpkgs { system = "x86_64-linux"; }; in home-manager.lib.homeManagerConfiguration {
      pkgs = pkgs;

      modules = [
        ./standalone
        ./hosts/wsl
      ];
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
      extraSpecialArgs = { inputs = inputs; user = "pi"; isDesktop = false; additionalPackages = with pkgs; [ caddy xcaddy wakeonlan ];};
    };

    nixosConfigurations.kang-stay-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inputs = inputs; };
      modules = [
        home-manager.nixosModules.home-manager
        ./nixos
        ./hosts/stay_nixos
      ];
    };

    nixosConfigurations.kang-home-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inputs = inputs; };
      modules = [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        ./nixos
        ./hosts/home_nixos
      ];
    };
  };
}
