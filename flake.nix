{
  description = "A nix environment for me";
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/release-25.05";
    };
    nixos = {
      url = "github:nixos/nixpkgs/nixos-25.05";
    };
    nixos-hardware = {
      url = "github:nixos/nixos-hardware/master";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    copilot-vim = {
      url = "github:github/copilot.vim";
      flake = false;
    };
    vim-rzip = {
      url = "github:lbrayner/vim-rzip";
      flake = false;
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, flake-utils, darwin, home-manager, nixpkgs, nixos, nixos-hardware, sops-nix, ... }@inputs: {
    darwinConfigurations = {
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
          additionalCasks = [ "android-studio" "claude" "discord" "parallels@19" "raspberry-pi-imager" "steam" "ollama" "lm-studio" "obs" "iterm2" "moonlight" ];
          additionalAppStore = {
            "KakaoTalk" = 869223134;
            "Blackmagic Disk Speed Test" = 425264550;
          };
          additionalPackages = let pkgs = (import nixpkgs { system = "aarch64-darwin"; }); in [
            pkgs.mitmproxy
          ];
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
      extraSpecialArgs = {
        inputs = inputs;
        user = "pi";
        isDesktop = false;
        additionalPackages = with pkgs; [
          wakeonlan
          caddy
        ];
      };
    };

    nixosConfigurations.kang-stay-nixos =
      let system = "x86_64-linux";
          pkgs = import nixpkgs { system = system; };
      in nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inputs = inputs; additionalPackages = [ ]; isDesktop = true; };
        modules = [
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          ./nixos
          ./hosts/stay_nixos
        ];
      };

    nixosConfigurations.kang-stay-gmk =
      let system = "x86_64-linux";
          pkgs = import nixpkgs { system = system; };
      in nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inputs = inputs; additionalPackages = [ ]; isDesktop = false; };
        modules = [
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          ./nixos
          ./hosts/stay_GMK
        ];
      };

    nixosConfigurations.kang-home-nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inputs = inputs; additionalPackages = []; isDesktop = true; };
      modules = [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        ./nixos
        ./hosts/home_nixos
      ];
    };

    nixosConfigurations.kang-soyo = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inputs = inputs; additionalPackages = []; isDesktop = true; };
      modules = [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        ./nixos
        ./hosts/kang_soyo
      ];
    };

    nixosConfigurations.kang-virtualbox = nixos.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inputs = inputs; additionalPackages = with (import nixos { system = "x86_64-linux"; }); [ wlr-randr ]; isDesktop = true; };
      modules = [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        ./nixos
        ./hosts/kang_virtualbox
      ];
    };

    nixosConfigurations.kang-rpi4 = nixos.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inputs = inputs; additionalPackages = []; isDesktop = false; };
      modules = [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        ./nixos
        nixos-hardware.nixosModules.raspberry-pi-4
        ./hosts/kang_rpi4
      ];
    };
  };
}
