{ user ? "kang", ... }:

{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home-manager = {
    users.${user} = {
      home.file.".env.nvim" = {
        enable = true;
        text = ''
          ESLINT_USE_FLAT_CONFIG=false
        '';
      };
    };
  };
}
