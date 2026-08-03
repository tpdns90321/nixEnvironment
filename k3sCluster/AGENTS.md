# K3S CLUSTER KNOWLEDGE BASE

## OVERVIEW

k3s NixOS modules plus Helmfile-managed self-hosted services, with DRBD/NFS storage and sops-backed secrets.

## STRUCTURE

```
k3sCluster/
|-- default.nix                # imports DRBD and NFS modules
|-- cluster.nix                # k3s server/agent, WireGuard, DRBD lifecycle
|-- drbd.nix                   # DRBD resources and service fixes
|-- nfs.nix                    # NFS export policy
|-- helmfile.yaml              # release graph and chart dependencies
|-- *_values.yaml              # root-level chart values
|-- *_private_key, tokenfile   # sops inputs; do not print
\-- charts/                    # local Helm charts and release-local secrets
```

## WHERE TO LOOK

| Task | Location | Notes |
| --- | --- | --- |
| Change k3s server/agent behavior | `cluster.nix` | Watch server vs agent branches and token file paths. |
| Change DRBD resources | `drbd.nix`, `cluster.nix` | Device names and mount lifecycle are coupled. |
| Change NFS exports | `nfs.nix` | Exports are broad and network-specific. |
| Add a Helm release | `helmfile.yaml`, `charts/<service>/` | Add `needs`, values, and secrets consistently. |
| Change Traefik | `traefik_values.yaml`, chart templates | Many releases depend on `traefik/traefik`. |
| Change cert-manager config | `charts/cert-manager-config/` | Uses chart-local secrets and must depend on cert-manager. |
| Work on Hermes Agent chart | `charts/hermes-agent/chart/` | Read nested AGENTS.md. |

## CONVENTIONS

- Helmfile releases use chart-local `values.yaml` and `secrets.yaml`; dependencies are explicit with `needs`.
- Namespaces generally match release/service names.
- Sops files sit next to the consumer that references them.
- Local service charts use simple `Chart.yaml`, `values.yaml`, `templates/`, and optional `secrets.yaml`.
- k3s systemd behavior in `cluster.nix` is operational code; small ordering changes can affect boot/recovery.

## ANTI-PATTERNS

- Do not inline secret material in templates, values, docs, or final messages.
- Do not remove `needs: traefik/traefik` from ingress-backed services without replacing ingress ordering.
- Do not change DRBD primary/secondary or `--discard-my-data` flows without checking both host disks and mount points.
- Do not add a chart release without values/secrets paths matching the chart directory convention.
- Do not assume a chart under `charts/` is upstream-standard; several are local wrappers.

## COMMANDS

```bash
cd k3sCluster && helmfile lint
cd k3sCluster && helmfile diff
cd k3sCluster && helmfile sync
sudo nixos-rebuild test --flake .#kang-stay-gmk
```

## NOTES

- `helmfile.yaml` includes third-party repos plus many local charts.
- `charts/hermes-agent/chart` is a nested Git boundary and has its own chart QA.
