{ config, pkgs, lib, ... }:
let VIP = "192.168.219.150"; in {
  sops.age.keyFile = "/etc/sops/age/keys.txt";
  sops.secrets.k3s_tokenfile = {
    sopsFile = ./tokenfile;
    format = "binary";
 };
 sops.secrets.wireguard_private_key = {
    sopsFile = ./wg_private_key;
    format = "binary";
  };

  systemd.services.k3s_server = {
    description = "k3s server service";
    after = [
      "network-online.target"
    ];
    wants = [
      "network-online.target"
    ];
    wantedBy = [ ];
    serviceConfig = {
      Type = "notify";
      KillMode = "process";
      Delegate = "yes";
      Restart = "always";
      RestartSec = "5s";
      LimitNOFILE = 1048576;
      LimitNPROC = "infinity";
      LimitCORE = "infinity";
      TasksMax = "infinity";
      ExecStart = "${pkgs.k3s}/bin/k3s server --disable traefik --disable servicelb --tls-san ${VIP} --token-file ${config.sops.secrets.k3s_tokenfile.path}";
    };
  };

  systemd.services.k3s_agent = {
    description = "k3s agent service";
    after = [
      "network-online.target"
    ];
    wants = [
      "network-online.target"
    ];
    wantedBy = [ ];
    serviceConfig = {
      Type = "exec";
      KillMode = "process";
      Delegate = "yes";
      Restart = "always";
      RestartSec = "5s";
      LimitNOFILE = 1048576;
      LimitNPROC = "infinity";
      LimitCORE = "infinity";
      TasksMax = "infinity";
      ExecStart = "${pkgs.k3s}/bin/k3s agent --server https://${VIP}:6443 --token-file ${config.sops.secrets.k3s_tokenfile.path}";
    };
  };

  networking.useNetworkd = true;

  systemd.network.netdevs."30-br0" = {
    enable = true;

    netdevConfig = {
      Name = "br0";
      Kind = "bridge";
    };

    bridgeConfig = {
      STP = true;
      ForwardDelaySec = 4;
      Priority = 2;
    };
  };

  systemd.network.networks."30-br0" = {
    enable = true;

    matchConfig = {
      Name = "br0";
    };

    networkConfig = {
      Address = if config.networking.hostName == "kang-stay-gmk" then "192.168.219.114/24" else "192.168.219.105/24";
      Gateway = "192.168.219.1";
    };

    linkConfig = {
      MTUBytes = "1500";
    };
  };

  networking.bridges.br0 = {
    interfaces = [
      (if config.networking.hostName == "kang-stay-gmk" then "enp3s0" else "enp34s0") # Replace with your network interface
      "ztfp6i26fp"
    ];
  };

  networking.wg-quick.interfaces.jp-tok = {
    privateKeyFile = config.sops.secrets.wireguard_private_key.path;
    listenPort = 51820;
    peers = [
      {
        publicKey = "YJSjrc/WWOjQUyUi4iYcHb7LsWWoCY+2fK8/8VtC/BY=";
        allowedIPs = [ "0.0.0.0/0" ];
        endpoint = "jp-tok.prod.surfshark.com:51820";
      }
    ];

    address = [ "10.14.0.2/16" ];
    postUp = with pkgs;
      let
        ip = "${iproute2}/bin/ip";
        iptables = "${pkgs.iptables}/bin/iptables";
        in ''
        ${ip} route add table 200 default via 192.168.219.1 dev br0
        ${ip} rule add fwmark 0x1 table 200

        ${iptables} -t mangle -A OUTPUT -s 192.168.219.150 -p tcp --sport 443 -j MARK --set-mark 1
        ${iptables} -t mangle -A OUTPUT -s 192.168.219.150 -p udp --sport 443 -j MARK --set-mark 1
        ${iptables} -t mangle -A OUTPUT -s 192.168.219.150 -p tcp --sport 80 -j MARK --set-mark 1
        ${iptables} -t mangle -A OUTPUT -p tcp --dport 50443 -j MARK --set-mark 1
        ${iptables} -t mangle -A PREROUTING -s 10.42.0.0/16 -p tcp --sport 443 -j MARK --set-mark 1
        ${iptables} -t mangle -A PREROUTING -s 10.42.0.0/16 -p udp --sport 443 -j MARK --set-mark 1
        ${iptables} -t mangle -A PREROUTING -s 10.42.0.0/16 -p tcp --sport 80 -j MARK --set-mark 1
        ${iptables} -t mangle -A PREROUTING -p tcp --dport 50443 -j MARK --set-mark 1
    '';
    postDown = with pkgs;
      let
        ip = "${iproute2}/bin/ip";
        iptables = "${pkgs.iptables}/bin/iptables";
        in ''
        ${ip} rule del fwmark 0x1 table 200
        ${ip} route flush table 200 default via

        ${iptables} -t mangle -D OUTPUT -s 192.168.219.150 -p tcp --sport 443 -j MARK --set-mark 1
        ${iptables} -t mangle -D OUTPUT -s 192.168.219.150 -p udp --sport 443 -j MARK --set-mark 1
        ${iptables} -t mangle -D OUTPUT -s 192.168.219.150 -p tcp --sport 80 -j MARK --set-mark 1
        ${iptables} -t mangle -D OUTPUT -p tcp --dport 50443 -j MARK --set-mark 1
        ${iptables} -t mangle -D PREROUTING -s 10.42.0.0/16 -p tcp --sport 443 -j MARK --set-mark 1
        ${iptables} -t mangle -D PREROUTING -s 10.42.0.0/16 -p udp --sport 443 -j MARK --set-mark 1
        ${iptables} -t mangle -D PREROUTING -s 10.42.0.0/16 -p tcp --sport 80 -j MARK --set-mark 1
        ${iptables} -t mangle -D PREROUTING -p tcp --dport 50443 -j MARK --set-mark 1
    '';
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
iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
iptables -t nat -A POSTROUTING -o jp+ -j MASQUERADE
iptables -t nat -A POSTROUTING -o br0 -j MASQUERADE
iptables -t nat -A OUTPUT -p tcp --dport 50443 -j DNAT --to-destination :443
iptables -t nat -A PREROUTING -p tcp --dport 50443 -j DNAT --to-destination :443
'';
    checkReversePath = false;
  };

  systemd.services.zerotierone.wantedBy = lib.mkForce [ ];

  environment.etc."keepalived_notify.sh" = {
    text = with pkgs; ''
#!${bash}/bin/bash

TYPE=$1
NAME=$2
STATE=$3

case $STATE in
    "MASTER")
        ${drbd}/bin/drbdadm connect --discard-my-data k3s_server_node
        ${drbd}/bin/drbdadm connect --discard-my-data k3s_nfs
        sleep 60
        ${drbd}/bin/drbdadm primary --force k3s_server_node
        ${drbd}/bin/drbdadm primary --force k3s_nfs
        # Mount DRBD device
        ${util-linux}/bin/mount /dev/drbd1 /var/lib/rancher/k3s/server
        ${util-linux}/bin/mount /dev/drbd2 /nfs
        # Start K3s server
        ${systemd}/bin/systemctl stop k3s_agent.service
        ${systemd}/bin/systemctl start k3s_server.service
        ${systemd}/bin/systemctl start nfs-server.service
        ${systemd}/bin/systemctl start zerotierone.service
        ;;
    "BACKUP"|"FAULT"|"STOP")
        kill $(${procps}/bin/ps -ef | ${gnugrep}/bin/grep MASTER | ${gawk}/bin/awk '{ print $2 }')
        # Stop K3s server
        ${systemd}/bin/systemctl stop nfs-server.service
        ${systemd}/bin/systemctl stop k3s_server.service
        ${systemd}/bin/systemctl stop zerotierone.service
        # Unmount DRBD device
        ${util-linux}/bin/umount /var/lib/rancher/k3s/server
        ${util-linux}/bin/umount /nfs
        ${drbd}/bin/drbdadm secondary k3s_server_node
        ${drbd}/bin/drbdadm secondary k3s_nfs
        sleep 60
        ${systemd}/bin/systemctl start k3s_agent.service
        ${drbd}/bin/drbdadm connect --discard-my-data k3s_server_node
        ${drbd}/bin/drbdadm connect --discard-my-data k3s_nfs
        ;;
    *)
        echo "Unknown state"
        exit 1
        ;;
esac
    '';
    mode = "0555";
  };

  services.keepalived = {
    enable = true;
    openFirewall = true;
    vrrpInstances = {
        K3S = {
        interface = "br0"; # Replace with your network interface
        state = if config.networking.hostName == "kang-stay-gmk" then "MASTER" else "BACKUP";
        virtualRouterId = 51;
        priority = if config.networking.hostName == "kang-stay-gmk" then 100 else 90;
        virtualIps = [{ addr = "${VIP}/24"; }]; # Virtual IP address
        extraConfig = ''
        notify "/etc/keepalived_notify.sh"
        '';
      };
    };
  };
}
