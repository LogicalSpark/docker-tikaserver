FROM ubuntu:focal as base
RUN apt-get update

ENV TIKA_VERSION 1.24.1
MAINTAINER david@logicalspark.com

FROM base as dependencies

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install openjdk-14-jre-headless gdal-bin tesseract-ocr \
        tesseract-ocr-eng tesseract-ocr-ita tesseract-ocr-fra tesseract-ocr-spa tesseract-ocr-deu

RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y xfonts-utils fonts-freefont-ttf fonts-liberation ttf-mscorefonts-installer wget cabextract

FROM dependencies as fetch_tika

ENV NEAREST_TIKA_SERVER_URL="https://www.apache.org/dyn/closer.cgi/tika/tika-server-${TIKA_VERSION}.jar?filename=tika/tika-server-${TIKA_VERSION}.jar&action=download" \
    ARCHIVE_TIKA_SERVER_URL="https://archive.apache.org/dist/tika/tika-server-${TIKA_VERSION}.jar" \
    DEFAULT_TIKA_SERVER_ASC_URL="https://downloads.apache.org/tika/tika-server-${TIKA_VERSION}.jar.asc" \
    ARCHIVE_TIKA_SERVER_ASC_URL="https://archive.apache.org/dist/tika/tika-server-${TIKA_VERSION}.jar.asc" \
    TIKA_VERSION=$TIKA_VERSION

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install gnupg2 \
    && wget -t 10 --max-redirect 1 --retry-connrefused -qO- https://downloads.apache.org/tika/KEYS | gpg --import \
    && wget -t 10 --max-redirect 1 --retry-connrefused $NEAREST_TIKA_SERVER_URL -O /tika-server-${TIKA_VERSION}.jar || rm /tika-server-${TIKA_VERSION}.jar \
    && sh -c "[ -f /tika-server-${TIKA_VERSION}.jar ]" || wget $ARCHIVE_TIKA_SERVER_URL -O /tika-server-${TIKA_VERSION}.jar || rm /tika-server-${TIKA_VERSION}.jar \
    && sh -c "[ -f /tika-server-${TIKA_VERSION}.jar ]" || exit 1 \
    && wget -t 10 --max-redirect 1 --retry-connrefused $DEFAULT_TIKA_SERVER_ASC_URL -O /tika-server-${TIKA_VERSION}.jar.asc  || rm /tika-server-${TIKA_VERSION}.jar.asc \
    && sh -c "[ -f /tika-server-${TIKA_VERSION}.jar.asc ]" || wget $ARCHIVE_TIKA_SERVER_ASC_URL -O /tika-server-${TIKA_VERSION}.jar.asc || rm /tika-server-${TIKA_VERSION}.jar.asc \
    && sh -c "[ -f /tika-server-${TIKA_VERSION}.jar.asc ]" || exit 1 \
    && gpg --verify /tika-server-${TIKA_VERSION}.jar.asc /tika-server-${TIKA_VERSION}.jar

FROM dependencies as runtime
RUN apt-get -y install curl && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV TIKA_VERSION=$TIKA_VERSION
COPY --from=fetch_tika /tika-server-${TIKA_VERSION}.jar /tika-server-${TIKA_VERSION}.jar

EXPOSE 9998
ENTRYPOINT java -jar /tika-server-${TIKA_VERSION}.jar -h 0.0.0.0
