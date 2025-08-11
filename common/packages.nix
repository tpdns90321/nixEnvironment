{ pkgs, inputs, lib, additionalPackages ? [ ] }:

(with pkgs; [
  codex
  claude-code
  curlHTTP3
  direnv
  fnm
  git
  gh
  home-manager
  jc
  jq
  neofetch
  mosh
  screen
  tmux
  uv
  wget
  zsh

  kubectl

  # secrets management
  age
  ssh-to-age
  sops

  # podman(docker alternative)
  podman
  docker-compose
  podman-compose

  # js development
  nodejs_22
  nodePackages_latest.npm
  nodePackages_latest.pnpm
  nodePackages_latest.yarn

  # react-native development
  # jdk11 in linux

  # python development
  python311
  uv

  # rust development
  rustup
]) ++ additionalPackages
