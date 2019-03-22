FROM ubuntu

RUN \
  sed -ie 's!deb http://archive.ubuntu.com/ubuntu/ bionic!deb mirror://mirrors.ubuntu.com/mirrors.txt bionic!' /etc/apt/sources.list && \
  apt-get update && apt-get install -y wget gnupg && \
  sh -c "echo 'deb http://download.opensuse.org/repositories/home:/cabelo/xUbuntu_18.04/ /' > /etc/apt/sources.list.d/home:cabelo.list" && \
  wget -nv https://download.opensuse.org/repositories/home:cabelo/xUbuntu_18.04/Release.key -O Release.key && \
  apt-key add - < Release.key && \
  apt-get update && \
  apt-get install -y owasp-zap xvfb curl iputils-ping python-pip && \
  pip install --upgrade zapcli

COPY ./tests /tests

CMD ["run-parts", "--verbose", "--exit-on-error", "/tests"]
