{ ... }:
{
  services.nfs.server = {
    enable = true;
    exports = ''
/nfs  192.168.219.114(rw,insecure,no_root_squash) 192.168.219.104(rw,insecure,no_root_squash) 192.168.219.2(rw,insecure,no_root_squash) 192.168.219.5(rw,insecure,no_root_squash)
'';
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
  };
}
