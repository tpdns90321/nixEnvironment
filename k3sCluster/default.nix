{ ... }: {
  imports = [
    ./drbd.nix
    ./nfs.nix
    ./cluster.nix
  ];
}
