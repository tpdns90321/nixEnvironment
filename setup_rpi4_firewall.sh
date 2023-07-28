#!/bin/bash

mkdir -p ~/.local/share/containers/storage/networks/podman.json || true
mkdir -p ~/.config/caddy_data || true
mkdir -p ~/.config/adguardhome/{conf,work} || true

PORTS="6053:53/tcp 6053:53/udp 6080:80/tcp 6443:443/tcp 6443:443/udp 9000:3000/tcp 6853:853/tcp 6784:784/udp 6853:853/udp 14853:8853/udp 11443:5443/tcp 6445:445/tcp"

echo '*nat' | sudo tee -a /etc/ufw/before.rules
for PORT in $PORTS; do
  echo $PORT
  PARSED=($(echo $PORT | sed 's/[\/:]/ /g'))
  IN=${PARSED[0]}
  OUT=${PARSED[1]}
  TYPE=${PARSED[2]}
  sudo ufw allow ${IN}/${TYPE}
  echo "-A PREROUTING -p ${TYPE} --dport ${OUT} -j REDIRECT --to-port ${IN} -s 192.168.50.0/24" | sudo tee -a /etc/ufw/before.rules
  echo "-A PREROUTING -p ${TYPE} --dport ${OUT} -j REDIRECT --to-port ${IN} -s 10.8.0.0/24" | sudo tee -a /etc/ufw/before.rules
done

echo 'COMMIT' | sudo tee -a /etc/ufw/before.rules
