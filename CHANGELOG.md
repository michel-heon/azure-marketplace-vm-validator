# Changelog

All notable changes to `azure-marketplace-vm-validator` are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
Versioning: [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

---

## [0.3.0] — 2026-06-17

### Added
- **`test_2003_no_empty_passwords.sh`** — No account in `/etc/shadow` with an
  empty password field (P2.1).
- **`test_2005_permit_root_login.sh`** — `PermitRootLogin` is `no` or
  `prohibit-password` (via `sshd -T`) (P2.1).
- **`test_2005_no_default_credentials.sh`** — No active account has a trivially
  short or absent password hash in `/etc/shadow` (P2.1).
- **`test_2006_required_services.sh`** — Parameterized check: all services listed
  in `CTT_REQUIRED_SERVICES` are active. Skips with WARN when unset (P2.1).
- **`test_2002_required_packages.sh`** — Parameterized check: all packages listed
  in `CTT_REQUIRED_PACKAGES` are installed. Skips with WARN when unset (P2.1).
- **`test_2005_no_vulnerable_packages.sh`** — Generic DRIFT-001 equivalent:
  checks packages named in `CTT_VULNERABLE_PACKAGES` have no pending security
  fix; falls back to generic scan when unset (P2.3).
- **`test_2004_no_test_artifacts.sh`** — Generic DRIFT-002 equivalent: scans the
  entire filesystem for forbidden fixture filenames (configurable via
  `CTT_FORBIDDEN_ARTIFACTS`, defaults to `zip-bomb.zip`) (P2.3).
- **`lib/_distro_ubuntu.sh` — `ctt_pkg_installed_cmd()`** — new adapter function
  returning an `apt`-based install check command (required by
  `test_2002_required_packages.sh`) (P2.1).

### Changed
- **`lib/_distro_ubuntu.sh` — `ctt_pkg_update_security_check_cmd()`** — now
  forces `apt-get update` before the simulation and uses `dist-upgrade` instead
  of `upgrade` to catch package replacements and transitional packages (P2.2).

---

## [0.2.0] — 2026-06-17

### Added
- **`docs/usage.md`** — full public API reference for all `CTT_*` environment
  variables, CLI commands, distro adapters, and GitHub Actions integration
  (P1.1).
- **`docs/policy-mapping.md`** — table mapping every test file to its Microsoft
  certification policy clause (section 200.x), severity, and distro support
  (P1.2).
- **`--severity-warn-is-fail` CLI flag** (also `CTT_SEVERITY_WARN_IS_FAIL=1`)
  — promotes every `[WARN]` result to `[FAIL]`, enabling zero-tolerance mode for
  Partner Center submission gates (P1.4).
- **Runtime version checks in `ctt.sh validate`** — verifies `az` ≥ 2.50.0 and
  `jq` ≥ 1.6 with a structured PASS/FAIL message (P1.5).
- **ADR-601** — Nomenclature des scripts de test (`test_<chapter>_<area>.sh`).
- **ADR-608** — Frontière de non-duplication workload-agnostic.
- **ADR-611** — Conventions couleurs PASS/FAIL/WARN/INFO.
- **ADR-700** — Taxonomie des tests par chapitre de certification 200.x.

### Fixed
- **`test_2004_no_zipbomb.sh`** — widened scan from `/tmp /var/tmp` (depth 2)
  to the entire filesystem via `find / -xdev -type f -name 'zip-bomb.zip'`.
  Fixes DRIFT-002 (zip-bomb.zip left in `/var/www/peertube/` passed the old
  check undetected, causing the 2026-06-15 Partner Center rejection) (P1.3).

### Changed
- `ctt.sh usage()` updated to document the new `--severity-warn-is-fail` option.

---

## [0.1.0] — 2026-06-14

### Added
- Initial bootstrap: 14 conformance tests covering Microsoft certification
  chapters 200.3.3, 200.4.x, 200.5.x.
- `scripts/ctt.sh` CLI with `validate`, `tests`, `list`, `test <name>` commands.
- `lib/_common.sh` — helpers `ctt_pass / warn / fail / info`, `ctt_remote_exec`,
  `ctt_remote_stdout`, `ctt_remote_check_true/false`, `ctt_load_distro_adapter`.
- `lib/_distro_ubuntu.sh` — Ubuntu adapter.
- `.github/workflows/conformance.yml` — reusable `workflow_call` CI workflow.
- `Makefile` — `validate`, `tests`, `test TEST=<name>` targets.
- ADR-000 (META), ADR-600 (DEVOPS bootstrap CI).

[0.3.0]: https://github.com/michel-heon/azure-marketplace-vm-validator/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/michel-heon/azure-marketplace-vm-validator/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/michel-heon/azure-marketplace-vm-validator/releases/tag/v0.1.0
