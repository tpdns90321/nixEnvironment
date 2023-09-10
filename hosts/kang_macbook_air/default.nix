{ user, home-manager, sops-nix, ... }: {
  home-manager.users.${user}.sops = {
    age.keyFile = "/Users/${user}/Library/Application Support/sops/age/keys.txt";
    secrets.env = {
      sopsFile = ./env;
      format = "binary";
      path = "/Users/${user}/.env";
    };
  };
}
