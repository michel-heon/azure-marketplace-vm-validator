# RU-CTT (EN)

As a Marketplace publisher,
I want a reusable conformance toolkit for VM certification checks,
so that I can validate offer compliance independently from my workload tests.

## Acceptance criteria

- I can run `scripts/ctt.sh validate`, `tests`, `test <name>`, and `list`.
- Checks execute remotely through Azure Run Command.
- Conformance tests are isolated from application smoke tests.
