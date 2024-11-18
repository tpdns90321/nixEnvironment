{ pkgs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../k3sCluster
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # vnc
      5900
      # k3s API Server
      6443
      # kublet metric
      10250
      # drbd ports
      7789
      7790
      # NFS ports
      111
      2049
      4000
      4001
      4002
      20048
      # Zerotier
      9993
    ];
    allowedUDPPorts = [
      # k3s flannel
      8472
      # NFS ports
      111
      2049
      4000
      4001
      4002
      20048
      # Zerotier
      9993
    ];
    extraCommands = ''iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
iptables -t nat -A POSTROUTING -o jp+ -j MASQUERADE
iptables -t nat -A POSTROUTING -o br0 -j MASQUERADE
iptables -t nat -A OUTPUT -p tcp --dport 50443 -j DNAT --to-destination :443'';
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.mosh.enable = true;

  # Enable Zerotier
  services.zerotierone.enable = true;

  # Hardware acceleration
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      #vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      #vaapiVdpau
      #libvdpau-va-gl
    ];
  };
}
