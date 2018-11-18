FROM ubuntu:bionic

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LC_ALL=en_US.UTF-8

RUN \
    sed -ie 's!deb http://archive.ubuntu.com/ubuntu/ bionic!deb mirror://mirrors.ubuntu.com/mirrors.txt bionic!' /etc/apt/sources.list && \
    apt-get update

RUN apt-get install -y tomcat8
