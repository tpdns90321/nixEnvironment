#!/bin/bash

TYPE=$1
NAME=$2
STATE=$3

case $STATE in
    "MASTER")
        drbdadm primary --force k3s_server_node
        # Mount DRBD device
        mount /dev/drbd1 /var/lib/rancher/k3s/server
        # Start K3s server
        systemctl start k3s-server.service
        ;;
    "BACKUP"|"FAULT")
        drbdadm secondary k3s_server_node
        # Stop K3s server
        systemctl stop k3s-server.service
        # Unmount DRBD device
        umount /var/lib/rancher/k3s/server
        ;;
    *)
        echo "Unknown state"
        exit 1
        ;;
esac
