{ pkgs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  sops.age.keyFile = "/etc/sops/age/keys.txt";

  sops.secrets.k3s_tokenfile = {
    sopsFile = ../../k3sCluster/tokenfile;
    format = "binary";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # vnc
      5900
      # k3s API Server
      6443
      # kublet metric
      10250
    ];
    allowedUDPPorts = [
      # k3s flannel
      8472
    ];
  };

  # k3s
  services.k3s = {
    enable = true;
    role = "server";
    tokenFile = config.sops.secrets.k3s_tokenfile.path;
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
