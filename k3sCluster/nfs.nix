{ ... }:
{
  services.nfs.server = {
    enable = true;
    exports = ''
/nfs  192.168.219.0/24(rw,insecure,no_root_squash)
'';
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
  };
}
