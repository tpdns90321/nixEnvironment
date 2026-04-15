{ pkgs, lib, inputs, additionalPackages ? [ ] }:

(with pkgs; [
  curl
  deno
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

  # secrets management
  age
  ssh-to-age
  sops

  # lspconfig
  nixd
]) ++ (builtins.map (name: pkgs.${name}) additionalPackages)
