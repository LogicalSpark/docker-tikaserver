# Content Processor

This is a fork of the [docker-tikaserver](https://github.com/LogicalSpark/docker-tikaserver/tree/1.18) repo with slight modifications to run in Heroku. Reference [documentation](https://devcenter.heroku.com/articles/container-registry-and-runtime) to see limitations of drunning a docker image in Heroku.
 * Run with non root user
 * CMD instead of entrypoint

## Local Usage

### Build Image
`docker build -t tika-server:latest .`

**Attributes:**

`--tag`, `-t` - tag the image (syntax: `name:version`)

### First time run of image inside container
`docker run -e HEROKU_PRIVATE_IP=0.0.0.0 -e PRIVATE_PORT=9998 -i -t -p 9998:9998 --name content-processor tika-server:latest`

**Attributes:**

[Run command options](https://docs.docker.com/edge/engine/reference/commandline/run/#options)

`--env`, `-e` - Set environment variables
   * `HEROKU_PRIVATE_IP` - Heroku private IP of the dyno (used for [DNS Service discovery](https://devcenter.heroku.com/articles/dyno-dns-service-discovery))
   * `PRIVATE_PORT` - Private port to bind too. Needs to be between `1024` and `65535`

`--interactive`, `-i` - Keep STDIN open even if not attached

`--tty`, `-t` - Allocate a pseudo-TTY (pseudo terminal)

`--port`, `-p` - Port to publush to your host machine. Needs to match `PRIVATE_PORT` env var.

`--name` - give name to container

***Note:** To run in attached mode add the `--detach` or `-d` attrubute.

### Rebuild image

delete docker container:

`docker rm content-processor`

build image from the command above and do the initial run command.

### Start Container

Subsequent starts:

`docker start content-processor`

### Stop Container

If running in deatached mode:

`docker stop content-processor`

otherwise:

`CMD+C` or `CTRL+C`

### Clean up local Images

Everytime an image is built, and rebuild. The old image lingers around. Clean them by:

`docker image prune`


## Deploy to Heroku