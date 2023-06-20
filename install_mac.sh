#!/bin/zsh

FLAKE=$(echo $HOST | sed 's/\.local//')

echo $FLAKE

print Find hostname in hosts and building
nix --extra-experimental-features 'nix-command flakes' build .#darwinConfigurations.$FLAKE.system --impure
print install flake
./result/sw/bin/darwin-rebuild switch --flake . --impure
