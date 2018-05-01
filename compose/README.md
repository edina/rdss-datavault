# Docker-Compose Services

## Service Sets

There are currently two service sets defined:

1. [qa](qa), which defines the main Datavault services.
1. [dev](dev), which extends `qa` to build the images from local files, rather than expecting to pull existing images.

These service sets are defined by the following `docker-compose` configuration files:

1. [docker-compose.qa.yml](docker-compose.qa.yml)
1. [docker-compose.dev.yml](docker-compose.dev.yml)

In general it is recommended to use the `make` commands rather than call `docker-compose` directly for building, as there are a number of additional tasks that need to be done other than `docker-compose build`.

## Building

The Docker Compose build has two modes: `dev` and `qa`.

The `qa` mode will attempt to use pre-built images available from a given registry. The `dev` mode does not require a registry, and instead builds each of the images itself. This takes longer, but can be useful if making changes as part of development.

The `qa` build is the default as this is the quickest and the one used by our default deployment.

To run the images, use `make up`.

## Initial configuration

Some Datavault configuration is stored in the database.
To setup the initial database, you can run the `./configure-storage.sh` script.
The script should display the contents of the `ArchiveStores` table.
If it displays nothing, or an error, then something has went wrong (most likely database initialisation).

### Other Commands

Here are some other `make` commands other that may be useful when working with these`docker-compose` configurations.

| Command | Description |
|---|---|
| `make list` | List all running containers (using `docker-compose ps`) |
| `make watch` | Watch logs from all containers |
| `make destroy` | Tear down all running containers for the configured compose set. |
| `make help` | List all commands |

## Volumes

The `docker-compose.yml` file will use volumes for persisting data between runs.
If you need to reset them, you can use `make destroy` to destroy all containers and all volumes.

*NOTE*: At present, bringing down the `broker` container will delete the contents of the database.

### Development Build

The `dev` mode builds each of the images itself. This takes longer, but can be useful if making changes as part of development.
To build the containers, use

	make build ENV=dev

You can then use `make up` to bring up the containers.

This will create all the services defined in [docker-compose.qa.yml](docker-compose.qa.yml). With `ENV=dev` specified, the docker images will be built by `docker-compose`, rather than expecting the images to exist already.

### Using docker-compose directly

You can use `docker-compose` directly to execute commands.
However, doing so successfully requires a number of environment variables to be set, which the `Makefile` normally does for you:

* REGISTRY
* COMPOSE_PROJECT_NAME
* COMPOSE_FILE

See the start of `Makefile` for an idea of values, then export these variables, e.g.:

        export COMPOSE_PROJECT_NAME=rdssdatavault REGISTRY=400079346860.dkr.ecr.eu-west-1.amazonaws.com COMPOSE_FILE=docker-compose.qa.yml

You can change the [COMPOSE_FILE](https://docs.docker.com/compose/reference/envvars/) environment variable to set which files you wish to use. To just configure the dev environment, use

	export COMPOSE_FILE=docker-compose.dev.yml:docker-compose.yml

It is possible to build the `qa` containers and then use `docker-compose` commands to modify or rebuild specific containers in the deployed set. This can be useful when only working on one or two services, since they can be modified individually without having to custom build all the other containers every time, which can save a lot of time.
