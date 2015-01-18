# docker-tikaserver
This repos contains the Dockerfile to create a docker image that contains the latest Ubuntu running copy of Apache Tika 1.7 Server on Port 9998 using Java 7.

## Usage

To run the container, execute the following command:

    docker run -d -p 9998:9998 docker-tikaserver

## Building

To build the image, simply invoke

    docker build -t 'docker-tikaserver' github.com/LogicalSpark/docker-tikaserver

## More

For more info on Apache Tika Server, go to the [Apache Tika Server documentation](http://wiki.apache.org/tika/TikaJAXRS).

## Author

  * David Meikle (<david@logicalspark.com>)
