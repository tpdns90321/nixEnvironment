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
  ngrok
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
