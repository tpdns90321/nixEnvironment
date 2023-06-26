{ pkgs, ... }:

let lock = builtins.fromJSON (builtins.readFile ../flake.lock); in
  let buildVimPluginFromFlake = name: let package = lock.nodes.${name}.locked;
    in pkgs.vimUtils.buildVimPlugin {
      name = "${name}";
      src = pkgs.fetchFromGitHub {
        owner = package.owner;
        repo = package.repo;
        rev = package.rev;
        sha256 = package.narHash;
      };
    }; in
[
  (buildVimPluginFromFlake "vim-astro")
]
