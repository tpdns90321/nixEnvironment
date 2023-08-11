{ pkgs, inputs, lib }:

(with pkgs; [
  direnv
  git
  gh
  home-manager
  jq
  neofetch
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

  # js development
  nodePackages.npm
  nodePackages.pnpm
  nodePackages.yarn
  nodejs

  # react-native development
  # jdk11 in linux

  # python development
  python310
  poetry

  # rust development
  cargo

  # lspconfig
  rnix-lsp
  rust-analyzer
  nodePackages.vscode-langservers-extracted
  nodePackages.typescript-language-server
  nodePackages."@astrojs/language-server"
  nodePackages."@tailwindcss/language-server"
  nodePackages.pyright
])
