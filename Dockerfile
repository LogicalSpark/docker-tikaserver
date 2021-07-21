FROM ubuntu:focal as base
RUN apt-get update

ENV TIKA_VERSION 2.0.0
ENV TIKA_SERVER_JAR tika-server-standard
MAINTAINER david@logicalspark.com

FROM base as dependencies

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install openjdk-14-jre-headless gdal-bin tesseract-ocr \
        tesseract-ocr-eng tesseract-ocr-ita tesseract-ocr-fra tesseract-ocr-spa tesseract-ocr-deu curl

RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y xfonts-utils fonts-freefont-ttf fonts-liberation ttf-mscorefonts-installer wget cabextract

FROM dependencies as fetch_tika

ENV NEAREST_TIKA_SERVER_URL="https://www.apache.org/dyn/closer.cgi/tika/${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar?filename=tika/${TIKA_VERSION}/${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar&action=download" \
    ARCHIVE_TIKA_SERVER_URL="https://archive.apache.org/dist/tika/${TIKA_VERSION}/${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar" \
    DEFAULT_TIKA_SERVER_ASC_URL="https://downloads.apache.org/tika/${TIKA_VERSION}/${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar.asc" \
    ARCHIVE_TIKA_SERVER_ASC_URL="https://archive.apache.org/dist/tika/${TIKA_VERSION}/${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar.asc" \
    TIKA_VERSION=$TIKA_VERSION

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install gnupg2 \
    && wget -t 10 --max-redirect 1 --retry-connrefused -qO- https://downloads.apache.org/tika/KEYS | gpg --import \
    && wget -t 10 --max-redirect 1 --retry-connrefused $NEAREST_TIKA_SERVER_URL -O /${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar || rm /${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar \
    && sh -c "[ -f /${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar ]" || wget $ARCHIVE_TIKA_SERVER_URL -O /${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar || rm /${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar \
    && sh -c "[ -f /${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar ]" || exit 1 \
    && wget -t 10 --max-redirect 1 --retry-connrefused $DEFAULT_TIKA_SERVER_ASC_URL -O /${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar.asc  || rm /${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar.asc \
    && sh -c "[ -f /${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar.asc ]" || wget $ARCHIVE_TIKA_SERVER_ASC_URL -O /${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar.asc || rm /${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar.asc \
    && sh -c "[ -f /${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar.asc ]" || exit 1 \
    && gpg --verify /${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar.asc /${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar

FROM dependencies as runtime
RUN apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV TIKA_VERSION=$TIKA_VERSION
COPY --from=fetch_tika /${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar /${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar

EXPOSE 9998
ENTRYPOINT [ "/bin/sh", "-c", "exec java -jar /${TIKA_SERVER_JAR}-${TIKA_VERSION}.jar -h 0.0.0.0 $0 $@"]
