# Content Processor

This is a fork of the [docker-tikaserver](https://github.com/LogicalSpark/docker-tikaserver/tree/1.18) repo with slight modifications to run in Heroku. Reference [documentation](https://devcenter.heroku.com/articles/container-registry-and-runtime) to see limitations of drunning a docker image in Heroku.
 * Run with non root user
 * CMD instead of entrypoint

## Local Usage

### Build Image
`docker build -t tika-server:latest .`

**Attributes:**

`--tag`, `-t` - tag the image (syntax: `name:version`)

### Run Image in Container
`docker run -e PRIVATE_PORT=9998 -i -t -p 9998:9998 --name content-processor tika-server:latest`

**Attributes:**

`--env`, `-e` - Set environment variables

`--interactive`, `-i` - Keep STDIN open even if not attached

`--tty`, `-t` - Allocate a pseudo-TTY (pseudo terminal)

`--name` - give name to container

***Note:** To run in attached mode add the `--detach` or `-d` attrubute.

### Stop Container

If running in deatached mode:

`docker stop content-processor`

otherwise:

`CMD+C` or `CTRL+C`

### Reference

[Run command options](https://docs.docker.com/edge/engine/reference/commandline/run/#options)

## Deploy to Heroku