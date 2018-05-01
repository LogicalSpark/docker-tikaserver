# Get latest ubuntu version
FROM ubuntu:latest

# Set runtime vars
ENV TIKA_VERSION 1.18
ENV TIKA_SERVER_URL https://www.apache.org/dist/tika/tika-server-$TIKA_VERSION.jar
ENV NEW_RELIC_URL https://download.newrelic.com/newrelic/java-agent/newrelic-agent/4.0.1/newrelic-agent-4.0.1.jar

# Download Tika Server jar
RUN	apt-get update \
    && apt-get install openjdk-8-jre-headless curl gdal-bin tesseract-ocr \
		tesseract-ocr-eng tesseract-ocr-ita tesseract-ocr-fra tesseract-ocr-spa tesseract-ocr-deu gnupg2 -y \
	&& curl -sSL https://people.apache.org/keys/group/tika.asc -o /tmp/tika.asc \
	&& gpg --import /tmp/tika.asc \
	&& curl -sSL "$TIKA_SERVER_URL.asc" -o /tmp/tika-server-${TIKA_VERSION}.jar.asc \
	&& NEAREST_TIKA_SERVER_URL=$(curl -sSL http://www.apache.org/dyn/closer.cgi/${TIKA_SERVER_URL#https://www.apache.org/dist/}\?asjson\=1 \
		| awk '/"path_info": / { pi=$2; }; /"preferred":/ { pref=$2; }; END { print pref " " pi; };' \
		| sed -r -e 's/^"//; s/",$//; s/" "//') \
	&& echo "Nearest mirror: $NEAREST_TIKA_SERVER_URL" \
	&& curl -sSL "$NEAREST_TIKA_SERVER_URL" -o /tika-server-${TIKA_VERSION}.jar \
	&& apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download New Relic jar
RUN echo "Downloading Newrelic jar" \
    && curl -sSL "$NEW_RELIC_URL" -o /newrelic.jar

# Run the image as a non-root user (mimic Heroku runtime)
RUN useradd -m myuser
USER myuser

# Run the app.  CMD is required to run on Heroku
# $PORT is set by Heroku
CMD java -javaagent:/newrelic.jar -jar /tika-server-${TIKA_VERSION}.jar -h $HEROKU_PRIVATE_IP -p $PRIVATE_PORT