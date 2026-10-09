# Kang's Nix Environment

A comprehensive Nix flake-based configuration for managing development environments and infrastructure across multiple platforms including macOS, NixOS, and containerized deployments.

## Features

- 🖥️ **Multi-Platform Support**: macOS (nix-darwin), NixOS, WSL, and Raspberry Pi
- 🔧 **Development Tools**: Comprehensive setup with Claude Code, Git, Kubernetes tools, and more
- 🐳 **Container Support**: Podman with Docker Compose compatibility
- 🔐 **Secrets Management**: Encrypted secrets using sops-nix and age
- ☸️ **Kubernetes Cluster**: Complete k3s cluster with self-hosted services
- 📦 **Package Management**: Modular package organization with shared and platform-specific configurations

## Quick Start

### Initial Setup

#### macOS
```bash
# Install Nix, nix-darwin, and Homebrew
./setup_mac.sh

# Build and apply configuration (automatically detects hostname)
./install_mac.sh
```

#### NixOS
```bash
# Build and switch to configuration
sudo nixos-rebuild switch --flake .#<hostname>

# Available hostnames: see "NixOS Systems" below
```

#### Home Manager (WSL/Standalone)
```bash
# Apply home-manager configuration
home-manager switch --flake .#kang-x86_64-linux   # x86_64 Linux / WSL
home-manager switch --flake .#kang-aarch64-linux  # ARM64 Linux
```

## System Configurations

### macOS Systems
- **kang-macbook-air**: Primary macOS development setup with GUI applications and productivity tools

### NixOS Systems
- **kang-stay-nixos**: Desktop NixOS system
- **kang-stay-gmk**: Server/headless NixOS system
- **kang-home-nixos**: Home NixOS desktop
- **kang-soyo**: Additional NixOS desktop
- **kang-odyssey**: Server/headless NixOS system
- **kang-ryzen**: Ryzen NixOS desktop
- **kang-ryzen-pve**: Ryzen Proxmox NixOS guest
- **kang-virtualbox**: VirtualBox NixOS instance
- **kang-rpi4**: Raspberry Pi 4 ARM64 NixOS

### Home Manager Configurations
- **kang-x86_64-linux**: Standalone Home Manager for user `kang` on x86_64 Linux / WSL
- **kang-aarch64-linux**: Standalone Home Manager for user `kang` on ARM64 Linux

Both standalone outputs currently enable the desktop profile. There is no `pi` Home Manager output; `kang-rpi4` is a NixOS system output.

## Directory Structure

```
nixEnvironment/
├── flake.nix                 # Main flake definition
├── common/                   # Shared configurations
│   ├── packages.nix         # Base packages
│   ├── packages_desktop.nix # Desktop packages
│   └── home-manager.nix     # Home Manager config
├── hosts/                    # Host-specific configurations
├── darwin/                   # macOS configurations
├── nixos/                    # NixOS configurations
├── standalone/               # Home Manager standalone
├── k3sCluster/              # Kubernetes cluster setup
└── containers/              # Container configurations
```

## Common Commands

### Flake Management
```bash
# Update all inputs
nix flake update

# Update specific input
nix flake update nixpkgs

# Check flake validity
nix flake check

# Show available outputs
nix flake show
```

### Safe Dependency Updates

The stable Nixpkgs, Home Manager, and nix-darwin inputs track 26.05. Refresh their pinned revisions together before considering a release upgrade:

```bash
nix flake update nixpkgs nixos home-manager darwin
git diff -- flake.lock
nix flake check --no-update-lock-file

# Build the output for the machine you intend to update, without activating it
nix build --no-link --no-update-lock-file .#homeConfigurations.kang-x86_64-linux.activationPackage
# NixOS example (use your actual host)
nix build --no-link --no-update-lock-file .#nixosConfigurations.kang-stay-nixos.config.system.build.toplevel
# macOS example (run on an Apple Silicon Mac)
nix build --no-link --no-update-lock-file .#darwinConfigurations.kang-macbook-air.system
```

Run only the applicable platform builds. Review the lock diff and test the target configuration before switching. Updating the lock does not require raising `home.stateVersion` or `system.stateVersion`; preserve those compatibility settings unless deliberately migrating state.

Note: standalone declares `home.stateVersion = "25.05"`, but its current merge with `linux_desktop` makes the effective value `"26.05"`. Check the installation's existing state before changing either value.

### Updating `pi-coding-agent`
```bash
# Update to the latest npm release
./update-pi-coding-agent.sh

# Update to a specific version
./update-pi-coding-agent.sh 0.64.0
```

This refreshes `common/pi-coding-agent.json`, regenerates `common/pi-coding-agent-package-lock.json`, rebuilds the package with the stable `nixpkgs` input used by the shared overlay, and checks `pi --version`.

### System Management
```bash
# macOS: Apply configuration changes
./install_mac.sh

# NixOS: Switch to new configuration
sudo nixos-rebuild switch --flake .#<hostname>

# Home Manager: Apply user configuration
home-manager switch --flake .#kang-<architecture>-linux
```

## Included Software

### Development Tools
- **Neovim**: Full-featured editor with LSP support, auto-completion, and language servers for TypeScript, Python, Go, Rust, Nix, and more
- **Git & GitHub CLI**: Version control and GitHub integration
- **Kubernetes Tools**: kubectl, helm, and k3s cluster management
- **Container Tools**: Podman, docker-compose, podman-compose
- **Claude Code**: AI-powered development assistant

### System Administration
- **Secrets Management**: age, sops, ssh-to-age
- **Networking**: mosh, wget, curl (with HTTP/3 support)
- **System Monitoring**: neofetch, various debugging tools

### Desktop Applications (macOS/NixOS Desktop)
- **Media**: Discord, OBS, various productivity apps
- **Development**: Android Studio, various IDEs and tools
- **System Utilities**: Comprehensive suite of desktop applications

## Kubernetes Cluster

The `k3sCluster/` directory contains a complete Kubernetes setup with:

- **Ingress**: Traefik with automatic HTTPS
- **Services**: AdGuard Home, Vaultwarden, LibreChat, Open WebUI
- **Storage**: NFS and DRBD configurations
- **Monitoring**: Various monitoring and logging solutions
- **Networking**: Advanced networking with VPN support

### Deploying Services
```bash
cd k3sCluster
helmfile sync
```

## Secrets Management

This repository uses sops-nix for encrypted secrets:

```bash
# Edit secrets file
sops secrets.yaml

# Generate new age key
age-keygen -o ~/.config/sops/age/keys.txt
```

## Contributing

1. Make changes to the appropriate configuration files
2. Test locally with `nix flake check`
3. Apply changes using the appropriate rebuild command
4. Commit and push changes

## Host Addition

To add a new host:

1. Create `hosts/<hostname>/default.nix`
2. Add hardware configuration if needed
3. Update `flake.nix` with new system configuration
4. Build and test without activating: `nix build --no-link .#nixosConfigurations.<hostname>.config.system.build.toplevel`

## Troubleshooting

### Common Issues

- **Flake evaluation errors**: Run `nix flake check` to identify issues
- **Build failures**: Inspect the first error and the target output before changing dependencies. If an update caused the failure, restore the previous reviewed lock file and rebuild.
- **Permission issues**: Ensure proper user permissions for Nix store

### Getting Help

- Check the `CLAUDE.md` file for detailed architecture information
- Review individual host configurations in `hosts/` directory
- Consult Nix documentation for flake-specific issues

## License

This configuration is personal use oriented. Feel free to use as reference for your own Nix configurations.
