{ pkgs, inputs, lib, additionalPackages ? [ ] }:

(with pkgs; [
  curlHTTP3
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
]) ++ additionalPackages
