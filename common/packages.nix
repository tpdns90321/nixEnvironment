{ pkgs, inputs, ... }:

(with pkgs; [
  git
  gh
  home-manager
  jq
  neofetch
  postman
  tmux
  vscodium
  wget
  zsh

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
  python311

  # lspconfig
  rnix-lsp
  nodePackages.vscode-langservers-extracted
  nodePackages.typescript-language-server
  nodePackages."@astrojs/language-server"
  nodePackages."@tailwindcss/language-server"
  nodePackages.pyright
]) ++ [ inputs.llama_cpp.packages.${pkgs.system}.default ]
