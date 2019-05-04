.DEFAULT_GOAL = all

.PHONY: all
all: fmt

.PHONY: fmt
fmt: ## formats files
	prettier \
		--parser markdown \
		--prose-wrap always \
		--write \
		*.md
