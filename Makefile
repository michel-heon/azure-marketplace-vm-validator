SHELL := /usr/bin/env bash

.PHONY: validate tests test report list

validate:
	./scripts/ctt.sh validate

tests:
	./scripts/ctt.sh tests

test:
	@if [ -z "$(TEST)" ]; then printf 'Usage: make test TEST=<name>\n'; exit 1; fi
	./scripts/ctt.sh test "$(TEST)"

list:
	./scripts/ctt.sh list

## Generate JSON + JUnit XML reports (set CTT_REPORT_DIR to write to a directory)
report:
	./scripts/ctt-report.sh
