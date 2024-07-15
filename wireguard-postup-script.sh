#!/bin/bash

# Create separate routing table
ip route add table 200 default via 192.168.219.1 dev br0

# Set up IP rule
ip rule add fwmark 1 table 200

# Configure iptables
iptables -t mangle -A OUTPUT -s 192.168.219.200 -p tcp --sport 6443 -j MARK --set-mark 1
iptables -t mangle -A OUTPUT -s 192.168.219.200 -p udp --sport 6443 -j MARK --set-mark 1
iptables -t mangle -A OUTPUT -s 192.168.219.200 -p tcp --sport 6080 -j MARK --set-mark 1

# Configure PMTU
iptables -A ufw-after-forward -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
