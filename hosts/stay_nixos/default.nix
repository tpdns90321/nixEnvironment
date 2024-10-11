{ pkgs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../k3sCluster/drbd.nix
  ];

  sops.age.keyFile = "/etc/sops/age/keys.txt";
  sops.secrets.smb_credential = {
    sopsFile = ../../smb_credential.txt;
    format = "binary";
  };

  sops.secrets.k3s_tokenfile = {
    sopsFile = ../../k3sCluster/tokenfile;
    format = "binary";
  };

  fileSystems."/mnt/share" = {
    device = "//192.168.219.200/pi";
    fsType = "cifs";
    options =
      let
        options = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
        uid = "1000";
        gid = "100";
        in ["${options},credentials=${config.sops.secrets.smb_credential.path},uid=${uid},gid=${gid}"];
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      5900
      # k3s ports api-server
      6443
    ];
    allowedUDPPorts = [
      # k3s ports flannel
      8472
    ];
  };

  services.k3s = {
    enable = true;
    role = "agent";
    tokenFile = config.sops.secrets.k3s_tokenfile.path;
    serverAddr = "https://192.168.219.114:6443";
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.extraConfig = ''
    usePAM yes
  '';
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
