FROM ubuntu as cache

RUN apt-get update && apt-get install -y curl
RUN mkdir /tmp/apache-hive
RUN curl http://ftp.jaist.ac.jp/pub/apache/hive/stable-2/apache-hive-2.3.3-bin.tar.gz | \
    tar zx -C /tmp/apache-hive

FROM ubuntu
COPY --from=cache /tmp/apache-hive /opt/apache-hive
