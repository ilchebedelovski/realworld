#!make

include .env
export $(shell cut -d= -f1 .env)

.PHONY: help init destroy scale
.DEFAULT_GOAL := help

SHELL := /bin/bash

help: ## Show this help message.
	@echo 'usage: make [target] ...'
	@echo
	@echo 'targets:'
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

init: ## Initialize the Kubernetes cluster
	./scripts/init.sh
	./scripts/services.sh

destroy: ## Destroy the Kubernetes cluster
	./scripts/destroy.sh

scale: ## Add or destroy extra nodes on the cluster and also node size can be defined in the pool, example NODES=2 SIZE=s-2vcpu-4gb
	./scripts/scale.sh $(NODES) $(SIZE)
