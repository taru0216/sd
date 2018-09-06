FROM dockertips3_1

RUN apt-get update && apt-get install -y curl && apt-get clean
RUN curl -O http://ftp.yz.yamagata-u.ac.jp/pub/linux/centos-altarch/7/isos/i386/CentOS-7-i386-NetInstall-1804.iso
CMD ["-cdrom", "CentOS-7-i386-NetInstall-1804.iso"]
