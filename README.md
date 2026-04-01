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
./install_mac.sh

# Build and apply configuration (automatically detects hostname)
./setup_mac.sh
```

#### NixOS
```bash
# Build and switch to configuration
sudo nixos-rebuild switch --flake .#<hostname>

# Available hostnames: kang-stay-nixos, kang-stay-gmk, kang-home-nixos, kang-soyo, kang-virtualbox, kang-rpi4
```

#### Home Manager (WSL/Standalone)
```bash
# Apply home-manager configuration
home-manager switch --flake .#kang  # For WSL
home-manager switch --flake .#pi    # For Raspberry Pi
```

## System Configurations

### macOS Systems
- **kang-macbook-air**: Primary macOS development setup with GUI applications and productivity tools

### NixOS Systems
- **kang-stay-nixos**: Desktop NixOS system
- **kang-stay-gmk**: Server/headless NixOS system
- **kang-home-nixos**: Home NixOS desktop
- **kang-soyo**: Additional NixOS desktop
- **kang-virtualbox**: VirtualBox NixOS instance
- **kang-rpi4**: Raspberry Pi 4 ARM64 NixOS

### Home Manager Configurations
- **kang**: WSL configuration
- **pi**: Raspberry Pi user configuration

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

### Updating `pi-coding-agent`
```bash
# Update to the latest npm release
./update-pi-coding-agent.sh

# Update to a specific version
./update-pi-coding-agent.sh 0.64.0
```

This refreshes `common/pi-coding-agent.json`, regenerates `common/pi-coding-agent-package-lock.json`, rebuilds the package, and checks `pi --version`.

### System Management
```bash
# macOS: Apply configuration changes
./setup_mac.sh

# NixOS: Switch to new configuration
sudo nixos-rebuild switch --flake .#<hostname>

# Home Manager: Apply user configuration
home-manager switch --flake .#<user>
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
4. Build and test: `nix build .#nixosConfigurations.<hostname>.system`

## Troubleshooting

### Common Issues

- **Flake evaluation errors**: Run `nix flake check` to identify issues
- **Build failures**: Check if all inputs are up to date with `nix flake update`
- **Permission issues**: Ensure proper user permissions for Nix store

### Getting Help

- Check the `CLAUDE.md` file for detailed architecture information
- Review individual host configurations in `hosts/` directory
- Consult Nix documentation for flake-specific issues

## License

This configuration is personal use oriented. Feel free to use as reference for your own Nix configurations.
