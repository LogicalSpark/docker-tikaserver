# Content Processor

This is a fork of the [docker-tikaserver](https://github.com/LogicalSpark/docker-tikaserver/tree/1.18) repo with slight modifications to run in Heroku. Reference [documentation](https://devcenter.heroku.com/articles/container-registry-and-runtime) to see limitations of drunning a docker image in Heroku.
 * Run with non root user
 * CMD instead of entrypoint

## Local Usage

### Build Image
`docker build -t tika-server:latest .`

**Attributes:**

`--tag`, `-t` - tag the image (syntax: `name:version`)

### Run Image
`docker run -e PORT=9998 -i -t -p 9998:9998 tika-server:latest`

**Attributes:**

`--env`, `-e` - Set environment variables

`--interactive`, -i` - Keep STDIN open even if not attached

`--tty`, `-t` - Allocate a pseudo-TTY (pseudo terminal)

*note: need this to shut down server in with CMD+C if running in attached mode. to run in attached mode add the `--detach` or `-d` attrubute.

### Reference

[Run command options](https://docs.docker.com/edge/engine/reference/commandline/run/#options)

## Deploy to Heroku