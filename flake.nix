{
  description = "A nix environment for me";
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/release-25.11";
    };
    nixpkgs_unstable = {
      url = "github:nixos/nixpkgs/master";
    };
    nixos = {
      url = "github:nixos/nixpkgs/nixos-25.11";
    };
    nixos-hardware = {
      url = "github:nixos/nixos-hardware/master";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
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

  outputs = { self, darwin, home-manager, nixpkgs, nixos, nixos-hardware, sops-nix, ... }@inputs: 
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
          additionalCasks = [ "android-studio" "claude" "discord" "parallels@19" "raspberry-pi-imager" "steam" "iterm2" "moonlight" "wireshark-app" "virtualbox" "zoom" "obs" "zap" ];
          additionalAppStore = {
            "KakaoTalk" = 869223134;
            "Blackmagic Disk Speed Test" = 425264550;
          };
          additionalPackages = [
            "podman"
            "podman-compose"
            "mitmproxy"
            "realvnc-vnc-viewer"
          ];
          sops-nix = sops-nix.homeManagerModules.sops;
        };
      };
    };

    # use in wsl
    homeConfigurations = builtins.listToAttrs (map (architecture:
      let pkgs = nixpkgs.legacyPackages.${architecture}; in {
        name = "kang-${architecture}";
        value = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./standalone
          ];
          extraSpecialArgs = { inputs = inputs; user = "kang"; isDesktop = true; additionalPackages = []; };
        };
      }) [ "x86_64-linux" "aarch64-linux" ]);

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
      specialArgs = { inputs = inputs; additionalPackages = [ "wakeonlan" ]; isDesktop = false; };
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
        tui-only = (nixos.lib.nixosSystem {
          inherit system;
          specialArgs = { inputs = inputs; additionalPackages = [ ]; isDesktop = false;  };
          modules = [
            home-manager.nixosModules.home-manager
            ./nixos
            {
              users.users.kang.password = "";
              virtualisation.diskSizeAutoSupported = true;
              services.openssh.enable = true;
            }
          ];
        }).config.system.build.images;

        kang-homemanager = (home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./standalone
          ];
          extraSpecialArgs = { inputs = inputs; user = "kang"; isDesktop = true; additionalPackages = ["iconv"]; };
        }).activationPackage;
      });
  };
}
