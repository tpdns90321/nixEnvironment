#!/bin/sh

# requirements
sudo apt install -y curl lsb-release xz-utils zsh

# default shell change to zsh
printf "Change default shell to zsh"
chsh -s $(which zsh)

# systemd-genie
printf "Install systemd-genie"
sudo curl -o /etc/apt/trusted.gpg.d/wsl-transdebian.gpg https://arkane-systems.github.io/wsl-transdebian/apt/wsl-transdebian.gpg
sudo chmod a+r /etc/apt/trusted.gpg.d/wsl-transdebian.gpg
cat << EOF | sudo tee /etc/apt/sources.list.d/wsl-transdebian.list
deb https://arkane-systems.github.io/wsl-transdebian/apt/ $(lsb_release -cs) main
deb-src https://arkane-systems.github.io/wsl-transdebian/apt/ $(lsb_release -cs) main
EOF

sudo apt update
sudo apt install systemd-genie
