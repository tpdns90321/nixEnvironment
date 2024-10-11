{ config, pkgs, ... }:
let VIP = "192.168.219.150"; in {
  sops.age.keyFile = "/etc/sops/age/keys.txt";
  sops.secrets.k3s_tokenfile = {
    sopsFile = ./tokenfile;
    format = "binary";
  };

  services.k3s = {
    enable = true;
    role = "agent";
    tokenFile = config.sops.secrets.k3s_tokenfile.path;
    serverAddr = "https://${VIP}:6443";
  };

  systemd.services.k3s.after = [
    "firewall.service"
    "network-online.target"
    "keepalived.service"
  ];

  systemd.services.k3s_server = {
    enable = false;
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
      ExecStart = "${pkgs.k3s}/bin/k3s server --disable-agent --server https://${VIP}:6443 --token-file ${config.sops.secrets.k3s_tokenfile.path}";
    };
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
      virtualIps = [{ addr = "192.168.219.200/24"; }]; # Virtual IP address
      extraConfig = ''
      notify "bash ${./notify.sh}"
      '';
    };
  };
};
}
