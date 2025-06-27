#!/bin/sh

eth_internet="enX0"
bridge=br0

# Install modprobe for gingervm
modprobe nbd

brctl addbr "${bridge}"
ip addr add 192.168.42.1/24 dev br0
ip link set dev "${bridge}" up

tap=tap0
ip tuntap add mode tap name "${tap}"
ip link set dev "${tap}" up
brctl addif "${bridge}" "${tap}"

tap=tap1
ip tuntap add mode tap name "${tap}"
ip link set dev "${tap}" up
brctl addif "${bridge}" "${tap}"

tap=tap2
ip tuntap add mode tap name "${tap}"
ip link set dev "${tap}" up
brctl addif "${bridge}" "${tap}"

# probably need to enable IPv4 forwarding and NAT
echo 1 > /proc/sys/net/ipv4/ip_forward
/sbin/iptables -t nat -A POSTROUTING -o "${eth_internet}" -j MASQUERADE
/sbin/iptables -A FORWARD -i "${eth_internet}" -o "${bridge}" -m state --state RELATED,ESTABLISHED -j ACCEPT
/sbin/iptables -A FORWARD -i "${bridge}" -o "${eth_internet}" -j ACCEPT