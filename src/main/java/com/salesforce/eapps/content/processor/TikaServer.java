package com.salesforce.eapps.content.processor;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.apache.tika.detect.DefaultDetector;
import org.apache.tika.detect.Detector;
import org.apache.tika.exception.TikaException;
import org.apache.tika.metadata.Metadata;
import org.apache.tika.parser.AutoDetectParser;
import org.apache.tika.sax.BodyContentHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;
import org.xml.sax.ContentHandler;
import org.xml.sax.SAXException;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

@SpringBootApplication
@RestController
public class TikaServer {

    private static final Logger log = LoggerFactory.getLogger(TikaServer.class);

    private final AutoDetectParser parser;

    public TikaServer() {
        Detector detector = new DefaultDetector();
        parser = new AutoDetectParser(detector);
    }

    public static void main(String[] args) {
        SpringApplication.run(TikaServer.class, args);
    }

    @PutMapping("/{filename}")
    public ParseResponse parse(@PathVariable("filename") String filename, @RequestBody byte[] bytes) throws TikaException, SAXException, IOException {
        log.debug("Processing '{}' with length {}", filename, bytes.length);

        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        ContentHandler handler = new BodyContentHandler(byteArrayOutputStream);
        Metadata metadata = new Metadata();

        parser.parse(new ByteArrayInputStream(bytes), handler, metadata);

        String body = byteArrayOutputStream.toString();
        Map<String, String> metadataMap = Arrays.stream(metadata.names())
                .collect(Collectors.toMap(Function.identity(), metadata::get));

        return new ParseResponse(body, metadataMap);
    }

    private static class ParseResponse {
        @JsonProperty
        private final Map<String, String> metadata;
        @JsonProperty
        private final String body;

        private ParseResponse(String body, Map<String, String> metadata) {
            this.metadata = metadata;
            this.body = body;
        }
    }
}
