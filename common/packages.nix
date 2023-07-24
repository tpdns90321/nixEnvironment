{ pkgs, inputs, lib }:

(with pkgs; [
  git
  gh
  home-manager
  jq
  neofetch
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
  (python310.withPackages (ps: ((with ps; [
  ]) ++ (import ./customPythonPackages.nix { ps = ps; inputs = inputs; lib = lib; }))))

  # lspconfig
  rnix-lsp
  nodePackages.vscode-langservers-extracted
  nodePackages.typescript-language-server
  nodePackages."@astrojs/language-server"
  nodePackages."@tailwindcss/language-server"
  nodePackages.pyright
]) ++ [ inputs.llama_cpp.packages.${pkgs.system}.default ]
