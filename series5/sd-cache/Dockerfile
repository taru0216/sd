FROM ubuntu

RUN apt-get update && apt-get install -y curl
RUN curl -O http://ftp.jaist.ac.jp/pub/apache/hive/stable-2/apache-hive-2.3.3-bin.tar.gz
RUN mkdir /tmp/apache-hive
RUN tar zxf /apache-hive-2.3.3-bin.tar.gz -C /tmp/apache-hive
