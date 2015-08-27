#!/bin/bash


iptables -t nat -A PREROUTING  ! -d  192.168.0.1 -p tcp --dport 80 -i eth0.1  -m state --state NEW -j REDIRECT --to-port 3126

iptables -P  FORWARD DROP

ipset -N white_list ipmap --network 192.168.0.0/16
iptables -A FORWARD  -p udp --dport 53 -m state --state NEW -j ACCEPT

iptables -A FORWARD  -i eth0.1 -o ppp0 -m set --match-set  white_list src -j ACCEPT
iptables -A FORWARD  -p icmp --icmp-type 8 -j ACCEPT
iptables -A FORWARD  -p tcp --dport 443 --syn -m state --state NEW -j ACCEPT
iptables -A FORWARD  -p tcp --dport 21 --syn -m state --state NEW -j ACCEPT
iptables -A FORWARD  -m state --state ESTABLISHED,RELATED -j ACCEPT
