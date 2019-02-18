FROM ubuntu as repo

ARG SD_OAUTHTOKEN

RUN sed -ie 's!deb http://archive.ubuntu.com/ubuntu/ bionic!deb mirror://mirrors.ubuntu.com/mirrors.txt bionic!' /etc/apt/sources.list
RUN apt-get update
RUN apt-get install -y git
RUN git clone https://$SD_OAUTHTOKEN:x-oauth-basic@github.com/RettyInc/hoge.git

FROM ubuntu
COPY --from=repo /hoge/ /hoge/
