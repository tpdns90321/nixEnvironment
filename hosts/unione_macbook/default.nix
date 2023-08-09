{ user, home-manager, sops-nix, ... }: {
  home-manager.users.${user}.sops = {
    age.keyFile = "/Users/${user}/Library/Application Support/sops/age/keys.txt";
    secrets.openvpn = {
      sopsFile = ../client.ovpn;
      format = "binary";
      path = "/Users/${user}/Library/Application Support/TunnelBlick/Configurations/home.ovpn";
    };
  };
}
