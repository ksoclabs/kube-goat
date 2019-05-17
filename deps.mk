.PHONY: deps
deps: deps-kind ## Install dependencies

.PHONY: deps-kind
deps-kind: deps-go deps-docker deps-kind-cli ## Install kind dependencies

.PHONY: deps-go
deps-go: ## Install go
	curl -sLO https://raw.githubusercontent.com/travis-ci/gimme/master/gimme
	chmod +x ./gimme
	./gimme stable

.PHONY: deps-docker
deps-docker: ## Install docker
	curl -fsSL https://get.docker.com | sh
	sudo usermod -aG docker $(USER)

.PHONY: deps-kind-cli
deps-kind-cli: ## Install kind cli
	GO111MODULE=on go get -u -v sigs.k8s.io/kind@master
