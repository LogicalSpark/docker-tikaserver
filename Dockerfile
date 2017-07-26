FROM ubuntu:latest
MAINTAINER david@logicalspark.com

ENV TIKA_VERSION 1.16
ENV TIKA_SERVER_URL https://www.apache.org/dist/tika/tika-server-$TIKA_VERSION.jar

RUN echo "deb http://archive.ubuntu.com/ubuntu/ xenial multiverse" > /etc/apt/sources.list.d/multiverse.list \
  && echo "deb http://archive.ubuntu.com/ubuntu/ xenial-updates multiverse" >> /etc/apt/sources.list.d/multiverse.list \
  && echo "deb http://archive.ubuntu.com/ubuntu/ xenial-security multiverse" >> /etc/apt/sources.list.d/multiverse.list

RUN	apt-get update \
  && apt-get install apt-transport-https wget curl cabextract xfonts-utils -y \
  && curl http://http.us.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.6_all.deb \
  -o /tmp/ttf-mscorefonts-installer_3.6_all.deb \
  && dpkg -i /tmp/ttf-mscorefonts-installer_3.6_all.deb \
  && apt-get install fonts-freefont-ttf fonts-liberation -y \
	&& apt-get install openjdk-8-jre-headless gdal-bin tesseract-ocr \
		tesseract-ocr-eng tesseract-ocr-ita tesseract-ocr-fra tesseract-ocr-spa tesseract-ocr-deu -y \
	&& curl -sSL https://people.apache.org/keys/group/tika.asc -o /tmp/tika.asc \
	&& gpg --import /tmp/tika.asc \
	&& curl -sSL "$TIKA_SERVER_URL.asc" -o /tmp/tika-server-${TIKA_VERSION}.jar.asc \
	&& NEAREST_TIKA_SERVER_URL=$(curl -sSL http://www.apache.org/dyn/closer.cgi/${TIKA_SERVER_URL#https://www.apache.org/dist/}\?asjson\=1 \
		| awk '/"path_info": / { pi=$2; }; /"preferred":/ { pref=$2; }; END { print pref " " pi; };' \
		| sed -r -e 's/^"//; s/",$//; s/" "//') \
	&& echo "Nearest mirror: $NEAREST_TIKA_SERVER_URL" \
	&& curl -sSL "$NEAREST_TIKA_SERVER_URL" -o /tika-server-${TIKA_VERSION}.jar \
	&& apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 9998
ENTRYPOINT java -jar /tika-server-${TIKA_VERSION}.jar -h 0.0.0.0
