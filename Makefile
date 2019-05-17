.DEFAULT_GOAL = help

include basic.mk deps.mk

.PHONY: kind-create-cluster
kind-create-cluster: ## Create kind cluster
	kind create cluster --config=$(CURDIR)/examples/kind/config.yaml --name=insecure

.PHONY: kind-delete-cluster
kind-delete-cluster: ## Delete kind cluster
	kind delete cluster --name=insecure

.PHONY: attack
attack: ## Launches attack scenario for users to start playing
	kubectl --kubeconfig=$(HOME)/.kube/kind-config-kind \
		run \
		-it \
		--rm \
		--image=ubuntu \
		attacker \
		-- /bin/bash
