FROM ubuntu:latest
MAINTAINER david@logicalspark.com

ENV TIKA_VERSION 1.7

RUN apt-get update
RUN apt-get install openjdk-7-jre-headless curl gdal-bin tesseract-ocr \
    tesseract-ocr-eng tesseract-ocr-ita tesseract-ocr-fra tesseract-ocr-spa tesseract-ocr-deu -y

RUN curl -sSL https://people.apache.org/keys/group/tika.asc -o /tmp/tika.asc \
    && gpg --import /tmp/tika.asc

ENV TIKA_SERVER_URL https://www.apache.org/dist/tika/tika-server-$TIKA_VERSION.jar

RUN NEAREST_TIKA_SERVER_URL=$(curl -sSL http://www.apache.org/dyn/closer.cgi/${TIKA_SERVER_URL#https://www.apache.org/dist/}\?asjson\=1 \
		| awk '/"path_info": / { pi=$2; }; /"preferred":/ { pref=$2; }; END { print pref " " pi; };' \
		| sed -r -e 's/^"//; s/",$//; s/" "//') \
	&& echo "Nearest mirror: $NEAREST_TIKA_SERVER_URL" \
	&& curl -sSL "$NEAREST_TIKA_SERVER_URL" -o /tmp/tika-server-${TIKA_VERSION}.jar \
	&& curl -sSL "$TIKA_SERVER_URL.asc" -o /tmp/tika-server-${TIKA_VERSION}.jar.asc
	
RUN gpg --verify /tmp/tika-server-${TIKA_VERSION}.jar.asc
RUN mv /tmp/tika-server-${TIKA_VERSION}.jar /tika-server-${TIKA_VERSION}.jar

RUN apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /setup /build

EXPOSE 9998
ENTRYPOINT java -jar /tika-server-${TIKA_VERSION}.jar -h 0.0.0.0
