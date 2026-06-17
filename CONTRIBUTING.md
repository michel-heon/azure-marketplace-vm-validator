# Contributing

## Add a new conformance test

1. Create a new executable file under `/tests` named `test_<id>_<area>.sh`.
2. Use strict mode: `set -euo pipefail`.
3. Source `/lib/_common.sh` and rely on `ctt_remote_*` helpers.
4. Keep one requirement per script (single responsibility).
5. Return `0` for PASS/WARN and non-zero for FAIL.
6. Ensure check runs through `az vm run-command invoke` only.
7. Validate with:
   - `make validate`
   - `make tests`
   - `make test TEST=test_<id>_<area>`
