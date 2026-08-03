# PROJECT KNOWLEDGE BASE

**Generated:** 2026-06-14
**Commit:** ea142cc
**Branch:** main

## OVERVIEW

Personal Nix flake for macOS, NixOS, WSL, Raspberry Pi, containers, and a k3s self-hosting cluster. Core stack: Nix flakes, nix-darwin, Home Manager, sops-nix, Helmfile, and local Helm charts.

## STRUCTURE

```
nixEnvironment/
|-- flake.nix                  # all darwin, nixos, and home-manager outputs
|-- common/                    # shared packages and Home Manager programs
|-- hosts/                     # machine-specific modules and hardware files
|-- darwin/                    # nix-darwin system and Homebrew/App Store glue
|-- nixos/                     # shared NixOS desktop/server baseline
|-- standalone/                # Home Manager for WSL and non-NixOS users
|-- containers/                # Podman and compose service helpers
|-- k3sCluster/                # k3s, DRBD/NFS, Helmfile, and service charts
\-- tasks/                     # agent lessons
```

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Add or rename a flake output | `flake.nix` | Keep host names aligned with `hosts/<name>/` modules. |
| Add shared CLI tools | `common/packages.nix` | Base package set; receives `additionalPackages` by attribute name. |
| Add desktop GUI tools | `common/packages_desktop.nix` | Desktop-only layer gated by `isDesktop`. |
| Change common shell/editor config | `common/home-manager.nix` | Imported by Darwin, NixOS, and standalone flows. |
| Add macOS system behavior | `darwin/` | Homebrew casks/brews/App Store values come through flake special args. |
| Add NixOS baseline behavior | `nixos/` | Shared OS services, Sway, PipeWire, packages, users. |
| Add a host | `hosts/<host>/`, `flake.nix` | Pair `default.nix` with hardware config when NixOS. |
| Work on k3s services | `k3sCluster/` | Read its child AGENTS.md first. |
| Update pi coding agent package | `update-pi-coding-agent.sh`, `common/pi-coding-agent.*` | Script refreshes JSON lock and checks `pi --version`. |
| Record durable corrections | `tasks/lessons.md` | Only record concrete repeat-prone lessons. |

## CODE MAP

| Symbol / File | Type | Location | Role |
| --- | --- | --- | --- |
| `darwinConfigurations.kang-macbook-air` | flake output | `flake.nix` | Apple Silicon nix-darwin system. |
| `homeConfigurations` | flake output | `flake.nix` | Architecture-mapped standalone Home Manager outputs. |
| `nixosConfigurations.kang-*` | flake outputs | `flake.nix` | x86_64 and aarch64 NixOS hosts. |
| `common/packages.nix` | package list | `common/` | Shared CLI/dev/admin tools. |
| `common/packages_desktop.nix` | package list | `common/` | Desktop apps plus base packages. |
| `common/home-manager.nix` | module data | `common/` | Shared programs imported across platforms. |
| `k3sCluster/helmfile.yaml` | deployment graph | `k3sCluster/` | Chart releases, values, secrets, and dependencies. |
| `k3sCluster/cluster.nix` | NixOS module | `k3sCluster/` | k3s server/agent, WireGuard, DRBD orchestration. |

## CONVENTIONS

- This repo passes host-specific knobs through flake `specialArgs` / `extraSpecialArgs`: `inputs`, `additionalPackages`, `isDesktop`, `user`, and platform-specific app lists.
- Package additions are strings only when they flow through `additionalPackages` and are resolved as `pkgs.${name}`; direct package expressions belong in the package list file.
- Host directories are named with underscores, while flake output names use hyphenated host IDs.
- `CLAUDE.md` delegates to `AGENTS.md`; keep root guidance complete enough for Claude-compatible agents.
- Secret-like files exist in-tree. Do not print, normalize, or replace secret contents while doing unrelated work.

## ANTI-PATTERNS (THIS PROJECT)

- Do not move host-specific settings into `common/` unless every consuming platform should inherit them.
- Do not add desktop packages to the base package layer; keep GUI-heavy packages behind `isDesktop`.
- Do not hand-edit generated package-lock JSON for `pi-coding-agent`; use the updater script.
- Do not remove sops-nix wiring when touching hosts or k3s modules.
- Do not flatten `k3sCluster/charts/` values/secrets into `helmfile.yaml`; release-local files are intentional.

## UNIQUE STYLES

- Nix modules are small and import-oriented; `flake.nix` is the composition hub.
- Infrastructure is personal but multi-platform: prefer explicit host entries over clever discovery.
- Kubernetes services are managed as local Helm charts with per-service `values.yaml` and `secrets.yaml`.
- Lessons are dated one-line issue-to-fix entries.

## COMMANDS

```bash
nix flake check
nix flake show
./setup_mac.sh
sudo nixos-rebuild switch --flake .#<hostname>
home-manager switch --flake .#<user>
./update-pi-coding-agent.sh
cd k3sCluster && helmfile sync
```

## NOTES

- Current branch was `main` when generated; working tree already had user changes in flake/common files.
- LSP was not available in this session; code map is file/output based.
- The Hermes chart under `k3sCluster/charts/hermes-agent/chart` is also a nested Git boundary.
