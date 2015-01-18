FROM ubuntu:latest
MAINTAINER david@logicalspark.com

RUN apt-get update
RUN apt-get install openjdk-7-jre-headless wget -y
RUN wget -nv http://repo1.maven.org/maven2/org/apache/tika/tika-server/1.7/tika-server-1.7.jar -O /tika-server-1.7.jar
RUN apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /setup /build

EXPOSE 9998
ENTRYPOINT java -jar /tika-server-1.7.jar -h 0.0.0.0
