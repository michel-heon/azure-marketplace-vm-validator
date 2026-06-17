# Contributing

## Add a new conformance test

1. Create a new executable file under `tests/` named `test_<id>_<area>.sh`
   (see [ADR-601](docs/adr/601-DEVOPS-nomenclature-scripts-de-test.md)).
2. Use strict mode: `set -euo pipefail`.
3. Source `lib/_common.sh` and rely on `ctt_remote_*` helpers.
4. Keep one requirement per script (single responsibility — [ADR-700](docs/adr/700-TEST-taxonomie-tests-par-chapitre-200.md)).
5. Return `0` for PASS/WARN and non-zero for FAIL.
6. Ensure check runs through `az vm run-command invoke` only ([ADR-608](docs/adr/608-DEVOPS-frontiere-non-duplication-workload-agnostic.md)).
7. Add the test to `docs/policy-mapping.md`.
8. Validate locally:
   ```bash
   shellcheck --severity=warning tests/test_<id>_<area>.sh
   make test TEST=test_<id>_<area>
   bats tests/unit/   # if you added a unit test
   ```

## Add a distro adapter

1. Create `lib/_distro_<name>.sh` implementing the 3 mandatory functions
   defined in [ADR-100](docs/adr/100-ARCH-contrat-adapter-distro.md):
   - `ctt_pkg_update_security_check_cmd`
   - `ctt_cloud_init_present_cmd`
   - `ctt_pkg_installed_cmd <pkg>`
2. Add mapping in `ctt_remote_detect_distro()` (`lib/_common.sh`).
3. Add adapter contract tests in `tests/unit/test_distro_adapters.bats`.
4. Add the adapter to the CI matrix in `.github/workflows/ci-multi-distro.yml`.

## Versioning policy (Semantic Versioning)

This project follows [Semantic Versioning 2.0.0](https://semver.org/) and
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

| Change type | Version bump | Examples |
|-------------|-------------|---------|
| Breaking API change (`CTT_*` removed/renamed, CLI incompatible) | **MAJOR** `X.0.0` | Remove `CTT_DISTRO`, rename `ctt.sh validate` → `ctt.sh check` |
| New feature, backward-compatible | **MINOR** `0.X.0` | New test, new distro adapter, new CLI option |
| Bug fix, documentation, refactor | **PATCH** `0.0.X` | Fix false-positive in a test, typo fix |

### Release checklist

1. Update `CHANGELOG.md` — add a `## [X.Y.Z] — YYYY-MM-DD` section.
2. Add the comparison link at the bottom of `CHANGELOG.md`.
3. Commit: `git commit -m "chore(release): vX.Y.Z"`.
4. Tag: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`.
5. Push: `git push && git push --tags`.
6. Create a GitHub Release from the tag, copy the CHANGELOG section as notes.

## Code style

- Bash only — no Python, no Node, no compiled dependencies.
- All output via `ctt_pass / ctt_warn / ctt_fail / ctt_info` ([ADR-611](docs/adr/611-DEVOPS-conventions-couleurs-pass-fail-warn.md)).
- `printf` exclusively — never `echo -e`.
- Remote commands: one-liner strings returned by a function (ADR-100 pattern).
- Run `shellcheck --severity=warning` before committing.
