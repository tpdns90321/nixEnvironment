{ pkgs, inputs, lib, additionalPackages ? [ ] }:

let
  my-helm = (pkgs.wrapHelm pkgs.kubernetes-helm {
    plugins = with pkgs.kubernetes-helmPlugins; [
      helm-diff
      helm-secrets
    ];
  });
  my-helmfile = pkgs.helmfile-wrapped.override {
    inherit (my-helm) pluginsDir;
  };
in (with pkgs; [
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
  my-helm
  my-helmfile

  # secrets management
  age
  ssh-to-age
  sops

  # podman(docker alternative)
  podman
  docker-compose
  podman-compose

  # js development
  nodejs_20
  nodePackages_latest.npm
  nodePackages_latest.pnpm
  nodePackages_latest.yarn

  # react-native development
  # jdk11 in linux

  # python development
  python311

  # rust development
  cargo
]) ++ additionalPackages
