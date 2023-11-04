{ pkgs, inputs, lib }:

(with pkgs; [
  direnv
  fnm
  git
  gh
  home-manager
  jq
  neofetch
  mosh
  screen
  tmux
  wget
  zsh

  # secrets management
  age
  ssh-to-age
  sops

  # podman(docker alternative)
  podman
  podman-compose

  # js development
  nodePackages.npm
  nodePackages.pnpm
  nodePackages.yarn
  nodejs

  # react-native development
  # jdk11 in linux

  # python development
  python311

  # rust development
  cargo
])
