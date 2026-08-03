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
        pi-coding-agent = final.callPackage ./pi-coding-agent.nix { };
        uv = unstablePkgs.uv;
        alacritty = unstablePkgs.alacritty;
      })
      inputs.nix-vscode-extensions.overlays.default
    ];
  };
}
