#!/bin/zsh

FLAKE=$(echo $HOST | sed 's/\.local//')

echo $FLAKE

echo Create Misc Folder
mkdir -p ~/Library/Application\ Support/TunnelBlick/Configurations || true

echo Find hostname in hosts and building
nix --extra-experimental-features 'nix-command flakes' build .#darwinConfigurations.$FLAKE.system $@
echo install flake
./result/sw/bin/darwin-rebuild switch --flake . $@
