{ config, pkgs, ... }:
{
  services.drbd = {
    enable = true;
    config = ''
global {
  usage-count yes;
}
common {
  protocol C;
}

resource k3s_server_node {
  on kang-stay-gmk {
    device     /dev/drbd1;
    disk       /dev/stay-gmk/k3s-server;
    address    192.168.219.114:7789;
    meta-disk  internal;
  }
  on kang-rpi4 {
    device     /dev/drbd1;
    disk       /dev/nixos/k3s-server;
    address    192.168.219.104:7789;
    meta-disk  internal;
  }
}

resource k3s_nfs {
  on kang-stay-gmk {
    device    /dev/drbd2;
    disk      /dev/stay-gmk/nfs;
    address   192.168.219.114:7790;
    meta-disk internal;
  }

  on kang-rpi4 {
    device    /dev/drbd2;
    disk      /dev/nixos/nfs;
    address   192.168.219.104:7790;
    meta-disk internal;
  }
}
'';
  };

  # Fix drbd service PATH issue
  systemd.services.drbd.path = with pkgs; [
      "${drbd}/bin:${drbd}/sbin:${coreutils}/bin:${util-linux}/bin:${systemd}/bin"
  ];
  systemd.services.drbd.serviceConfig = {
    Type = "oneshot";
    RemainAfterExit = "true";
    Restart = "on-failure";
    RestartSec = "5";
  };
  systemd.services.drbd.after = [
    "network-online.target"
  ];
  systemd.services.drbd.wants = [
    "network-online.target"
  ];
}
