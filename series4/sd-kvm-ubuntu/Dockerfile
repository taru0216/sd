FROM dockertips3_1

RUN apt-get update && apt-get install -y curl && apt-get clean
RUN curl -O http://archive.ubuntu.com/ubuntu/dists/bionic/main/installer-i386/current/images/netboot/mini.iso
CMD ["-cdrom", "mini.iso"]
