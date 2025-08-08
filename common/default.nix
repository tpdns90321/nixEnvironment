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
        claude-code = unstablePkgs.claude-code;
      })
    ];
  };

  home-manager = {
    users.kang = {
      home.file.".env.nvim" = {
        enable = true;
        text = ''
          ESLINT_USE_FLAT_CONFIG=false
        '';
      };
    };
  };
}
