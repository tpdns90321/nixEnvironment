#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package_name='@mariozechner/pi-coding-agent'
registry_url='https://registry.npmjs.org/%40mariozechner%2Fpi-coding-agent'
metadata_file="$repo_root/common/pi-coding-agent.json"
lockfile_file="$repo_root/common/pi-coding-agent-package-lock.json"

usage() {
  echo "Usage: $0 [version]" >&2
}

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "error: missing required command: $cmd" >&2
    exit 1
  fi
}

for cmd in curl jq npm nix tar mktemp; do
  require_command "$cmd"
done

if [[ $# -gt 1 ]]; then
  usage
  exit 1
fi

requested_version="${1-}"
fake_hash='sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='

tmpdir="$(mktemp -d)"
cleanup_mode="restore"

had_metadata=0
had_lockfile=0
backup_metadata="$tmpdir/original-pi-coding-agent.json"
backup_lockfile="$tmpdir/original-pi-coding-agent-package-lock.json"

if [[ -f "$metadata_file" ]]; then
  had_metadata=1
  cp "$metadata_file" "$backup_metadata"
fi

if [[ -f "$lockfile_file" ]]; then
  had_lockfile=1
  cp "$lockfile_file" "$backup_lockfile"
fi

cleanup() {
  if [[ "$cleanup_mode" == "restore" ]]; then
    if [[ $had_metadata -eq 1 ]]; then
      cp "$backup_metadata" "$metadata_file"
    else
      rm -f "$metadata_file"
    fi

    if [[ $had_lockfile -eq 1 ]]; then
      cp "$backup_lockfile" "$lockfile_file"
    else
      rm -f "$lockfile_file"
    fi
  fi

  rm -rf "$tmpdir"
}

trap cleanup EXIT

registry_json="$(curl -fsSL "$registry_url")"

if [[ -n "$requested_version" ]]; then
  version="$requested_version"
else
  version="$(jq -r '."dist-tags".latest // empty' <<<"$registry_json")"
fi

if [[ -z "$version" ]]; then
  echo "error: could not resolve target version" >&2
  exit 1
fi

src_hash="$(jq -r --arg version "$version" '.versions[$version].dist.integrity // empty' <<<"$registry_json")"
tarball_url="$(jq -r --arg version "$version" '.versions[$version].dist.tarball // empty' <<<"$registry_json")"

if [[ -z "$src_hash" || -z "$tarball_url" ]]; then
  echo "error: version $version was not found in npm registry metadata" >&2
  exit 1
fi

workdir="$tmpdir/work"
mkdir -p "$workdir"
tarball_path="$workdir/pi-coding-agent.tgz"
package_dir="$workdir/package"
npm_cache="$workdir/.npm-cache"

curl -fsSL "$tarball_url" -o "$tarball_path"
tar -xzf "$tarball_path" -C "$workdir"

cd "$package_dir"
tmp_package_json="$workdir/package.json.tmp"
tmp_lockfile="$workdir/package-lock.json"
tmp_metadata="$workdir/pi-coding-agent.json"
tmp_build_log="$workdir/nix-build.log"
tmp_out_path="$workdir/out-path.txt"

jq 'del(.devDependencies)' package.json > "$tmp_package_json"
mv "$tmp_package_json" package.json

npm_config_cache="$npm_cache" npm install --package-lock-only --ignore-scripts --omit=dev --package-lock >/dev/null
cp package-lock.json "$tmp_lockfile"

jq -n \
  --arg version "$version" \
  --arg srcHash "$src_hash" \
  --arg npmDepsHash "$fake_hash" \
  '{version: $version, srcHash: $srcHash, npmDepsHash: $npmDepsHash}' > "$tmp_metadata"

install -m 0644 "$tmp_lockfile" "$lockfile_file"
install -m 0644 "$tmp_metadata" "$metadata_file"

cd "$repo_root"
build_expr='let flake = builtins.getFlake ("path:" + toString ./.); pkgs = import flake.inputs.nixpkgs_unstable { system = builtins.currentSystem; config.allowUnfree = true; }; in pkgs.callPackage ./common/pi-coding-agent.nix {}'

set +e
nix build --impure --no-link --expr "$build_expr" > /dev/null 2> "$tmp_build_log"
build_status=$?
set -e

if [[ $build_status -eq 0 ]]; then
  echo "error: expected the first build to fail with a fake npmDepsHash" >&2
  exit 1
fi

npm_deps_hash="$(sed -n 's/.*got:[[:space:]]*\(sha256-[A-Za-z0-9+/=]*\).*/\1/p' "$tmp_build_log" | tail -n 1)"

if [[ -z "$npm_deps_hash" ]]; then
  echo "error: could not extract npmDepsHash from nix build output" >&2
  cat "$tmp_build_log" >&2
  echo "build log: $tmp_build_log" >&2
  exit 1
fi

jq --arg npmDepsHash "$npm_deps_hash" '.npmDepsHash = $npmDepsHash' "$metadata_file" > "$tmp_metadata"
mv "$tmp_metadata" "$metadata_file"

nix build --impure --no-link --print-out-paths --expr "$build_expr" > "$tmp_out_path"
out_path="$(tail -n 1 "$tmp_out_path")"

if [[ -z "$out_path" || ! -x "$out_path/bin/pi" ]]; then
  echo "error: built output is missing bin/pi" >&2
  exit 1
fi

smoke_dir="$(mktemp -d "$tmpdir/pi-smoke.XXXXXX")"
smoke_version="$(PI_CODING_AGENT_DIR="$smoke_dir" "$out_path/bin/pi" --version 2>&1 | tail -n 1)"

if [[ "$smoke_version" != "$version" ]]; then
  echo "error: smoke test reported version '$smoke_version', expected '$version'" >&2
  exit 1
fi

cleanup_mode="keep"
echo "Updated $package_name to $version"
echo "srcHash: $src_hash"
echo "npmDepsHash: $npm_deps_hash"
