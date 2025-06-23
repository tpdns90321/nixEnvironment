{ ... }:

{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
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
