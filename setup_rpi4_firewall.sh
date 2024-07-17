#!/bin/bash

mkdir -p ~/.local/share/containers/storage/networks || true
mkdir -p ~/.config/caddy_data || true
mkdir -p ~/.config/adguardhome/{conf,work} || true
mkdir -p ~/.config/transmission || true

PORTS="6053:53/tcp 6053:53/udp 6080:80/tcp 6443:443/tcp 6443:443/udp 9000:3000/tcp 6853:853/tcp 6784:784/udp 6853:853/udp 14853:8853/udp 11443:5443/tcp 6445:445/tcp 9091:9091/tcp 51413:51413/tcp 51413:51413/udp"

echo '*nat' | sudo tee -a /etc/ufw/before.rules
echo '-A OUTPUT -p tcp --dport 6443 -j DNAT --to-destination :443' | sudo tee -a /etc/ufw/before.rules
echo '-A POSTROUNTING -o jp+ -j MASQUERADE' | sudo tee -a /etc/ufw/before.rules
echo '-A POSTROUNTING -o br0 -j MASQUERADE' | sudo tee -a /etc/ufw/before.rules
for PORT in $PORTS; do
  echo $PORT
  PARSED=($(echo $PORT | sed 's/[\/:]/ /g'))
  IN=${PARSED[0]}
  OUT=${PARSED[1]}
  TYPE=${PARSED[2]}
  sudo ufw allow ${IN}/${TYPE}
  echo "-A PREROUTING -p ${TYPE} --dport ${OUT} -d 192.168.219.200 -j REDIRECT --to-port ${IN}" | sudo tee -a /etc/ufw/before.rules
done

# allow mosh
sudo ufw allow 60000:61000/udp
sudo ufw allow 9993:9993/tcp

echo 'COMMIT' | sudo tee -a /etc/ufw/before.rules
