FROM ubuntu:latest
MAINTAINER david@logicalspark.com

ENV TIKA_VERSION 2.0-SNAPSHOT
ENV TIKA_SERVER_URL https://repository.apache.org/service/local/artifact/maven/redirect?r=snapshots&g=org.apache.tika&a=tika-server&v=${TIKA_VERSION}

RUN	apt-get update \
	&& apt-get install openjdk-8-jre-headless curl gdal-bin tesseract-ocr \
		tesseract-ocr-eng tesseract-ocr-ita tesseract-ocr-fra tesseract-ocr-spa tesseract-ocr-deu -y \
	&& curl -sSL "$TIKA_SERVER_URL" -o /tika-server-${TIKA_VERSION}.jar \
	&& apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 9998
ENTRYPOINT java -jar /tika-server-${TIKA_VERSION}.jar -h 0.0.0.0
