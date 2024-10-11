{ ... }:
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
  on kang-stay-nixos {
    device     /dev/drbd1;
    disk       /dev/nixos/k3s-server;
    address    192.168.219.105:7789;
    meta-disk  internal;
  }
}
'';
  };
}
