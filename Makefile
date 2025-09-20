# Thanks: https://gist.github.com/mpneuried/0594963ad38e68917ef189b4e6a269db
.PHONY: help build build-metrics-exporter build-simple-app packer packer-metrics-exporter packer-simple-app

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

all: build packer tfplan

# Build
build: ## Compile golang apps 
	make build-metrics-exporter 
	make build-simple-app

build-metrics-exporter:
	cd applications/metrics-exporter && ./build.sh
	
build-simple-app:
	cd applications/simple-app && ./build.sh

# TASKS
packer: ## Build AMIs
	make packer-metrics-exporter 
	make packer-simple-app

packer-metrics-exporter:
	cd packer && packer validate packer-metrics-exporter.json; packer build packer-metrics-exporter.json

packer-simple-app:
	cd packer && packer validate packer-simple-app.json; packer build packer-simple-app.json

tfplan: ## terraform validate
	terraform -chdir=./terraform init; \
	terraform -chdir=./terraform plan 

tfapply: ## terraform apply
	terraform -chdir=./terraform apply
