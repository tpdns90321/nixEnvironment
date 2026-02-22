{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  security.pam.enableFscrypt = true;
  services.openssh.enable = true;
  services.openssh.settings.KbdInteractiveAuthentication = false;
  services.displayManager.ly.enable = true;

  programs.mosh.enable = true;

  networking.hostName = "kang-ryzen-pve";
  networking.nameservers = [];

  boot.extraModprobeConfig = "options kvm_amd nested=1";

  systemd.services.home-manager-kang.wantedBy = lib.mkForce [];

  services.qemuGuest.enable = true;
}
