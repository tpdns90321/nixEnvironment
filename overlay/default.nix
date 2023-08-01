prev: final: {
  caddy-with-plugins = (
    import ./caddy.nix { inherit prev; }
  );
}
