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

  # direnv
  direnv

  # AI Code Assistant
  codex
  claude-code
  opencode

  # GUI Application for work
  alacritty

  # Kubernetes development
  kubectl

  # js development
  bun
  fnm
  nodePackages.npm
  nodePackages.pnpm
  nodePackages.yarn

  # golang development
  go

  # react-native development
  # jdk11 in linux

  # python development
  python311
  uv

  # rust development
  rustup
  
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

] ++
  (if pkgs.stdenv.hostPlatform.isLinux then 
    [
      # temporary painter
      gimp
      # vnc client
      wayvnc

      # wireshark
      wireshark
    ]
  else [])
) else [])
