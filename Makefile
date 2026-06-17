SHELL := /usr/bin/env bash

.PHONY: validate tests test

validate:
	./scripts/ctt.sh validate

tests:
	./scripts/ctt.sh tests

test:
	@if [ -z "$(TEST)" ]; then printf 'Usage: make test TEST=<name>\n'; exit 1; fi
	./scripts/ctt.sh test "$(TEST)"
