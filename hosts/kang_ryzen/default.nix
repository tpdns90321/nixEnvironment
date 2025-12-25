{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.kernel.sysctl."mm.ksm.run" = true;
  boot.kernel.sysctl."mm.ksm.pages_to_scan" = 5000;
  boot.kernel.sysctl."mm.ksm.sleep_millisecs" = 5;

  security.pam.enableFscrypt = true;
  services.openssh.enable = true;
  services.openssh.settings.KbdInteractiveAuthentication = false;

  programs.mosh.enable = true;

  networking.hostName = "kang-ryzen";
  networking.nameservers = [];
  networking.useNetworkd = true;
  networking.bridges.br0.interfaces = [ "enp34s0" ];
  networking.interfaces.enp34s0.wakeOnLan.enable = true;

  systemd.network.networks."20-br0" = {
    matchConfig = {
      Name = "br0";
    };

    networkConfig = {
      DHCP = true;
    };
  };

  networking.firewall = {
    extraCommands = with pkgs; let ip = "${iproute2}/bin/ip"; in ''
      ${ip} route flush table 200
      ${ip} route add table 200 192.168.219.150/32 dev ztfp6i26fp
      ${ip} rule add fwmark 0x1 table 200
      iptables -t mangle -A OUTPUT -d 192.168.219.150 -p tcp --dport 80 -j MARK --set-mark 0x1
      iptables -t mangle -A OUTPUT -d 192.168.219.150 -p tcp --dport 443 -j MARK --set-mark 0x1
      iptables -t mangle -A OUTPUT -d 192.168.219.150 -p udp --dport 443 -j MARK --set-mark 0x1
    '';
  };

  users.users.kang.extraGroups = [ "libvirtd" "docker" ];

  virtualisation.waydroid.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          }).fd
        ];
      };
    };
  };
  virtualisation.docker.enable = true;

  boot.extraModprobeConfig = "options kvm_amd nested=1";
}
