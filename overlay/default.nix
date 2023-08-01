prev: final: {
  caddy-with-plugins = (
    final.callPackage ./caddy.nix { inherit prev; plugins = [ "github.com/caddy-dns/duckdns" ]; vendorSha256="sha256-fiDAqzpHUY1TmU/6BXnAhz1JRYJh83gfN181LEZC9m0="; }
  );
}
