#!/bin/bash

# Remove IP rule
ip rule del fwmark 1 table 200

# Remove routing table
ip route flush table 200

# Remove iptables rules
iptables -t mangle -D OUTPUT -s 192.168.219.200 -p tcp --sport 6443 -j MARK --set-mark 1
iptables -t mangle -D OUTPUT -s 192.168.219.200 -p udp --sport 6443 -j MARK --set-mark 1
iptables -t mangle -D OUTPUT -s 192.168.219.200 -p tcp --sport 6080 -j MARK --set-mark 1
iptables -t mangle -D OUTPUT -p tcp --dport 6443 -j MARK --set-mark 1

# Remove PMTU
iptables -D ufw-after-forward -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
