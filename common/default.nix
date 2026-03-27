{ inputs, ... }:

{
  nixpkgs = let config = { allowUnfree = true; }; in {
    inherit config;
    overlays = [
      (final: prev: let
        unstablePkgs = (import inputs.nixpkgs_unstable {
          inherit config;
          inherit (final) system;
        });
      in {
        vscode-with-extensions = unstablePkgs.vscode-with-extensions;
        codex = unstablePkgs.codex;
        claude-code = unstablePkgs.claude-code;
        opencode = unstablePkgs.opencode;
        gemini-cli = unstablePkgs.gemini-cli;
        gemini-cli-bin = unstablePkgs.gemini-cli-bin;
        antigravity = unstablePkgs.antigravity;
        uv = unstablePkgs.uv;
        nodePackages = unstablePkgs.nodePackages;
        inetutils = unstablePkgs.inetutils;
        alacritty = unstablePkgs.alacritty;
      })
      inputs.nix-vscode-extensions.overlays.default
    ];
  };
}
