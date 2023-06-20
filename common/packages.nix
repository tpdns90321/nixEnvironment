{ pkgs }:

with pkgs; [
  git
  gh
  home-manager
  jq
  neofetch
  tmux
  wget
  zsh

  # js development
  nodePackages.npm
  nodePackages.pnpm
  nodePackages.yarn
  nodejs

  # react-native development
  # jdk11 in linux

  # python development
  python311

  # lspconfig
  rnix-lsp
  nodePackages.vscode-langservers-extracted
  nodePackages.typescript-language-server
  nodePackages.pyright
]
