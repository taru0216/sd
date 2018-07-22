#!/bin/sh
#
# Copyright 2018 Masato Taruishi <taru@retty.me>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software
# and associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial
# portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

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
