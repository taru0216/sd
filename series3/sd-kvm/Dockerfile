FROM ubuntu

RUN \
  apt-get update && \
  apt-get install -y qemu-kvm && \
  apt-get install -y net-tools dnsmasq iptables && \
  apt-get clean

ADD entrypoint.sh kvm-ifup.sh kvm-ifdown.sh /

EXPOSE 5900 5901

ENTRYPOINT ["/entrypoint.sh", "-boot", "menu=on"]
