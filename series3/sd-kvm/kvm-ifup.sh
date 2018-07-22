#!/bin/sh

set -e

# Debug
if test "x$DOCKERTIPS3_DEBUG" != "x"; then
  set -x
fi

DOCKERTIPS3_NETWORK_ADDRESS=${DOCKERTIPS3_NETWORK_ADDRESS:-192.168.254.0/24}
prefixlen=$(echo $DOCKERTIPS3_NETWORK_ADDRESS | cut -d/ -f2)

if test "x$prefixlen" = "x24"; then
  DOCKERTIPS3_HOST_ADDRESS=${DOCKERTIPS3_HOST_ADDRESS:-$(echo $DOCKERTIPS3_NETWORK_ADDRESS | cut -d. -f-3).254}
  DOCKERTIPS3_GUEST_ADDRESS=${DOCKERTIPS3_GUEST_ADDRESS:-$(echo $DOCKERTIPS3_NETWORK_ADDRESS | cut -d. -f-3).1}
else
  if test "x$DOCKERTIPS3_HOST_ADDRESS" = "x" || test "x$DOCKERTIPS3_GUEST_ADDRESS" = "x"; then
    echo "Unable to assign IP addresses automatically unless its prefix len is 24." 1>&2
    exit 1
  fi 
fi

###

# Activates the host tap interface.
ifconfig $1 $DOCKERTIPS3_HOST_ADDRESS/$(echo $DOCKERTIPS3_NETWORK_ADDRESS | cut -d/ -f2)

# Starts DHCP / DNS for the VM.
dnsmasq -i $1 --dhcp-range $DOCKERTIPS3_GUEST_ADDRESS,$DOCKERTIPS3_GUEST_ADDRESS


### ENGRESS PACKETS

# MASQUERADE for engress packets from the VM.
iptables -t nat -A POSTROUTING -s $DOCKERTIPS3_NETWORK_ADDRESS -j MASQUERADE


### INGRESS PACKETS

# VNC
if [ -s /ports ]; then
    . /ports
fi
for p in ${DOCKERTIPS3_HOST_PORTS}; do
    iptables -t nat -A PREROUTING -p tcp --dport $p -j ACCEPT
done

# DNAT
iptables -t nat -A PREROUTING ! -i $1 -j DNAT --to-destination $DOCKERTIPS3_GUEST_ADDRESS
