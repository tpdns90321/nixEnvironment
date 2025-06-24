{ pkgs, inputs, lib, additionalPackages ? [ ] }:

(with pkgs; [
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

  # rust development
  rustup
]) ++ additionalPackages
