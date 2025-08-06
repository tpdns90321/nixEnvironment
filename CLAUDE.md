# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

### Nix Flake Operations
- `nix flake update` - Update all flake inputs to latest versions
- `nix flake update <input>` - Update specific input (e.g., nixpkgs)
- `nix flake check` - Verify flake evaluation and build checks
- `nix flake show` - Display flake outputs and available packages

### System Management

#### macOS (nix-darwin)
- `./install_mac.sh` - Initial setup and installation of Nix and darwin-rebuild
- `./setup_mac.sh` - Build and switch to new configuration (uses hostname detection)
- `nix --extra-experimental-features 'nix-command flakes' build .#darwinConfigurations.<hostname>.system` - Build specific system configuration
- `./result/sw/bin/darwin-rebuild switch --flake .` - Apply configuration changes

#### NixOS Systems
- `nixos-rebuild switch --flake .#<hostname>` - Build and switch to new configuration
- `nixos-rebuild test --flake .#<hostname>` - Test configuration without making it default

#### Home Manager (Standalone)
- `home-manager switch --flake .#<user>` - Apply home-manager configuration
- Available configurations: `kang` (WSL), `pi` (Raspberry Pi 4)

### Container and Kubernetes Management
- `kubectl` - Kubernetes cluster management (included in base packages)
- `helmfile` - Located in k3sCluster/ for Helm chart deployments
- Configuration files in `k3sCluster/charts/` for various services

## High-Level Architecture

### Flake Structure
This is a comprehensive Nix flake-based environment configuration supporting multiple platforms and deployment scenarios:

**Core Components:**
- `flake.nix` - Main flake definition with inputs and system configurations
- `common/` - Shared packages and configurations across all systems
- `hosts/` - Host-specific configurations for different machines
- `darwin/` - macOS-specific nix-darwin configurations  
- `nixos/` - NixOS system configurations
- `standalone/` - Home Manager configurations for non-NixOS systems

### System Configurations

**Darwin (macOS) Systems:**
- `kang-macbook-air` - Primary macOS configuration with development tools, GUI applications, and productivity software

**NixOS Systems:**
- `kang-stay-nixos` - Desktop NixOS system
- `kang-stay-gmk` - Server/headless NixOS system  
- `kang-home-nixos` - Home NixOS desktop
- `kang-soyo` - Additional NixOS desktop
- `kang-virtualbox` - VirtualBox NixOS instance
- `kang-rpi4` - Raspberry Pi 4 ARM64 NixOS

**Home Manager Standalone:**
- `kang` - WSL configuration
- `pi` - Raspberry Pi user configuration

### Package Management Strategy
- **Base packages** in `common/packages.nix` - Essential CLI tools, development utilities
- **Desktop packages** in `common/packages_desktop.nix` - GUI applications and desktop tools
- **Custom packages** for Python and Vim plugins in respective `.nix` files
- **Platform-specific additions** through `additionalPackages` parameter

### Key Features
- **Secrets Management**: sops-nix integration with age encryption
- **Container Support**: Podman with docker-compose compatibility
- **Development Tools**: claude-code, git, gh, kubectl, development environments
- **Multi-Architecture**: Support for x86_64 and aarch64 (Apple Silicon, Raspberry Pi)
- **Kubernetes Cluster**: k3s cluster configuration with Helm charts for self-hosted services

### Directory Organization
- Host configurations follow naming pattern `<user>_<hostname>` or `<hostname>`
- Each host has `default.nix` and optional `hardware-configuration.nix`
- Environment files (`env`) contain host-specific environment variables
- Shared functionality imported through `../common` and platform directories

### Infrastructure Components
The k3sCluster directory contains a complete Kubernetes cluster setup with:
- Traefik ingress controller configuration
- Self-hosted services (AdGuard, Vaultwarden, LibreChat, Open WebUI)
- Storage solutions with NFS and DRBD
- Certificate management with cert-manager
- Monitoring and networking configurations

This architecture enables consistent development environments across macOS, NixOS, and containerized deployments while maintaining security through encrypted secrets and modular configuration management.