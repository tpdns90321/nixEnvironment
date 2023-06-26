#!/bin/zsh

print 'install Nix'
sh <(curl -L https://nixos.org/nix/install)

print 'install nix-darwin'
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer

print 'install homebrew'
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

print 'install symlink'
echo 'run\tprivate/var/run' | sudo tee -a /etc/synthetic.conf
sudo /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t
