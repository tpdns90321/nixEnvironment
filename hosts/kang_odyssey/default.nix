{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  sops.age.keyFile = "/etc/sops/age/keys.txt";

  sops.secrets.wpa_supplicant_secret = {
    sopsFile = ./wpa_supplicant_secret;
    format = "binary";
  };
  sops.secrets.wg_conf_secret = {
    sopsFile = ./wg_conf_secret;
    format = "binary";
  };
  sops.secrets.k3s_token_secret = {
    sopsFile = ./k3s_token_secret;
    format = "binary";
  };

  security.pam.enableFscrypt = true;
  services.openssh.enable = true;
  services.openssh.settings.KbdInteractiveAuthentication = false;
  services.resolved.extraConfig = ''
DNSStubListenerExtra=192.168.172.1
'';
  services.k3s = {
    enable = true;
    tokenFile = config.sops.secrets.k3s_token_secret.path;
    role = "agent";
    serverAddr = "https://192.168.219.150:6443";
    extraFlags = "--node-external-ip=192.168.1.123";
  };

  programs.mosh.enable = true;

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
  };

  networking.useNetworkd = true;
  networking.useDHCP = false;
  networking.hostName = "kang-odyssey";
  networking.nameservers = [ "192.168.219.150" ];
  networking.bridges.br-internal.interfaces = [ "enp2s0" "enp3s0" ];

  networking.wireless.enable = true;
  networking.wireless.secretsFile = config.sops.secrets.wpa_supplicant_secret.path;
  networking.wireless.networks = {
    kang_5G.pskRaw = "ext:psk_kang";
  };

  networking.wg-quick.interfaces.wg-vxlan = {
    configFile = config.sops.secrets.wg_conf_secret.path;
  };

  systemd.network.networks."20-wlo" = {
    enable = true;

    matchConfig = {
      Name = "wlo2";
    };

    networkConfig = {
      DHCP = "ipv4";
      IPv4Forwarding = true;
      DNSDefaultRoute = false;
    };

    dhcpV4Config = { UseDNS = false;  };
    dhcpV6Config = { UseDNS = false;  };
  };

  systemd.network.networks."20-br-internal" = {
    enable = true;

    matchConfig = {
      Name = "br-internal";
    };

    networkConfig = {
      Address = "192.168.172.1/24";
      DHCPServer = true;
      IPv4Forwarding = true;
    };

    dhcpServerConfig = {
      DNS = "192.168.172.1";
    };

    linkConfig = {
      RequiredForOnline = "no";
    };
  };

  systemd.services.k3s-exclude-routing = {
    description = "Disable some PREROUTING chain in k3s";
    after = [
      "k3s.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      Environment = "PATH=${pkgs.iptables}/bin/";
      ExecStart = ''${pkgs.busybox}/bin/sh -c "sleep 60 && \
      iptables -t nat -I PREROUTING 1 -i br-internal -j RETURN && \
      iptables -I FORWARD 1 -i br-internal -j RETURN"'';
    };
    wantedBy = [ "multi-user.target" ];
  };

  networking.firewall = {
    allowedUDPPorts = [ 67 68 53 ];
  };
}
