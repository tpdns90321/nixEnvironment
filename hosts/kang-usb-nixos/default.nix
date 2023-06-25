{ ... }:
{
  imports = [
    (import ../../nixos "kang-usb-nixos")
    ./hardware-configuration.nix
  ];
}
