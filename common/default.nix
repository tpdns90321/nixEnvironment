{ inputs, ... }:

{
  nixpkgs = let config = { allowUnfree = true; }; in {
    inherit config;
    overlays = [
      (final: prev: let
        unstablePkgs = (import inputs.nixpkgs_unstable {
          inherit config;
          system = final.stdenv.hostPlatform.system;
        });
      in {
        vscode-with-extensions = unstablePkgs.vscode-with-extensions;
        codex = unstablePkgs.codex;
        claude-code = unstablePkgs.claude-code;
        direnv = unstablePkgs.direnv;
        opencode = unstablePkgs.opencode;
        gemini-cli = unstablePkgs.gemini-cli;
        gemini-cli-bin = unstablePkgs.gemini-cli-bin;
        antigravity = unstablePkgs.antigravity;
        pi-coding-agent = final.callPackage ./pi-coding-agent.nix { };
        uv = unstablePkgs.uv;
        inetutils = unstablePkgs.inetutils;
        alacritty = unstablePkgs.alacritty;
      })
      inputs.nix-vscode-extensions.overlays.default
    ];
  };
}
