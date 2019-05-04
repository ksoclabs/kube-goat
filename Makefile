.DEFAULT_GOAL = help

include basic.mk deps.mk

.PHONY: cluster-create
cluster-create: ## Create kind cluster
	kind create cluster

.PHONY: cluster-delete
cluster-delete: ## Delete kind cluster
	kind delete cluster
