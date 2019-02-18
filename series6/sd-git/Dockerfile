FROM ubuntu as builder

RUN sed -ie 's!deb http://archive.ubuntu.com/ubuntu/ bionic!deb mirror://mirrors.ubuntu.com/mirrors.txt bionic!' /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y git
RUN git clone https://github.com/git/git.git

WORKDIR /git

RUN apt-get install -y make gcc autoconf zlib1g-dev gettext libcurl4-gnutls-dev
RUN make configure
RUN ./configure
RUN make prefix=/opt/git -j$(getconf _NPROCESSORS_ONLN) all
RUN make prefix=/opt/git install

FROM ubuntu
COPY --from=builder /opt/git /opt/git
RUN apt-get update && apt-get install -y zlib1g libcurl4-gnutls-dev
WORKDIR /root
ENTRYPOINT ["/opt/git/bin/git"]
