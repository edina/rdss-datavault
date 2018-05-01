# rdss-datavault

Integration repo for the RDSS fork of DataVault.

## Usage

This project uses a Makefile to drive the build. Run `make help` to see a list
of targets with descriptions, e.g.:

```
$ make help
build-images                   Build Docker images.
clone                          Clone source code repositories.
help                           Print this help message.
```

## AWS environment

Using Terraform to create all the necessary infrastructure and Amazon ECS to run the containers in a cluster of EC2 instances.

Open [the aws folder](aws) to see more details.

## Development environment

Open [the compose folder](compose) to see more details.

