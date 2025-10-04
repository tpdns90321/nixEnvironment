{ pkgs, inputs, lib, additionalPackages ? [], isDesktop ? false }:

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
  in
  (import ./packages.nix { inherit pkgs inputs lib additionalPackages; }) ++ (if isDesktop then (with pkgs; [
  my-helm
  my-helmfile

  # AI Code Assistant
  codex
  claude-code

  # GUI Application for work
  alacritty
  gimp
  
  # VSCode
  (
    vscode-with-extensions.override {
      vscodeExtensions = (with vscode-marketplace; [
        vscodevim.vim
        arcanis.vscode-zipfs
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
        ms-vscode.remote-explorer
        ms-vscode-remote.remote-ssh
        github.copilot
        github.copilot-chat
      ]);
    }
  )

  # Local llms
  (if pkgs.stdenv.hostPlatform.isLinux then 
    lmstudio
  else emptyDirectory)
]) else [])
