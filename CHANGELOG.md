# Changelog

All notable changes to `azure-marketplace-vm-validator` are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
Versioning: [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

---

## [0.6.0] — 2026-06-17

### Added
- **`scripts/ctt-report.sh`** — Report generator wrapping `ctt.sh tests`.
  Produces JSON (`--format json`) and JUnit XML (`--format junit`), or both
  (`--format all`, default). Parses `[PASS]`/`[FAIL]`/`[WARN]` lines from
  `ctt.sh` human output into structured `{test_id, section, status, message,
  duration_ms}` records (P5.1 / P5.2).
- **`CTT_REPORT_DIR` support** — when set, `ctt-report.sh` writes
  timestamped `ctt-report-<ISO>.json` and `ctt-junit-<ISO>.xml` to the
  directory (P5.3).
- **`Makefile` — `report` target** — `make report` runs `ctt-report.sh`
  with `CTT_REPORT_DIR` passthrough.
- **`Makefile` — `list` target** — expose `ctt.sh list` as `make list`.
- **`.github/workflows/conformance.yml` updated** — new inputs `distro`,
  `severity_warn_is_fail`, `upload_reports`; `make tests` replaced by
  `make report` (generates reports before upload); JUnit results published
  via `mikepenz/action-junit-report`; reports uploaded via
  `actions/upload-artifact@v4` with 30-day retention (P5.4).
- **`docs/usage.md`** — added *Reports* section with JSON schema, JUnit
  note, and `CTT_REPORT_DIR` examples.

---

## [0.5.0] — 2026-06-17

### Added
- **`lib/_malware_scanner.sh`** — ClamAV transient scanner helper. Single
  remote command: install ClamAV → `freshclam` → `clamscan --infected` on
  `CTT_MALWARE_SCAN_PATHS` → purge (guaranteed via `trap EXIT`). Output
  format: `clean` or `INFECTED:<n>:<file1>,<file2>,...` (P4.1 / P4.3).
- **`tests/test_2005_malware_scan.sh`** — Policy 200.5.2 gate. Consumes
  `ctt_malware_scan_cmd()`, parses `clean` / `INFECTED:*` /
  `SCANNER_ERROR:*` output, emits `ctt_pass` or `ctt_fail` accordingly
  (P4.2).

### Changed
- **`docs/usage.md`** — Added *Long-running tests* section documenting the
  ClamAV transient scan: typical 3–10 min execution time, `CTT_MALWARE_SCAN_PATHS`
  default value corrected to `/var/www /home /tmp /var/tmp` (P4.4).
- **`docs/policy-mapping.md`** — Added `test_2005_malware_scan.sh` row
  (200.5.2, ubuntu/rhel/debian).

---

## [0.4.0] — 2026-06-17

### Added
- **`lib/_distro_rhel.sh`** — Distro adapter for RHEL 8/9, CentOS Stream 8/9,
  Rocky Linux, AlmaLinux. Uses `dnf updateinfo list updates security` for
  security scan (P3.2).
- **`lib/_distro_debian.sh`** — Distro adapter for Debian 11 / 12. Near-Ubuntu
  but without ESM; uses `apt-get -s dist-upgrade` against `*-security` suite
  (P3.3).
- **`ctt_remote_detect_distro()`** in `lib/_common.sh` — reads
  `/etc/os-release` on the remote VM and returns the matching adapter name
  (`ubuntu`, `rhel`, `debian`). Falls back to `ubuntu` with a WARN for unknown
  IDs (P3.4).
- **`ctt_load_distro_adapter()` updated** — auto-detects distro when
  `CTT_DISTRO` is unset (unless `CTT_DRY_RUN=1` where it defaults to `ubuntu`).
  Exports resolved `CTT_DISTRO` so child test scripts inherit it (P3.4).
- **`.github/workflows/ci-multi-distro.yml`** — CI matrix workflow with three
  jobs: (1) adapter contract validation for each distro (`ubuntu`, `rhel`,
  `debian`) in dry-run, (2) `shellcheck --severity=warning` for all lib files,
  (3) CLI dry-run smoke (`validate`, `list`, `tests --severity-warn-is-fail`)
  (P3.5).
- **`docs/adr/100-ARCH-contrat-adapter-distro.md`** — ADR formalizing the
  mandatory adapter contract (3 required functions, return convention, optional
  extensions) (P3.1).
- **`lib/_distro_ubuntu.sh` optional functions** — `ctt_pkg_manager_name()` and
  `ctt_os_release_id()` added for completeness per ADR-100.

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

[0.6.0]: https://github.com/michel-heon/azure-marketplace-vm-validator/compare/v0.5.0...v0.6.0
[0.5.0]: https://github.com/michel-heon/azure-marketplace-vm-validator/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/michel-heon/azure-marketplace-vm-validator/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/michel-heon/azure-marketplace-vm-validator/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/michel-heon/azure-marketplace-vm-validator/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/michel-heon/azure-marketplace-vm-validator/releases/tag/v0.1.0
