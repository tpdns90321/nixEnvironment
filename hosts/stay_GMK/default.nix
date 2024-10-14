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
    ];
    allowedUDPPorts = [
      # k3s flannel
      8472
    ];
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.mosh.enable = true;

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
