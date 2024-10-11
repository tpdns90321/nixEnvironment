{ config, pkgs, ... }:
let VIP = "192.168.219.150"; in {
  sops.age.keyFile = "/etc/sops/age/keys.txt";
  sops.secrets.k3s_tokenfile = {
    sopsFile = ./tokenfile;
    format = "binary";
 };

  systemd.services.k3s_server = {
    description = "k3s server service";
    after = [
      "firewall.service"
      "network-online.target"
    ];
    wants = [
      "firewall.service"
      "network-online.target"
    ];
    wantedBy = [ "multi-user.target" ];
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
      ExecStart = "${pkgs.k3s}/bin/k3s server --tls-san ${VIP} --token-file ${config.sops.secrets.k3s_tokenfile.path}";
    };
  };

  systemd.services.k3s_agent = {
    description = "k3s agent service";
    after = [
      "firewall.service"
      "network-online.target"
    ];
    wants = [
      "firewall.service"
      "network-online.target"
    ];
    wantedBy = [ "multi-user.target" ];
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

  environment.etc."keepalived_notify.sh" = {
    text = with pkgs; ''
#!${bash}/bin/bash

TYPE=$1
NAME=$2
STATE=$3

case $STATE in
    "MASTER")
        ${systemd}/bin/systemctl stop k3s_agent.service
        ${drbd}/bin/drbdadm primary --force k3s_server_node
        # Mount DRBD device
        ${util-linux}/bin/mount /dev/drbd1 /var/lib/rancher/k3s/server
        # Start K3s server
        ${systemd}/bin/systemctl start k3s-server.service
        ;;
    "BACKUP"|"FAULT"|"STOP")
        ${systemd}/bin/systemctl stop k3s-server.service
        # Unmount DRBD device
        ${util-linux}/bin/umount /var/lib/rancher/k3s/server
        # Stop K3s server
        ${drbd}/bin/drbdadm secondary k3s_server_node
        ${systemd}/bin/systemctl start k3s_agent.service
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
        interface = if config.networking.hostName == "kang-stay-gmk" then "enp3s0" else "enp34s0"; # Replace with your network interface
        state = if config.networking.hostName == "kang-stay-gmk" then "MASTER" else "BACKUP";
        virtualRouterId = 51;
        priority = if config.networking.hostName == "kang-stay-gmk" then 100 else 90;
        virtualIps = [{ addr = "192.168.219.150/32"; }]; # Virtual IP address
        extraConfig = ''
        notify "/etc/keepalived_notify.sh"
        '';
      };
    };
  };
}
