ARG TIKA_VERSION=1.23

FROM ubuntu:latest as apt_base

RUN apt-get update

FROM apt_base as fetch_fonts

RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y curl xfonts-utils fonts-freefont-ttf fonts-liberation ttf-mscorefonts-installer wget cabextract

FROM apt_base as runtime_deps

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install openjdk-11-jre-headless gdal-bin tesseract-ocr \
        tesseract-ocr-eng tesseract-ocr-ita tesseract-ocr-fra tesseract-ocr-spa tesseract-ocr-deu

FROM runtime_deps as fetch_tika

ARG TIKA_VERSION

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install gnupg curl jq \
    && curl -sSL https://www.apache.org/dist/tika/KEYS | gpg --import \
    && curl -sSL https://www.apache.org/dist/tika/tika-server-${TIKA_VERSION}.jar.asc -o /tika-server-${TIKA_VERSION}.jar.asc \
    && NEAREST_TIKA_SERVER_URL=$(curl --fail -sSL https://www.apache.org/dyn/closer.cgi/tika/tika-server-${TIKA_VERSION}.jar?asjson=1 | jq --raw-output '.preferred + .path_info') \
    && echo "Nearest mirror: $NEAREST_TIKA_SERVER_URL" \
    && curl -sSL $NEAREST_TIKA_SERVER_URL -o /tika-server-${TIKA_VERSION}.jar \
    && gpg --verify /tika-server-${TIKA_VERSION}.jar.asc /tika-server-${TIKA_VERSION}.jar

FROM runtime_deps as runtime

RUN apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG TIKA_VERSION
ENV TIKA_VERSION=$TIKA_VERSION

COPY --from=fetch_fonts /usr/share/fonts /usr/share/fonts
COPY --from=fetch_tika /tika-server-${TIKA_VERSION}.jar /tika-server-${TIKA_VERSION}.jar

EXPOSE 9998
ENTRYPOINT java -jar /tika-server-${TIKA_VERSION}.jar -h 0.0.0.0

LABEL maintainer david@logicalspark.com