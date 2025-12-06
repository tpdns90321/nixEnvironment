{
  description = "A nix environment for me";
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/release-25.05";
    };
    nixpkgs_unstable = {
      url = "github:nixos/nixpkgs/master";
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
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, darwin, home-manager, nixpkgs, nixos, nixos-hardware, sops-nix, nixos-generators, ... }@inputs: 
  {
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
          additionalBrews = [ "minikube" "vfkit" ];
          additionalCasks = [ "android-studio" "claude" "discord" "parallels@19" "raspberry-pi-imager" "steam" "iterm2" "moonlight" "wireshark-app" "virtualbox" "zen" "zoom" "obs" "zap" ];
          additionalAppStore = {
            "KakaoTalk" = 869223134;
            "Blackmagic Disk Speed Test" = 425264550;
          };
          additionalPackages = [
            "mitmproxy"
          ];
          sops-nix = sops-nix.homeManagerModules.sops;
        };
      };
    };

    # use in wsl
    homeConfigurations.kang = let pkgs = nixpkgs.legacyPackages.x86_64-linux; in home-manager.lib.homeManagerConfiguration {
      modules = [
        ./standalone
        ./hosts/wsl
      ];
      extraSpecialArgs = { inputs = inputs; user = "kang"; isDesktop = true; additionalPackages = []; };
    };

    # use in raspberry pi 4
    homeConfigurations.pi = let pkgs = nixpkgs.legacyPackages.aarch64-linux; in home-manager.lib.homeManagerConfiguration {

      modules = [
        sops-nix.homeManagerModules.sops
        ./standalone
        ./hosts/rpi4
      ];
      extraSpecialArgs = {
        inputs = inputs;
        user = "pi";
        isDesktop = false;
        additionalPackages = [
          "wakeonlan"
          "caddy"
        ];
      };
    };

    nixosConfigurations.kang-stay-nixos =
      let system = "x86_64-linux";
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
      in nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inputs = inputs; additionalPackages = [ "nfs-utils" ]; isDesktop = false; };
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

    nixosConfigurations.kang-odyssey = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inputs = inputs; additionalPackages = []; isDesktop = false; };
      modules = [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        ./nixos
        ./hosts/kang_odyssey
      ];
    };

    nixosConfigurations.kang-ryzen = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inputs = inputs; additionalPackages = ["virt-manager"]; isDesktop = true; };
      modules = [
        home-manager.nixosModules.home-manager
        ./nixos
        ./hosts/kang_ryzen
      ];
    };

    nixosConfigurations.kang-virtualbox = nixos.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inputs = inputs; additionalPackages = [ "wlr-randr" ]; isDesktop = true; };
      modules = [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        ./nixos
        ./hosts/kang_virtualbox
        ./hosts/kang_virtualbox/hardware-configuration.nix
      ];
    };

    nixosConfigurations.kang-rpi4 = nixos.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inputs = inputs; additionalPackages = [ "nfs-utils" ]; isDesktop = false; };
      modules = [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        ./nixos
        nixos-hardware.nixosModules.raspberry-pi-4
        ./hosts/kang_rpi4
      ];
    };

  packages =
    let
      allSystems = [ "x86_64-linux" "aarch64-linux" ];
      in
      nixpkgs.lib.genAttrs allSystems (system: {
        tui-only = nixos-generators.nixosGenerate {
          inherit system;
          specialArgs = { inputs = inputs; additionalPackages = [ ]; isDesktop = false;  };
          modules = [
            home-manager.nixosModules.home-manager
            ./nixos
            ./hosts/kang_virtualbox
            {
              nix.registry.nixpkgs.flake = nixpkgs;
              users.users.kang.password = "";
              virtualisation.diskSize = 1024 * 20;
            }
          ];
          format = "qcow";
        };
      });
  };
}
