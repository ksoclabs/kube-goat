.PHONY: deps
deps: deps-kind ## Install dependencies

.PHONY: deps-kind
deps-kind: deps-go deps-docker deps-kind-cli ## Install kind dependencies

.PHONY: deps-go
deps-go: ## Install go
ifeq (, $(shell which go))
GO_VERSION := $(shell curl -fsSL https://golang.org/VERSION?m=text)
GO_ARCH := linux-amd64
	curl -fsSL https://dl.google.com/go/$(GO_VERSION).$(GO_ARCH).tar.gz | sudo tar -vxzC /usr/local -f -
endif

.PHONY: deps-docker
deps-docker: ## Install docker
ifeq (, $(shell which docker))
	curl -fsSL https://get.docker.com | sh
	sudo usermod -aG docker $(USER)
endif

.PHONY: deps-kind-cli
deps-kind-cli: ## Install kind cli
ifeq (, $(shell which kind))
	go get -u -v sigs.k8s.io/kind
endif
