{ pkgs, inputs, lib, additionalPackages ? [ ] }:

(with pkgs; [
  bitwarden-cli
  curlHTTP3
  direnv
  fnm
  git
  gh
  home-manager
  jc
  jq
  neofetch
  ngrok
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
]) ++ additionalPackages
