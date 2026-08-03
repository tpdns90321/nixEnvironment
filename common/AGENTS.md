# COMMON KNOWLEDGE BASE

## OVERVIEW

Shared package lists and Home Manager program settings consumed by Darwin, NixOS, and standalone outputs.

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Add base CLI/dev tools | `packages.nix` | Imported by desktop package layer and NixOS system packages. |
| Add desktop apps/tools | `packages_desktop.nix` | Wrap with `isDesktop`; imports `packages.nix` first. |
| Change shared shell/editor behavior | `home-manager.nix` | Merged into Darwin, NixOS, and standalone home configs. |
| Maintain custom Python package | `customPythonPackages.nix` | Keep overrides local to Python packaging. |
| Maintain custom Vim plugin | `customVimPlugins.nix` | Fed by flake inputs such as `copilot-vim` and `vim-rzip`. |
| Maintain pi coding agent package | `pi-coding-agent.nix`, `pi-coding-agent.json`, `pi-coding-agent-package-lock.json` | Prefer `../update-pi-coding-agent.sh`. |
| Adjust sandbox JSON | `pi-sandbox-json.nix` | Treat as agent/runtime config, not system package policy. |

## CONVENTIONS

- `packages_desktop.nix` composes `packages.nix` and then conditionally appends desktop packages when `isDesktop` is true.
- `additionalPackages` is a list of package attribute names, mapped with `pkgs.${name}`; validate names before adding them.
- `home-manager.nix` returns attrsets that callers merge with platform-specific program settings.
- Shared files should accept only the arguments already used by callers unless every import site is updated together.

## ANTI-PATTERNS

- Do not put macOS-only Homebrew, casks, or App Store apps here; those belong under `darwin/` and flake special args.
- Do not put host-only tools here unless they are genuinely portable defaults.
- Do not bypass `packages_desktop.nix` when adding desktop packages for both Linux desktop and Darwin.
- Do not manually drift `pi-coding-agent.json` from its lock file.

## CHECKS

```bash
nix flake check
./update-pi-coding-agent.sh
```
