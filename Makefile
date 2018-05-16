ENV ?= qa

REGION ?= eu-west-1

REGISTRY ?= 400079346860.dkr.ecr.eu-west-1.amazonaws.com/rdss-datavault

VERSION ?= $(shell git describe --tags --always --dirty)

ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

ANSIBLE_PLAYBOOK := $(shell command -v ansible-playbook 2> /dev/null)

check-ansible-playbook:
ifndef ANSIBLE_PLAYBOOK
	$(error "ansible-playbook is not available, please install Ansible.")
endif

build: build-images

clone: check-ansible-playbook  ## Clone source code repositories.
	ansible-playbook \
		--extra-vars="env=$(ENV) registry=$(REGISTRY) rdss_version=$(VERSION)" \
		--tags=clone \
			$(ROOT_DIR)/playbook.yml

build-images: check-ansible-playbook  ## Build Docker images.
	ansible-playbook \
		--extra-vars="env=$(ENV) registry=$(REGISTRY) rdss_version=$(VERSION)" \
		--tags=clone,build \
			$(ROOT_DIR)/playbook.yml

login:  ## Login to registry.
	./ecr-login.sh

publish: check-ansible-playbook  ## Publish Docker images to a registry.
	ansible-playbook \
		--extra-vars="env=$(ENV) registry=$(REGISTRY) rdss_version=$(VERSION)" \
		--tags=clone,build,publish \
			$(ROOT_DIR)/playbook.yml

help:  ## Print this help message.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
